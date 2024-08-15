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

#import "MainController.h"
#import "PreferenceWindowController.h"
#import "ProgressWindowController.h"
#import "64bitTransition.h"

@interface MainController(private)
- (void)launchJobs:(NSArray *)filenames;
@end

@implementation MainController

- (id)init
{
    if (self = [super init]) {
        launchedByDragDrop = NO;
        droppedItemCount = 0;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma delegate_application

- (void)awakeFromNib
{
#ifdef DEBUG
NSLog(@"awakeFromNib (%s:%d)", __FILE__, __LINE__);
#endif
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]]];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(allJobFinishedNotified:) name:PWCAllJobCompletedNotification object:nil];
    [center addObserver:self selector:@selector(filesDraggedNotified:) name:PWCFilesDraggedNotification object:nil];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
#ifdef DEBUG
NSLog(@"openFiles (%s:%d)", __FILE__, __LINE__);
#endif
    droppedItemCount += [filenames count];
    [self launchJobs:filenames];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#ifdef DEBUG
NSLog(@"applicationDidFinishLaunching (%s:%d)", __FILE__, __LINE__);
#endif
    if (droppedItemCount > 0) {
        launchedByDragDrop = YES;
    }

    [[ProgressWindowController sharedInstance] showWindow:self];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)notification
{
    ProgressWindowController *controller = [ProgressWindowController sharedInstance];

    if ([[controller subviewControllers] count] > 0) { // jobs are running yet
        NSInteger result;
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Warning", "")
                                         defaultButton:NSLocalizedString(@"Continue", "")
                                       alternateButton:NSLocalizedString(@"Quit", "")
                                           otherButton:nil
                             informativeTextWithFormat:NSLocalizedString(@"There are items in processing. Are you really quit ?", "")];
        [alert setAlertStyle:NSCriticalAlertStyle];

        result = [alert runModal];
        if (result == NSAlertAlternateReturn) {
            [[ProgressWindowController sharedInstance] removeAllJobs];
            return YES;
        } else {
            return NO;
        }
    }
    
    return YES;
}

#pragma notification

- (void)allJobFinishedNotified:(NSNotification *)notification
{
    if (launchedByDragDrop == YES && [[NSUserDefaults standardUserDefaults] boolForKey: @"doNotQuitAfterTask"] == NO) {
        [NSApp terminate:self];
    }
}

- (void)filesDraggedNotified:(NSNotification *)notification
{
    [self launchJobs:[notification object]];
}

#pragma action

- (IBAction)openMenu:(id)sender
{
    NSOpenPanel *panel;
    NSInteger rc;

    panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:YES];

    rc = [panel runModalForDirectory:NSHomeDirectory() file:@"Documents" types:nil];
    if (rc == NSOKButton) {
        [self launchJobs:[panel filenames]];
    }
}

- (IBAction)preferencesMenu:(id)sender
{
    PreferenceWindowController *controller = [PreferenceWindowController sharedInstance];
    [controller showWindow:self];
}

#pragma private

- (void)launchJobs:(NSArray *)filenames
{
    ProgressWindowController *controller = [ProgressWindowController sharedInstance];
    int i;

    [controller showWindow:self];
    if ([[NSUserDefaults standardUserDefaults] boolForKey : @"doTaskPerItem"] == YES) {
        for (i=0; i<[filenames count]; i++) {
            NSArray *arg = [NSArray arrayWithObject:[filenames objectAtIndex:i]];
            [controller addJob:arg];
        }
    } else {
        [controller addJob:filenames];
    }
}

@end
