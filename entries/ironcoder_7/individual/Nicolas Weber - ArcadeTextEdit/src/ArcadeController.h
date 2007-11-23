//
//  ArcadeController.h
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>\
#import <QuartzCore/QuartzCore.h>


@class AnimationLayer;

@interface ArcadeController : NSObject {

    IBOutlet NSTextView *textView;
    
    // XXX: This shouldn't be required, i need it only for coordinate
    // transforms...
    IBOutlet NSScrollView *scrollView;
    
    IBOutlet AnimationLayer *animationLayer;
    
    IBOutlet NSWindow *window;

    NSSet *keywords;
    NSArray *sounds;
    NSSound *background;

    CATextLayer *scoreLayer;
    CIFilter *filter;
    QCCompositionLayer* backgroundLayer;
    
    int score;
}

- (NSArray *)wordsInRange:(NSRange)range forString:(NSString *)string;
- (void)incrementScore:(int)dScore;

@end
