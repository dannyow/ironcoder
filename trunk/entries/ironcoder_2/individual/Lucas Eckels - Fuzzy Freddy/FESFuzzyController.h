//
//  FESFuzzyController.h
//  Fuzzy Freddy
//
//  Created by Lucas Eckels on 7/23/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FESHair;
@class FESQuartzView;

/**
 * The tool available for Fuzzy Freddy.
 */
enum FESFuzzyTool
{
   FESRazorTool, /**< A tool to reset the age of a region of hairs to 0 */
   FESTonicTool, /**< A tool to increase the growth rate of a region of hairs. */
   FESPoisonTool, /**< A tool to decrease the growth rate of a region of hairs. */
};

@interface FESFuzzyController : NSObject
{
   NSMutableArray *hairs;
   NSTimer *timer;
   NSPoint lastPoint;

   enum FESFuzzyTool currentTool;
   IBOutlet FESQuartzView *fuzzyView;
   
   NSCursor *razorCursor;
   NSCursor *poisonCursor;
   NSCursor *tonicCursor;
   
   NSSound *spraySound;
   
   CGColorRef colors[8];
}

- (IBAction)setRazor:(id)sender;
- (IBAction)setTonic:(id)sender;
- (IBAction)setPoison:(id)sender;

- (IBAction)playPause:(id)sender;
- (IBAction)saveAsPdf:(id)sender;
- (IBAction)openReadme:(id)sender;

- (IBAction)reset:(id)sender;

-(void)mouseDown:(NSEvent*)event;
-(void)mouseDragged:(NSEvent*)event;
-(void)mouseUp:(NSEvent*)event;

/**
 * Randomly generate hairs as specified in the various constants in FESFuzzyConstants.h
 */
-(void)makeHair;

/**
 * Age all hairs.
 */
-(id)age:(NSNotification*)notification;

/**
 * The cursor for the currently selected tool.
 */
-(NSCursor*)toolCursor;

/**
 * The data has changed, the view may need to be redrawn.
 */
-(void)dataChanged;

/**
 * Transform a point from view-space to model-space.
 */
-(NSPoint)transformPoint:(NSPoint)point;

/**
 * Determine if Freddy's getting fuzzier.
 * 
 * @return YES if the hair is currently growing, NO otherwise.
 */
-(BOOL)isPlaying;
@end
