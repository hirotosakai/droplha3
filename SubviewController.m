/*
 * Copyright (c) 2006 Hiroto Sakai
 * Contributed by Joar Wingfors
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

//
//  SubviewController.m
//  SubviewTableViewTester
//
//  Created by Joar Wingfors on Tue Dec 02 2003.
//  Copyright (c) 2003 joar.com. All rights reserved.
//

#import "SubviewController.h"

@interface SubviewController(private)
- (void)startJob;
@end

@implementation SubviewController

+ (id)controller
{
    return [[[self alloc] init] autorelease];
}

- (id)init
{
    if ((self = [super init]) != nil) {
        if (![NSBundle loadNibNamed: @"Subview" owner: self]) {
            [self release];
            self = nil;
            return self;
        }
        consoleLog = [[NSMutableString alloc] initWithString:@""];
        processingItem = [[NSMutableString alloc] initWithString:@""];
    }
    
    return self;
}

- (void)dealloc
{
    [subview release];
    [consoleLog release];
    [processingItem release];

    [super dealloc];
}

- (NSView *)view
{
    return subview;
}

- (NSString *)processingItem
{
    return processingItem;
}

- (NSString *)consoleLog
{
    return consoleLog;
}

- (void)startJob:(NSArray *)args workingDirectory:(NSString *)workDir processingItem:(NSString *)filename
{
    [processingItem setString:filename];
    [description setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Processing %@ ...", ""), [filename lastPathComponent]]];

    // allocate memory for and initialize a new TaskWrapper object
    if (jobController != nil)
        [jobController release];
    jobController = [[AMShellWrapper alloc] initWithController:self
                    inputPipe:nil outputPipe:nil errorPipe:nil
                    workingDirectory:workDir environment:nil
                    arguments:args];
    // kick off the process asynchronously
    [jobController startProcess];
}

#pragma action

- (IBAction)cancelClicked:(id) sender
{
    // kill the process
    if (jobController != nil)
        [jobController stopProcess];
}

#pragma AMShellWrapperController_protocol

- (void)appendOutput:(NSString *)output
{
    [consoleLog appendString:output];
    // notify to the ProgressWindowController
    [[NSNotificationCenter defaultCenter] postNotificationName:SCJobStdoutNotification object:[NSDictionary dictionaryWithObjectsAndKeys:self, SCJobRunningNotificationInfoKeyController, output, SCJobRunningNotificationInfoKeyOutput, nil]];
}

- (void)appendError:(NSString *)error
{
    [consoleLog appendString:error];
    // notify to the ProgressWindowController
    [[NSNotificationCenter defaultCenter] postNotificationName:SCJobStderrNotification object:[NSDictionary dictionaryWithObjectsAndKeys:self, SCJobRunningNotificationInfoKeyController, error, SCJobRunningNotificationInfoKeyOutput, nil]];
}

- (void)processStarted:(id)sender
{
    [progressIndicator startAnimation:nil];
}

- (void)processFinished:(id)sender withTerminationStatus:(int)resultCode
{
    [progressIndicator stopAnimation:nil];
    // notify to the ProgressWindowController
    [[NSNotificationCenter defaultCenter] postNotificationName:SCJobFinishedNotification object:[NSDictionary dictionaryWithObjectsAndKeys:self, SCJobFinishedNotificationInfoKeyController, [NSNumber numberWithInt:resultCode], SCJobFinishedNotificationInfoKeyStatus, nil]];
}

@end
