//
//  TextEffectAnimation.h
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/13/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/QuartzCore.h>

@interface TextEffectAnimation : CAAnimationGroup {

    CATextLayer *layer;
    
}

+ (TextEffectAnimation*)animationForLayer:(CATextLayer *)layer startFontSize:(int)fontSize;

- (TextEffectAnimation*)initWithLayer:(CATextLayer *)layer startFontSize:(int)fontSize;

//@property(retain) CATextLayer *layer;
@property(assign) CATextLayer *layer;

@end
