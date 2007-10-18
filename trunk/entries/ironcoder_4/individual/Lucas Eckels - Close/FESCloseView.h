//
//  FESCloseView.h
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

enum FESAnimationType
{
   FESNoAnimation,
   FESBlurAnimation,
   FESStinkCloudAnimation,
   FESTransitionAnimation
};
typedef enum FESAnimationType FESAnimationType;

@class CIFilter;
@class FESCloseController;

@interface FESCloseView : NSView {
   IBOutlet FESCloseController *controller;
   
   CIImage *background;

   FESAnimationType currentAnimation;

   // animation controls
   NSAnimation *animation;
   CIFilter *filter;
   NSString *blurString;
   NSMutableDictionary *textAttributes;
   BOOL animationBuild;
   
   float radius;
}

-(void)blurAndDisplayString:(NSString*)string;
-(void)displayStinkCloudAtPoint:(NSPoint)center radius:(float)radius color:(CIColor*)color0;

-(void)initializeTransition;
-(void)displayTransition;

-(void)setMapName:(NSString*)mapName;

@end
