//
//  AnimationView.m
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "AnimationLayer.h"

#import "TextEffectAnimation.h"


CGPoint CGPointFromNSPoint(NSPoint p)
{
    // Yay for Cocoa!
    return *(CGPoint*)&p;
}

@implementation AnimationLayer

- (id)init {
    if (![super init])
        return nil;

    layerQueue = [[NSMutableArray alloc] init];

    // text layers need this to set their bounds automatically from their
    // contents
    [self setLayoutManager:[CAConstraintLayoutManager layoutManager]];
    return self;
}

- (void)dealloc
{
    [layerQueue release];
    [super dealloc];
}

- (void)animationDidStop:(TextEffectAnimation *)animation finished:(BOOL)didComplete
{
    CALayer *layer = [layerQueue objectAtIndex:0];
    [layerQueue removeObjectAtIndex:0];
    
    // this also releases the layer, it's retained nowhere else
    [layer removeFromSuperlayer];
}

- (void)addString:(NSAttributedString *)string atPosition:(NSPoint)point
{
    CATextLayer *layer = [CATextLayer layer];
    
    // this makes setting the position easier, but it also sets the anchor for
    // scaling...we can't do that
    //layer.anchorPoint = CGPointMake(0, 0);
    layer.string = [string string];
    NSFont *font = [string attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
    layer.font = [font fontName];
    layer.fontSize = [font pointSize];
    
    // Sucks:
    //layer.magnificationFilter = kCAFilterNearest;   // Retro ftw!
    
    // XXX: Does this leak? No, one of the only cgcolor creation functions
    // that you don't have to cgrelease (according to the docs)
    layer.foregroundColor = CGColorCreateGenericRGB(1, 0, 0, 1);
    layer.position = CGPointFromNSPoint(point);

    TextEffectAnimation *anim = [TextEffectAnimation animationForLayer:layer startFontSize:[font pointSize]];
    [anim setDelegate:self];
    [layer addAnimation:anim forKey:@"myFunkyAnim"];
    
    CAConstraint *constraint;
    
    // set the constraint relative to the text layer's midpoint, looks nicer
    // that way if the layer is not deleted after vanishing. isn't completely
    // correct vertically, but it's good enough for the effect.
    NSRect stringRect = [string boundingRectWithSize:NSMakeSize(1e100, 1e100)
        options:NSStringDrawingOneShot|NSStringDrawingUsesLineFragmentOrigin];
    
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMidX
        relativeTo:@"superlayer" attribute:kCAConstraintMinX
        offset:point.x + stringRect.size.width/2];
    [layer addConstraint:constraint];
    
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMidY
        relativeTo:@"superlayer" attribute:kCAConstraintMinY
        offset:point.y + (stringRect.size.height+1)/2];
    [layer addConstraint:constraint];
    

    [self addSublayer:layer];
    
    [layerQueue addObject:layer];
}

@end
