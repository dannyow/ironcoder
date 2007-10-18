//
//  FESCloseView.m
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "FESCloseView.h"
#import "FESCloseConstants.h"
#import "CIContext_CloseExtension.h"
#import "NSBezierPath_CloseExtension.h"
#import "FESCloseController.h"

// Convenience function to clear an NSBitmapImageRep's bits to zero.
static void ClearBitmapImageRep(NSBitmapImageRep *bitmap) {
   unsigned char *bitmapData = [bitmap bitmapData];
   if (bitmapData != NULL) {
      // A fast alternative to filling with [NSColor clearColor].
      bzero(bitmapData, [bitmap bytesPerRow] * [bitmap pixelsHigh]);
   }
}


// Create a subclass of NSAnimation that we'll use to drive the transition.
@interface CloseViewAnimation : NSAnimation
@end

@interface FESCloseView (PrivateDrawMethods)
-(void)drawRegular;
-(void)drawBlurAnimation;
-(void)drawStinkCloudAnimation;
-(void)drawTransitionAnimation;
@end

@implementation FESCloseView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       background = nil;
       
        // Initialization code here.
       textAttributes = [[NSMutableDictionary alloc]
                             initWithObjectsAndKeys:
          [NSFont fontWithName: @"Marker Felt"
                          size: TEXT_SIZE],
          NSFontAttributeName,
          nil];

       animation = nil;
       filter = nil;
       blurString = nil;
    }
    return self;
}

-(void)setMapName:(NSString*)mapName;
{
   [background release];
   background = nil;
   
   NSString *path = [[NSBundle mainBundle] pathForImageResource:mapName];
   if (path != nil)
   {
      NSURL *url = [NSURL fileURLWithPath:path];
      
      background = [[CIImage alloc] initWithContentsOfURL:url];
   }   
}   
   

-(void)dealloc
{
   [background release];
   [textAttributes release];
   [super dealloc];
}

- (void)drawRect:(NSRect)rect {
   
   switch (currentAnimation)
   {
      case FESNoAnimation:
         [self drawRegular];
         break;
      case FESBlurAnimation:
         [self drawBlurAnimation];
         break;
      case FESStinkCloudAnimation:
         [self drawStinkCloudAnimation];
         break;
      case FESTransitionAnimation:
         [self drawTransitionAnimation];
         break;
   }
   

}

-(void)keyDown:(NSEvent*)event;
{
   FESTurnType turn;
   switch ([event keyCode])
   {
      case 126: // up cursor
      case 91: // keypad 8
         turn = FESUp;
         break;
      case 125: // down cursor
      case 84: // keypad 2
         turn = FESDown;
         break;
      case 123: // left cursor
      case 86: // keypad 6
         turn = FESLeft;
         break;
      case 124: // cursor right
      case 88: // keypad 4
         turn = FESRight;
         break;
      case 89: // keypad 7
         turn = FESUpLeft;
         break;
      case 92: // keypad 9
         turn = FESUpRight;
         break;
      case 83: // keypad 1
         turn = FESDownLeft;
         break;
      case 85: // keypad 3
         turn = FESDownRight;
         break;
      case 3: // f
         turn = FESFart;
         break;
      case 9: // v
         turn = FESTeleport;
         break;
      case 49: // spacebar
      case 87: // keypad 5
         turn = FESPass;
         break;
      default:
         return;
         
   }
   [controller executeTurn:turn];
}

-(void)mouseDown:(NSEvent*)event
{
   NSPoint pnt = [event locationInWindow];
   NSPoint localPnt = [self convertPoint:pnt fromView:nil];
   
   [controller clickInSquareX:localPnt.x/CHARACTER_WIDTH Y:localPnt.y/CHARACTER_HEIGHT];
   
}


-(BOOL)acceptsFirstResponder;
{
   return YES;
}

