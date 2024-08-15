/*
 * Copyright (c) 2006 Hiroto Sakai
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

#import "PreferenceWindowController.h"
#import "PreferenceHelper.h"

#define DestionationIdentifier  @"destination"
#define OptionsIdentifier       @"options"

static PreferenceWindowController *gSharedInstance = nil;

@interface PreferenceWindowController(private)
- (void)adjustWindowSize:(NSString *)identifier isInitial:(BOOL)isInitial;
- (void)setupToolbar;
@end

@implementation PreferenceWindowController
// almost UI related features are implemented by Cocoa Bindings !

+ (PreferenceWindowController *)sharedInstance
{
    if (!gSharedInstance) {
        gSharedInstance = [[PreferenceWindowController alloc] init];
    }
    return gSharedInstance;
}

- (id)init
{
    if (self = [super initWithWindowNibName:@"Preference"]) {
        // initialize ...
    }
    return self;
}

- (void)dealloc
{
    if (self == gSharedInstance) {
        gSharedInstance = nil;
    }
    [super dealloc];
}

- (void)awakeFromNib
{
    [self setupToolbar];
    [self setWindowFrameAutosaveName:@"PreferenceWindow"];
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"NSWindow Frame PreferenceWindow"]) {
        [[self window] center];
    }
    [tabview selectTabViewItemWithIdentifier:DestionationIdentifier];
    [self adjustWindowSize:DestionationIdentifier isInitial:YES];
}

#pragma action

- (IBAction)selectDestination:(id)sender
{
    NSString *destination = [PreferenceHelper destinationFromUser];
    if ([destination length] > 0) {
        id values = [prefsController values];
        [values setValue:destination forKey:@"DestinationDir"];
        [values setValue:[NSNumber numberWithInt:DestinationTypeUse] forKey:@"DestinationType"];
    }
}

#pragma delegate

- (void)windowWillClose:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:DestionationIdentifier, OptionsIdentifier, nil];
}

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
    return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemId willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    NSToolbarItem*  toolbarItem;
    toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemId] autorelease];

	[toolbarItem setTarget:self];
	[toolbarItem setAction:@selector(showTab:)];

    if ([itemId isEqualToString:DestionationIdentifier]) {
        [toolbarItem setLabel:NSLocalizedString(@"Destination", @"")];
        [toolbarItem setImage:[NSImage imageNamed:@"Destination"]];
        return toolbarItem;
    }

    if ([itemId isEqualToString:OptionsIdentifier]) {
        [toolbarItem setLabel:NSLocalizedString(@"Options", @"")];
        [toolbarItem setImage:[NSImage imageNamed:@"Options"]];
        return toolbarItem;
    }
    
    return nil;
}

- (void)showTab:(id)sender
{
    if ([[tabview selectedTabViewItem] isEqualTo:sender]) {
        return;
    }

    // switch tab
    NSString *identifier = [sender itemIdentifier];
    [tabview selectTabViewItemWithIdentifier:identifier];
    if ([identifier isEqualToString:DestionationIdentifier]) {
        [tabview selectTabViewItemWithIdentifier:DestionationIdentifier];
    } else if ([identifier isEqualToString:OptionsIdentifier]) {
        [tabview selectTabViewItemWithIdentifier:OptionsIdentifier];
    } else {
        return;
    }

    // adjust window size
    [self adjustWindowSize:identifier isInitial:NO];
}

#pragma private

- (void)adjustWindowSize:(NSString *)identifier isInitial:(BOOL)isInitial
{
    NSRect windowRect = [[self window] frame];
    NSRect tabviewRect = [tabview frame];
    NSRect newRect;

    if ([identifier isEqualToString:DestionationIdentifier]) {
        newRect = [destinationBox frame];
    } else if ([identifier isEqualToString:OptionsIdentifier]) {
        newRect = [optionsBox frame];
    } else {
        return;
    }

    windowRect.size.height -= (tabviewRect.size.height - newRect.size.height);
    if (isInitial != YES) {
        windowRect.origin.y += (tabviewRect.size.height - newRect.size.height);
    }
    [[self window] setFrame:windowRect display:YES animate:YES];
}

- (void)setupToolbar
{
    NSToolbar* toolbar;

    toolbar = [[[NSToolbar alloc] initWithIdentifier:@"PreferencesToolBar"] autorelease];
    [toolbar setDelegate:self];
    [toolbar setSelectedItemIdentifier:DestionationIdentifier];
    [[self window] setToolbar:toolbar];
}

@end
