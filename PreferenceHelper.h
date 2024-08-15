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

#import <AppKit/AppKit.h>

#define DestinationTypeDesktop          0
#define DestinationTypeSameAsOriginal   1
#define DestinationTypeAsk              2
#define DestinationTypeUse              3

#define LZHHeaderLevel1     0
#define LZHHeaderLevel2     1
#define LZHHeaderLevel0     2

#define LZHMethodLH5        0
#define LZHMethodLH6        1
#define LZHMethodLH7        2
#define LZHMethodNoCompress 3

@interface PreferenceHelper : NSObject {
}

+ (NSString *)destinationFromUser;

@end
