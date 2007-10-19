/*
 * Project:     MyLife
 * File:        MyLifeView.m
 * Author:      Andrew Wellington
 *
 * License:
 * Copyright (C) 2007 Andrew Wellington.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MyLifeView.h"

#import "ArrayUtilities.h"
#import "MyLifeILifeUtilities.h"
#include <stdlib.h>

#define SCALE_TO_WIDTH 200
#define BUNDLE_ID   @"net.allocinit.ironcoder.mylife"

@implementation MyLifeView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
        srandomdev();
        runningQC = NO;
        
        ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:BUNDLE_ID];       
        [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
            @"Library", @"AlbumName",
            nil]];
        status = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [myLifeQCView release];
    [super dealloc];
}

- (void)startAnimation
{
    [super startAnimation];
    
    myLifeQCView = [[QCView alloc] initWithFrame:[self frame]];
    [myLifeQCView loadCompositionFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"MyLife" ofType:@"qtz"]];
    status = nil;
    [NSThread detachNewThreadSelector:@selector(prepareImages:) toTarget:self withObject:nil];
}

- (void)startQC:(id)sender
{
    runningQC = YES;
    [self addSubview:myLifeQCView];
    [myLifeQCView startRendering];   
}

- (void)abortLoadingImages:(id)sender
{
    if (status)
        [status release];
    status = [NSLocalizedString(@"Could not locate Album. Please select a new album.", @"") retain];
    [self setNeedsDisplay:YES];
}

- (void)stopAnimation
{
    [super stopAnimation];
    if (runningQC)
    {
        [myLifeQCView stopRendering];
        [myLifeQCView removeFromSuperview];
    }
    
    runningQC = NO;
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    if (!runningQC)
    {
        [[NSColor blackColor] set];
        NSRectFillUsingOperation([self frame], NSCompositeCopy);
        
        if (!status)
            status = @"Loading...";
        
        [status drawAtPoint:NSMakePoint(50.0, 50.0)
             withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]],
                 NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil]];
    }
    
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:BUNDLE_ID];
    
    if (!configSheet)
    {
        if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) 
        {
            NSLog( @"Failed to load configure sheet." );
            NSBeep();
        }
    }
    
    [album removeAllItems];
    [album addItemsWithTitles:[MyLifeILifeUtilities iPhotoAlbums]];
    [album selectItemWithTitle:[defaults objectForKey:@"AlbumName"]];
    
    return configSheet;
}

- (void)prepareImages:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray *images;
    NSMutableArray *imagePaths = [NSMutableArray array];
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:BUNDLE_ID];
    NSEnumerator *pathEnum = [[MyLifeILifeUtilities iPhotoPathsForAlbum:[defaults objectForKey:@"AlbumName"]] objectEnumerator]; 
    NSString *path;
    NSImage *image;
    int i, j, k;
    
    if (!pathEnum) {
        [self performSelectorOnMainThread:@selector(abortLoadingImages:) withObject:nil waitUntilDone:YES];
        [pool release];
        return;
    }
        
    
    while ((path = [pathEnum nextObject])) {
        //NSLog(@"Path: %@", path);
        [imagePaths addObject:path];
    }
    
    [imagePaths shuffle];
    j = 0;
    
    for (i=0; i < 4; i++)
    {   
        images = [NSMutableArray array];
        for (k = 0; k < 10;)
        {
            image = [[NSImage alloc] initWithContentsOfFile:[imagePaths objectAtIndex:j]];
            if (image)
            {
                float widthToHeightRatio = ((float)[[[image representations] objectAtIndex: 0] pixelsHigh])/((float)[[[image representations] objectAtIndex: 0] pixelsWide]);
                NSImage *scaledImage;
                scaledImage = [[NSImage alloc] initWithSize:NSMakeSize([self frame].size.width / 10, ([self frame].size.width / 10) * widthToHeightRatio)];
                [scaledImage lockFocus];
                [image drawInRect:NSMakeRect(0,0,[scaledImage size].width,[scaledImage size].height)
                         fromRect:NSMakeRect(0,0,[image size].width,[image size].height)
                        operation:NSCompositeCopy
                         fraction:1.0];
                [scaledImage unlockFocus];
                
                [images addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    scaledImage, @"img",
                    [NSNumber numberWithFloat:(random()%100)/10], @"speed",
                    nil]];
                [image release];
                [scaledImage release];
                k++;
            }
            j = (j + 1) % [imagePaths count];
        }
        [self performSelectorOnMainThread:@selector(setImageArray:)
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   images, @"imageArray",
                                   [NSString stringWithFormat:@"imageSet%d", i+1], @"setName",
                                   nil]
                            waitUntilDone:YES];
    }
    //NSLog(@"Images: %@", images);
    
    [self performSelectorOnMainThread:@selector(startQC:) withObject:nil waitUntilDone:YES];
    
    [pool release];
}

- (void)setImageArray:(NSDictionary *)dict
{
    [myLifeQCView setValue:[dict objectForKey:@"imageArray"] forInputKey:[dict objectForKey:@"setName"]];
}

- (IBAction)configOK:(id)sender
{
    ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:BUNDLE_ID];
    
    [defaults setObject:[album titleOfSelectedItem] forKey:@"AlbumName"];
    [defaults synchronize];
    [[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)configCancel:(id)sender
{
    [[NSApplication sharedApplication] endSheet:configSheet];
}

@end
