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

#import "CommandHelper.h"
#import "PreferenceHelper.h"
#import "64bitTransition.h"

#ifdef DEBUG
#define CommandName @"lha_debug"
#else
#define CommandName @"lha"
#endif

@interface CommandHelper(Private)
- (NSString *)initDestination;
- (NSString *)outputPath;
- (BOOL)isDestinationValid:(NSString *)destination;
- (NSString *)temporaryDestination;
@end

@implementation CommandHelper

- (id)initWithFiles:(NSArray *)filenames
{
    if (self = [super init]) {
        args = [[NSArray alloc] initWithArray:filenames];
        destination = [[NSMutableString alloc] initWithString:[self initDestination]];
    }
    return self;
}

- (void)dealloc
{
    [destination release];
    [args release];
    [super dealloc];
}

- (NSArray *)commandLine
{
    NSMutableArray *cmd;
    NSString *outputPath = [self outputPath];

    // lha co52 --ignore-mac-files /foo/bar/Archive.lzh file1 file2 file3 ...
    if (outputPath != nil) {
        cmd = [NSMutableArray arrayWithObject:[self commandPath]];
        [cmd addObjectsFromArray:[self commandOption]];
        [cmd addObject:outputPath];
        [cmd addObjectsFromArray:[self argsWithoutDirectory]];
        return cmd;
    }

    return nil;
}

// return lha command path
- (NSString *)commandPath
{
    return [[[NSBundle mainBundle] resourcePath]
              stringByAppendingPathComponent:CommandName];
}

- (NSArray *)argsWithoutDirectory
{
    int i;
    NSMutableArray *array = [NSMutableArray array];

    for (i=0; i<[args count]; i++) {
        [array addObject:[[args objectAtIndex:i] lastPathComponent]];
    }

    return array;
}

// return lha's option
- (NSArray *)commandOption
{
    NSMutableString *option;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *options;

    option = [NSMutableString stringWithString:@"c"];

    switch ([defaults integerForKey:@"CompressionMethod"]) {
    case LZHMethodLH6:
        [option appendString:@"o6"];
        break;
    case LZHMethodLH7:
        [option appendString:@"o7"];
        break;
    case LZHMethodNoCompress:
        [option appendString:@"z"];
        break;
    case LZHMethodLH5:
    default:
        [option appendString:@"o5"];
        break;
    }

    switch ([defaults integerForKey:@"HeaderLevel"]) {
    case LZHHeaderLevel0:
        [option appendString : @"0"];
        break;
    case LZHHeaderLevel1:
        [option appendString : @"1"];
        break;
    case LZHHeaderLevel2:
    default:
        [option appendString : @"2"];
        break;
    }

    options = [NSMutableArray arrayWithObject:option];

    if ([defaults boolForKey:@"StoreHiddenFile"] != YES) {
        [options addObject:@"--ignore-mac-files"];
    }

    return options;
}

- (NSString *)processingItem
{
    return [[self outputPath] lastPathComponent];
}

- (NSString *)destination
{
    return destination;
}

- (void)setDestination:(NSString *)path
{
    [destination setString:path];
}

- (NSString *)workingDirectory
{
    // return location of dropped items
    return [[args objectAtIndex:0] stringByDeletingLastPathComponent];
}

#pragma private

- (NSString *)initDestination
{
    NSString *path;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    switch ([defaults integerForKey:@"DestinationType"]) {
    case DestinationTypeSameAsOriginal:
        path = [[args objectAtIndex:0] stringByDeletingLastPathComponent];
        break;
    case DestinationTypeUse:
        path = [defaults stringForKey:@"DestinationDir"];
        break;
    case DestinationTypeDesktop:
        path = [[NSString stringWithString:NSHomeDirectory()]
                    stringByAppendingPathComponent:@"Desktop"];
        break;
    default:
        path = @"";
        break;
    }
    
    if ([self isDestinationValid:path]) {
        return path;
    } else {
        return @"";
    }
}

- (NSString *)outputPath
{
    NSString *path;
    NSString *dest;
    unsigned int i;

    if ([self isDestinationValid:[self destination]]) {
        dest = [self destination];
    } else {
        dest = [self temporaryDestination];
    }

    if ([args count] == 1) {
        path = [NSString stringWithFormat:@"%@/%@.lzh",
                    dest,
                    [[[args objectAtIndex:0] lastPathComponent] stringByDeletingPathExtension]];
    } else {
        path = [NSString stringWithFormat:@"%@/Archive.lzh",
                    dest];
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }

    // get alternative filename
    for (i=1; i<UINT_MAX; i++) {
        NSString *altPath = [NSString stringWithFormat:@"%@ %d.lzh",
                                    [path stringByDeletingPathExtension], i];
        if (![[NSFileManager defaultManager] fileExistsAtPath:altPath]) {
            return altPath;
        }
    }

    return nil;
}

- (BOOL)isDestinationValid:(NSString *)path
{
    NSFileManager *manager;
    BOOL isDir;

    manager = [NSFileManager defaultManager];
    if ([path length] < 1)
        return false;
    if (![manager fileExistsAtPath:path isDirectory:&isDir] || !isDir)
        return false;
    if (![manager isWritableFileAtPath:path])
        return false;

    return true;
}

- (NSString *)temporaryDestination
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    NSInteger rc;

    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanCreateDirectories:YES];

    rc = [panel runModalForTypes:nil];
    if (rc == NSOKButton) {
        return [panel filename];
    } else {
        return @"";
    }

    return nil;
}

@end
