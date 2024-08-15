/*
 * Copyright (c) 2006-2016 Hiroto Sakai
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ProgressWindowController.h"
#import "MainController.h"
#import "SubviewController.h"
#import "CommandHelper.h"
#import "PreferenceHelper.h"
#import "64bitTransition.h"

// Identifier of subviewTableView's columns
#define subviewTableColumn      @"progressView"

static ProgressWindowController *gSharedInstance = nil;

@interface ProgressWindowController(Private)
- (void)setProcessingLog;
- (void)appendProcessingLog:(NSString *)log;
- (NSAttributedString *)attributedLog:(NSString *)log;
@end

@implementation ProgressWindowController

+ (ProgressWindowController *)sharedInstance
{
    if (!gSharedInstance) {
        gSharedInstance = [[ProgressWindowController alloc] init];
    }
    return gSharedInstance;
}

- (id)init
{
    if (self = [super initWithWindowNibName:@"Progress"]) {
        // initialize ...
    }
    return self;
}

- (void)dealloc
{
    if (self == gSharedInstance) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [tableViewController release];
        [subviewControllers release];
        gSharedInstance = nil;
    }
    [super dealloc];
}

#pragma public

// The rows in the table view
- (NSMutableArray *)subviewControllers
{
    if (subviewControllers == nil) {
        subviewControllers = [[NSMutableArray alloc] init];
    }
    return subviewControllers;
}

- (void)addJob:(NSArray *)filenames
{
    CommandHelper *helper = [[[CommandHelper alloc] initWithFiles:filenames] autorelease];

    // ask destination, if need
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"DestinationType"] == 2) { // Ask
        NSString *destination = [PreferenceHelper destinationFromUser];
        if ([destination length] == 0) {
            return; // skip
        } else {
            [helper setDestination:destination];
        }
    }

    // if destionation is not usable, abort and show error dialog
    if ([[helper destination] length] == 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Error", "")
                                         defaultButton:NSLocalizedString(@"OK", "")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"An specified destination is unaccessable. Please check your setting in prefenreces.", "")];
        [alert runModal];
        return;
    }

    // launch job
    NSArray *args = [helper commandLine];
    NSString *workDir = [helper workingDirectory];
    NSString *procItem = [helper processingItem];

#ifdef DEBUG
NSLog(@"%@", args);
NSLog(@"workDir %@", workDir);
NSLog(@"procItem %@", procItem);
#endif

    // add progress view
    SubviewController *controller = [SubviewController controller];
    [controller startJob:args workingDirectory:workDir processingItem:procItem];
    [[self subviewControllers] addObject:controller];

    // reload table view
    [tableViewController reloadTableView];
    NSInteger row = [[self subviewControllers] count] - 1;
    [subviewTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    [subviewTableView scrollRowToVisible:row];
}

- (void)removeAllJobs
{
    [[self subviewControllers] removeAllObjects];
    [tableViewController reloadTableView];
}

#pragma delegate

- (void)awakeFromNib
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    // creating the SubviewTableViewController
    tableViewController = [[SubviewTableViewController controllerWithViewColumn:[subviewTableView tableColumnWithIdentifier:subviewTableColumn]] retain];
    [tableViewController setDelegate:self];

    // setup window
    [self setWindowFrameAutosaveName:@"ProgressWindow"];
    if (![defaults stringForKey:@"NSWindow Frame ProgressWindow"]) {
        [[self window] center];
    }
    [[self window] registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];

    // add observer from SubviewController
    [center addObserver:self selector:@selector(jobFinishedNotified:) name:SCJobFinishedNotification object:nil];
    [center addObserver:self selector:@selector(jobRunningNotified:) name:SCJobStdoutNotification object:nil];
    [center addObserver:self selector:@selector(jobRunningNotified:) name:SCJobStderrNotification object:nil];
}

#pragma delegate_drag_and_drop

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];

    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
//        [subviewTableView setFocusRingType:NSFocusRingTypeDefault];
        if (sourceDragMask & NSDragOperationLink) {
            return NSDragOperationLink;
        } else if (sourceDragMask & NSDragOperationCopy) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
//        [subviewTableView setFocusRingType:NSFocusRingTypeNone];
    }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
        // notificate to MainController
        [[NSNotificationCenter defaultCenter] postNotificationName:PWCFilesDraggedNotification object:filenames];
    }
    return YES;
}

#pragma delegate_drawer

- (void)drawerWillOpen:(NSNotification *)notification
{
    [disclosureLabel setStringValue:NSLocalizedString(@"Hide details", "")];
    [self setProcessingLog];
}

- (void)drawerDidClose:(NSNotification *)notification
{
    [disclosureLabel setStringValue:NSLocalizedString(@"Show details", "")];
}

#pragma delegate_tableview

// Methods from SubviewTableViewControllerDataSourceProtocol
- (NSView *)tableView:(NSTableView *)tableView viewForRow:(NSInteger)row
{
    return [[[self subviewControllers] objectAtIndex:row] view];
}

// Methods from NSTableDataSource protocol
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self subviewControllers] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return nil;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self setProcessingLog];
}

#pragma notification

- (void)jobRunningNotified:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    int i;

    if ([subviewTableView selectedRow] < 0) // no row is selected
        return;

    SubviewController *controller = [dict valueForKey:SCJobRunningNotificationInfoKeyController];
    for (i=0; i<[[self subviewControllers] count]; i++) {
        if ([controller isEqualTo:[[self subviewControllers] objectAtIndex:i]]) {
            [self appendProcessingLog:[dict valueForKey:SCJobRunningNotificationInfoKeyOutput]];
            break;
        }
    }
}

- (void)jobFinishedNotified:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    int i;

    SubviewController *controller = [dict valueForKey:SCJobFinishedNotificationInfoKeyController];

    // check return value of command
    int result = [[dict valueForKey:SCJobFinishedNotificationInfoKeyStatus] intValue];
    if (result != 0) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"An error occurred while processing %@ (Error code: %d).", ""), [controller processingItem], result];
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Error", "")
                                         defaultButton:NSLocalizedString(@"OK", "")
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:message];
        [alert runModal];
    }

    // remove row already finished
    for (i=0; i<[[self subviewControllers] count]; i++) {
        if ([controller isEqualTo:[[self subviewControllers] objectAtIndex:i]]) {
            [subviewTableView deselectAll:nil];
            [[self subviewControllers] removeObjectAtIndex:i];
            [tableViewController reloadTableView];
            break;
        }
    }
    
    // in case of all jobs are completed
    if ([[self subviewControllers] count] == 0) {
        [detailTextView setString:@""];
        // notificate to MainController
        [[NSNotificationCenter defaultCenter] postNotificationName:PWCAllJobCompletedNotification object:nil];
    }
}

#pragma private

- (void)setProcessingLog
{
    NSInteger row = [subviewTableView selectedRow];

    if (row >= 0) { // row is selected
        NSString *log = [[[self subviewControllers] objectAtIndex:row] consoleLog];
        [[detailTextView textStorage] setAttributedString:[self attributedLog:log]];
    } else {
        [[detailTextView textStorage] setAttributedString:[self attributedLog:@""]];
    }
}

- (void)appendProcessingLog:(NSString *)log
{
    [[detailTextView textStorage] appendAttributedString:[self attributedLog:log]];
    [detailTextView scrollRangeToVisible:NSMakeRange([[detailTextView string] length], 0)];
}

- (NSAttributedString *)attributedLog:(NSString *)log
{
    NSMutableAttributedString *string;
    NSFont *font;

    string = [[[NSMutableAttributedString alloc] initWithString:log] autorelease];
    font = [NSFont userFixedPitchFontOfSize:10];

    [string addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [log length])];
    return string;
}

@end
