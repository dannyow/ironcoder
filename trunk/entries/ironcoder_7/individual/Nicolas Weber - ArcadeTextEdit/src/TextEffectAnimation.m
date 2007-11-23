//
//  TextEffectAnimation.m
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TextEffectAnimation.h"


@implementation TextEffectAnimation

+ (TextEffectAnimation*)animationForLayer:(CATextLayer *)layer startFontSize:(int)fontSize
{
    return [[[TextEffectAnimation alloc] initWithLayer:layer startFontSize:fontSize] autorelease];
}

-(void)dealloc
{
    //if (layer)
    //    [layer release];

    [super dealloc];
}

- (TextEffectAnimation*)initWithLayer:(CATextLayer *)theLayer startFontSize:(int)fontSize
{
    if (![super init])
        return nil;
    
    [self setLayer:theLayer];
    
    //*
    CABasicAnimation *animX = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animX.fromValue = [NSNumber numberWithInt:1];
    animX.toValue = [NSNumber numberWithInt:8];
    
    CABasicAnimation *animY = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animY.fromValue = [NSNumber numberWithInt:1];
    animY.toValue = [NSNumber numberWithInt:8];
    /*/
    // fontSize is not animatable, and i don't understand how i could change
    // that. i could add an action that does the following when fontSize is
    // written to, but it doesn't seem to do anything...
    CABasicAnimation *animSize = [CABasicAnimation animationWithKeyPath:@"fontSize"];
    animSize.toValue = [NSNumber numberWithInt:fontSize];
    animSize.toValue = [NSNumber numberWithInt:2*fontSize];
    //*/
    
    CABasicAnimation *alpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alpha.fromValue = [NSNumber numberWithFloat:1];
    alpha.toValue = [NSNumber numberWithFloat:0];
    
    [self setAnimations:[NSArray arrayWithObjects:animX, animY, alpha, nil]];
    //[self setAnimations:[NSArray arrayWithObjects:animSize, alpha, nil]];

    self.fillMode = kCAFillModeForwards;
    self.removedOnCompletion = NO;
    
    // 1: super slomo
    // .5: a bit too slow
    // .25: two bits too fast
    self.duration = .4;

    return self;
}

@synthesize layer;

@end
