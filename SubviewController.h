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
//  SubviewController.h
//  SubviewTableViewTester
//
//  Created by Joar Wingfors on Tue Dec 02 2003.
//  Copyright (c) 2003 joar.com. All rights reserved.
//

/*****************************************************************************

SubviewController

Overview:

The SubviewController is a very simple class. It is the controller object for
the custom views used in the table. It provides the view, and answers to
actions methods from the view or the table view controller.

*****************************************************************************/

#import <AppKit/AppKit.h>
#import "AMShellWrapper.h"

#define SCJobFinishedNotification   @"SCJobFinishedNotification"
#define SCJobFinishedNotificationInfoKeyController   @"SCJobFinishedNotificationInfoKeyController"
#define SCJobFinishedNotificationInfoKeyStatus   @"SCJobFinishedNotificationInfoKeyStatus"
#define SCJobStdoutNotification   @"SCJobStdoutNotification"
#define SCJobStderrNotification   @"SCJobStderrNotification"
#define SCJobRunningNotificationInfoKeyController   @"SCJobRunningNotificationInfoKeyController"
#define SCJobRunningNotificationInfoKeyOutput   @"SCJobRunningNotificationInfoKeyOutput"

@interface SubviewController : NSObject <AMShellWrapperController>
{
    @private

    IBOutlet NSView *subview;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *description;
    
    AMShellWrapper *jobController;
    BOOL isAnimating;
    NSMutableString *processingItem;
    NSMutableString *consoleLog;
}

// Convenience factory method
+ (id)controller;

// The view displayed in the table view
- (NSView *)view;

- (NSString *)processingItem;
- (NSString *)consoleLog;
- (void)startJob:(NSArray *)args workingDirectory:(NSString *)workDir processingItem:(NSString *)filename;

// Called when the cancel button was clicked
- (IBAction)cancelClicked:(id)sender;

@end
