//
//  BSInvaderBackgroundView.m
//  Invader
//
//  Created by Blake Seely on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BSInvaderBackgroundView.h"
#import "BSInvaderBackgroundWindow.h"
#import "BSInvaderAppDelegate.h"

#define CGRectToNSRect(r) NSMakeRect(r.origin.x, r.origin.y, r.size.width, r.size.height)

@implementation BSInvaderBackgroundView

- (id)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect])
    {
        _backgroundImage = nil;
        _bullets = [[NSMutableSet alloc] init];
        _bulletTimer = nil;
    }
    
    return self;
}

- (void)dealloc
{
    [_backgroundImage release];
    [_bullets release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    
}

- (void)drawRect:(NSRect)rect
{    
    if (!_backgroundImage)
    {
        _backgroundImage = [[CIImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Screen.png"]]];
        [_backgroundImage drawAtPoint:NSMakePoint(0,0) fromRect:[self frame] operation:NSCompositeCopy fraction:1.0];
    }
    
    if (_backgroundImage)
    {
        //[_backgroundImage drawAtPoint:NSMakePoint(0,0) fromRect:[self bounds] operation:NSCompositeCopy fraction:1.0];
        
        NSEnumerator *enumerator = [_bullets objectEnumerator];
        CIVector *center = nil;
        CIImage *outputImage = _backgroundImage;
        NSRect fromRect = [self frame];
        while (center = [enumerator nextObject])
        {
            CIFilter *holeFilter = [CIFilter filterWithName:@"CIHoleDistortion"];
            [holeFilter setDefaults];
            [holeFilter setValue:[NSNumber numberWithInt:30] forKey:@"inputRadius"];
            [holeFilter setValue:center forKey:@"inputCenter"];
            [holeFilter setValue:outputImage forKey:@"inputImage"];
            outputImage = [holeFilter valueForKey:@"outputImage"];
            
        }
        
        [outputImage drawInRect:[self frame] fromRect:fromRect operation:NSCompositeCopy fraction:1.0];
        
    }
}

- (void)fire
{
    if ([_bullets count] > 0 && !_bulletTimer)
    {
        _bulletTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(moveBullets:) userInfo:nil repeats:YES];
    }
}

- (void)moveBullets:(NSTimer *)timer
{
    NSEnumerator *enumerator = [_bullets objectEnumerator];
    CIVector *center = nil;
    NSMutableSet *newBullets = [[NSMutableSet alloc] init];
    BOOL hit = NO;
    while (center = [enumerator nextObject])
    {
        NSPoint point = NSMakePoint([center X], [center Y]);
        NSArray *subviews = [self subviews];
        int i;
        for (i = 0; i < [subviews count]; i++)
        {
            NSView *subview = [subviews objectAtIndex:i];
            if (NSPointInRect(point,[subview frame]))
            {
                [delegate removeInvader:subview];
                hit = YES;
                break;
            }
        }
        
        if (!hit && ([center Y] < [self bounds].size.height))
        {
            CIVector *newCenter = [CIVector vectorWithX:[center X] Y:([center Y] + 20)];
            [newBullets addObject:newCenter];
        }
                
    }
    
    [_bullets removeAllObjects];
    [_bullets unionSet:newBullets];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event
{
    NSPoint clickPoint = [self convertPoint:[event locationInWindow] fromView:nil];
    CIVector *bulletCenter = [CIVector vectorWithX:clickPoint.x Y:0];
    [_bullets addObject:bulletCenter];
    
    [self fire];
}

@end
