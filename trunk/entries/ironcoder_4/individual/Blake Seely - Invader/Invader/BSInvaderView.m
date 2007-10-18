//
//  BSInvaderView.m
//  Invader
//
//  Created by Blake Seely on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BSInvaderView.h"


@implementation BSInvaderView

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        _alive = NO;
        _birthDuration = 2.0;
        _birthTime = 0.0;
        
        NSString *frame1Path = [[NSBundle mainBundle] pathForResource:@"A2" ofType:@"png"];
        frame1 = [[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:frame1Path]];
        NSString *frame2Path = [[NSBundle mainBundle] pathForResource:@"B2" ofType:@"png"];
        frame2 = [[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:frame2Path]];
        
        _currentFrame = frame1;
    }
    
    return self;
}

- (void)dealloc
{
    [_frameTimer invalidate];
    
    [frame1 release];
    [frame2 release];
    
    [super dealloc];
}

- (void)birthAtRect:(NSRect)rect
{
    [self setFrame:rect];
    
    NSAnimation *birthAnimation = [[NSAnimation alloc] initWithDuration:_birthDuration animationCurve:NSAnimationEaseInOut];
    [birthAnimation setDelegate:self];
    [birthAnimation setAnimationBlockingMode:NSAnimationNonblocking];
    
    NSMutableArray *array = [NSMutableArray array];
    float i;
    for (i = 1; i <= 100.0; i+= 5.0)
        [array addObject:[NSNumber numberWithFloat:(i / 100)]];
    //[birthAnimation setProgressMarks:array];
    [birthAnimation startAnimation];    
}

- (void)drawRect:(NSRect)rect
{
    // Clear the drawing
    [[NSColor clearColor] set];
    [NSBezierPath fillRect:[self frame]];
    
    // Capture an image of the background
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    CIImage *originalImage = [[CIImage alloc] initWithBitmapImageRep:rep];
    [rep release];
    
    
    CIFilter *invertFilter = [CIFilter filterWithName:@"CIColorInvert"];
    [invertFilter setDefaults];
    [invertFilter setValue:originalImage forKey:@"inputImage"];
    CIImage *invertedImage = [invertFilter valueForKey:@"outputImage"];
    
    CIFilter *maskFilter = [CIFilter filterWithName:@"CIBlendWithMask"];
    [maskFilter setDefaults];
    [maskFilter setValue:originalImage forKey:@"inputBackgroundImage"];
    [maskFilter setValue:invertedImage forKey:@"inputImage"];
    [maskFilter setValue:_currentFrame forKey:@"inputMaskImage"];
    
    CIImage *output = [maskFilter valueForKey:@"outputImage"];
    [output drawAtPoint:NSMakePoint(0,0) fromRect:NSMakeRect(0,0,[self bounds].size.width, [self bounds].size.height)  operation:NSCompositeSourceOver fraction:_birthTime];
        
}

#pragma mark -
// Timer
#pragma mark Timer

- (void)step:(NSRect)rect
{
    [self setFrame:rect];
    if (_currentFrame == frame1)
        _currentFrame = frame2;
    else
        _currentFrame = frame1;

    [self setNeedsDisplay:YES];
}
- (void)frameChange:(NSTimer *)timer
{
    if (_currentFrame == frame1)
        _currentFrame = frame2;
    else
        _currentFrame = frame1;
}

#pragma mark -
// Animation delegate
#pragma mark Animation Delegate

- (void)animation:(NSAnimation*)animation didReachProgressMark:(NSAnimationProgress)progress
{
    _birthTime = progress;
    [self setNeedsDisplay:YES];
}

- (void)animationDidEnd:(NSAnimation*)animation
{
    _alive = YES;
    _birthTime = 1.0;
    [animation release];
}

@end
