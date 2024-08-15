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
//  SubviewTableViewCell.h
//  SubviewTableViewTester
//
//  Created by Joar Wingfors on Sat Feb 15 2003.
//  Copyright (c) 2003 joar.com. All rights reserved.
//

/*****************************************************************************

SubviewTableViewCell

Overview:

This is a very simple cell subclass used as the table data cell in the column
where the custom view will be used. It is responsible for ensuring that the
custom view is inserted into the table view, and of proper size and position.

*****************************************************************************/

#import <AppKit/AppKit.h>

@interface SubviewTableViewCell : NSCell
{
    @private
    NSView *subview;
}

// The view is not retained by the cell!
- (void) addSubview:(NSView *) view;

@end
