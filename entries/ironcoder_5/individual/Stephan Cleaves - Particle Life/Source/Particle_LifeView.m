//
//  Particle_LifeView.m
//  Particle Life
//
//  Created by Stephan Cleaves on 4/1/07.
//  Copyright (c) 2007, Yellow Camp Software. All rights reserved.
//

#import "Particle_LifeView.h"
#import "YCIC5Particle.h"
#import "YCIC5Simulation.h"

@implementation Particle_LifeView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
        simulation = [[YCIC5Simulation alloc] initWithSize:frame.size];
    }
    return self;
}

- (void)dealloc
{
    [simulation release]; simulation = nil;
    
    [super dealloc];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    NSEnumerator *particleEnum = [simulation particleEnumerator];
    NSRect particleRect = NSMakeRect( 0, 0, 1, 1 );
    YCIC5Particle *particle;
    
    [super drawRect:rect];
    
    [[NSColor blackColor] set];
    NSRectFill( rect );
    
    [[NSColor whiteColor] set];
    while ( particle = [particleEnum nextObject] ) {
        particleRect.origin = [particle location];
        NSRectFill( particleRect );
    }
}

- (void)animateOneFrame
{
    [simulation update];
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