-(void)blurAndDisplayString:(NSString*)string;
{
   blurString = [string retain];
   NSRect rect = [self bounds];
   
   NSBitmapImageRep *content = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
   ClearBitmapImageRep(content);
   [self cacheDisplayInRect:rect toBitmapImageRep:content];
   
   CIImage *ciContent = [[CIImage alloc] initWithBitmapImageRep:content];
   filter = [[CIFilter filterWithName:@"CIGaussianBlur"] retain];
   [filter setDefaults];
   [filter setValue:ciContent forKey:@"inputImage"];
   [ciContent release];
   
   animation = [[CloseViewAnimation alloc] initWithDuration:TEXT_BLURRING_DURATION animationCurve:NSAnimationEaseInOut];
   [animation setFrameRate:30];
   [animation setDelegate:self];
   
   currentAnimation = FESBlurAnimation;
   
   animationBuild = YES;
   [animation startAnimation];
   animationBuild = NO;
   [animation startAnimation];
   
   [animation release];
   animation = nil;
   [filter release];
   filter = nil;
   [blurString release];
   blurString = nil;
   
   [self setNeedsDisplay:YES];
   currentAnimation = FESNoAnimation;

}

-(void)displayStinkCloudAtPoint:(NSPoint)center radius:(float)aRadius color:(CIColor*)color0;
{  
   radius = aRadius;
      
   
   filter = [[CIFilter filterWithName:@"CIGaussianGradient"] retain];
   [filter setDefaults];

   CIVector *ciVector = [CIVector vectorWithX:center.x Y:center.y];
   [filter setValue:ciVector forKey:@"inputCenter"];
   CIColor *color1 = [CIColor colorWithRed:0 green:0 blue:0 alpha:0];

   if (color0 == nil)
   {
      color0 = [[color1 retain] autorelease];
   }
   
   [filter setValue:color0 forKey:@"inputColor0"];
   [filter setValue:color1 forKey:@"inputColor1"];
   
   animation = [[CloseViewAnimation alloc] initWithDuration:STINK_CLOUD_DURATION animationCurve:NSAnimationLinear];
   [animation setFrameRate:30];
   [animation setDelegate:self];
   
   currentAnimation = FESStinkCloudAnimation;
   
   animationBuild = YES;
   [animation startAnimation];
   animationBuild = NO;
   [animation startAnimation];
   
   [animation release];
   animation = nil;
   [filter release];
   filter = nil;
   
   [self setNeedsDisplay:YES];
   currentAnimation = FESNoAnimation;

}

-(void)initializeTransition;
{
   NSRect rect = [self bounds];

   NSBitmapImageRep *content = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
   ClearBitmapImageRep(content);
   [self cacheDisplayInRect:rect toBitmapImageRep:content];
   
   CIImage *ciContent = [[CIImage alloc] initWithBitmapImageRep:content];
   filter = [[CIFilter filterWithName:@"CIDissolveTransition"] retain];
   [filter setDefaults];
   [filter setValue:ciContent forKey:@"inputImage"];
   [ciContent release];
   
   
}

-(void)displayTransition;
{
   NSRect rect = [self bounds];
   
   NSBitmapImageRep *content = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
   ClearBitmapImageRep(content);
   [self cacheDisplayInRect:rect toBitmapImageRep:content];
   
   CIImage *ciContent = [[CIImage alloc] initWithBitmapImageRep:content];
   [filter setValue:ciContent forKey:@"inputTargetImage"];
   [ciContent release];

   animation = [[CloseViewAnimation alloc] initWithDuration:TRANSITION_DURATION animationCurve:NSAnimationEaseInOut];
   [animation setFrameRate:30];
   [animation setDelegate:self];

   currentAnimation = FESTransitionAnimation;

   animationBuild = YES;
   [animation startAnimation];

   [animation release];
   animation = nil;
   [filter release];
   filter = nil;

   [self setNeedsDisplay:YES];
   currentAnimation = FESNoAnimation;
}

@end

