/*
 * Copyright (c) 2006-2016 Hiroto Sakai
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
//  SubviewTableViewController.h
//  SubviewTableViewTester
//
//  Created by Joar Wingfors on Sat Feb 15 2003.
//  Copyright (c) 2003 joar.com. All rights reserved.
//

/*****************************************************************************

SubviewTableViewController

Files:

* SubviewTableViewController.h
* SubviewTableViewCell.h

Overview:

The SubviewTableViewController (STVC) is used to create a table view like the
one used in the rules preference pane in Mail, or the new find panel in Finder.
It allows you to provide views that will be displayed instead of (really: on
top of) the usual cells in the table view.

Usage guidelines:

The table view used to hold the contents is a standard NSTableView. The table 
view needs to have a table column dedicated for the subviews. The table view 
also preferably needs to have a row height matching the height of the subviews. 
The owner of the table view should instantiate a STVC using the convenience 
method, and providing this column:

- (void) awakeFromNib
{
    tableViewController = 
    [[SubviewTableViewController controllerWithViewColumn: subviewTableColumn] 
        retain];
    [tableViewController setDelegate: self];
}

The STVC will make itself the delegate and data source of the table view, 
and will forward all data source and delegate methods to the original owner.

NOTE! In order for the STVC to know when the contents of the table view has 
changed a public method is provided to trigger the reload of the table view 
via the controller. You NEED to use this method in any case where you would 
have otherwise used "reloadData" from NSTableView:

[tableViewController reloadTableView];

*****************************************************************************/

#import <AppKit/AppKit.h>
#import "64bitTransition.h"

@interface SubviewTableViewController : NSObject
{
    @private

    NSTableView *subviewTableView;
    NSTableColumn *subviewTableColumn;

    id delegate;
}

// Convenience factory method
+ (id)controllerWithViewColumn:(NSTableColumn *)vCol;

// The delegate is required to conform to the SubviewTableViewControllerDataSourceProtocol
- (void)setDelegate:(id)obj;
- (id)delegate;

// The method to call instead of the standard "reloadData" method of NSTableView.
// You need to call this method at any time that you would have called reloadData
// on a table view.
- (void) reloadTableView;

@end

@protocol SubviewTableViewControllerDataSourceProtocol

// The view retreived will not be retained, and will be resized to fit the
// cell in the table view. Please adjust the row height and column width in
// ib (or in code) to make sure that it is appropriate for the views used.
- (NSView *)tableView:(NSTableView *)tableView viewForRow:(NSInteger)row;

@end