@implementation FESCloseView (PrivateDrawMethods)
-(void)drawBlurAnimation;
{
   float animationValue = [animation currentValue];

   if (!animationBuild)
   {
         animationValue = 1-animationValue;
   }

   // blur the image
   [filter setValue:[NSNumber numberWithFloat:animationValue*10] forKey:@"inputRadius"];
   CIImage *outputCIImage = [filter valueForKey:@"outputImage"];

   NSRect imageRect = [self bounds];
   [outputCIImage drawInRect:imageRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];

   // draw the text
   if (blurString != nil)
   {
      NSSize size = [blurString sizeWithAttributes:textAttributes];
      NSPoint center = NSMakePoint(imageRect.origin.x + imageRect.size.width/2, imageRect.origin.y + imageRect.size.height/2);
      center.x -= size.width/2;
      
      NSRect rect = NSMakeRect(center.x - LINE_WIDTH, center.y - LINE_WIDTH, size.width+LINE_WIDTH*2, size.height+LINE_WIDTH*2);
      
      NSBezierPath *path = [NSBezierPath bezierPathWithRoundRectInRect:rect radius:LINE_WIDTH*2];
      [path setLineWidth:LINE_WIDTH];
      NSColor *color = [[NSColor whiteColor] colorWithAlphaComponent:animationValue*0.75];
      [color setFill];
      [path fill];
      
      color = [[NSColor blackColor] colorWithAlphaComponent:animationValue*3];
      [color setStroke];
      [path stroke];
      
      [textAttributes setValue:[[NSColor blackColor] colorWithAlphaComponent:animationValue] forKey:NSForegroundColorAttributeName];
      [blurString drawAtPoint:center withAttributes:textAttributes];
   }
}

-(void)drawStinkCloudAnimation;
{
   float animationValue = [animation currentValue];

   [self drawRegular];
   
   float currentRadius = animationValue * radius;
   if (!animationBuild)
   {
      currentRadius = radius + 2 * (animationValue) * radius;
      if (animationValue != 1)
      {
         CIColor *color0 = [filter valueForKey:@"inputColor0"];
         CIColor *newColor0 = [CIColor colorWithRed:[color0 red] green:[color0 green] blue:[color0 blue] alpha:1 / (5
                                                                                                                    *(animationValue))];
         [filter setValue:newColor0 forKey:@"inputColor0"];
      }
   }
   [filter setValue:[NSNumber numberWithFloat:currentRadius] forKey:@"inputRadius"];
   CIImage *outputCIImage = [filter valueForKey:@"outputImage"];
   
   NSRect imageRect = [self bounds];
   [outputCIImage drawInRect:imageRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
   
}

-(void)drawTransitionAnimation;
{
   [filter setValue:[NSNumber numberWithFloat:[animation currentValue]] forKey:@"inputTime"];
   CIImage *outputCIImage = [filter valueForKey:@"outputImage"];
   
   NSRect imageRect = [self bounds];
   [outputCIImage drawInRect:imageRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
   
}

-(void)drawRegular;
{
   CIContext *context = [[NSGraphicsContext currentContext] CIContext];
   NSRect dstRect = [self bounds];
   [context drawImage:background scaledInRect:*(CGRect*)&dstRect fromRect:[background extent]];

   [controller draw];
}

@end

@implementation CloseViewAnimation

// Override NSAnimation's -setCurrentProgress: method, and use it as our point to hook in and advance our Core Image transition effect to the next time slice.
- (void)setCurrentProgress:(NSAnimationProgress)progress {
   // First, invoke super's implementation, so that the NSAnimation will remember the proposed progress value and hand it back to us when we ask for it in AnimatingTabView's -drawRect: method.
   [super setCurrentProgress:progress];
   
   // Now ask the AnimatingTabView (which set itself as our delegate) to display.  Sending a -display message differs from sending -setNeedsDisplay: or -setNeedsDisplayInRect: in that it demands an immediate, syncrhonous redraw of the view.  Most of the time, it's preferrable to send a -setNeedsDisplay... message, which gives AppKit the opportunity to coalesce potentially numerous display requests and update the window efficiently when it's convenient.  But for a syncrhonously executing animation, it's appropriate to use -display.
   [[self delegate] display];
}

@end

