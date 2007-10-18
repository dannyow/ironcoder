//
//  GameView.m
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 27/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import "GameView.h"
#import "SpaceDefenderConstants.h"
#import "SpaceDefenderDelegate.h"
#import "Sprite.h"


static const unsigned scFlashXOrigin = 50;
static const float scGameOverTransitionIncrement = 0.1;


@interface GameView ( PrivateAPI )
- ( void ) drawBackground;
- ( CIImage* ) generateTitleImage;
@end

@implementation GameView

- ( id ) initWithFrame : ( NSRect ) frame
{
   self = [ super initWithFrame: frame ];
   if( self )
   {
      NSURL* url = [ NSURL fileURLWithPath: [[ NSBundle mainBundle ]
         pathForResource: @"background" ofType: @"tif" ]];
      backgroundImage = [[ NSImage alloc ] initWithContentsOfURL: url ];
      
      drawTitle = YES;
      
      offscreenImage = [[ NSBitmapImageRep alloc ] initWithBitmapDataPlanes: nil
            pixelsWide: gSMSViewRect.size.width
            pixelsHigh: gSMSViewRect.size.height
            bitsPerSample: 8
            samplesPerPixel: 4
            hasAlpha: YES
            isPlanar: NO
            colorSpaceName: NSCalibratedRGBColorSpace
            bitmapFormat: 0
            bytesPerRow: (4 * gSMSViewRect.size.width)
            bitsPerPixel: 32 ];

      [ self drawTitleViewOffscreen ];
      
      // The flash transition is used when the game is over.
      gameOverFilter = [ CIFilter filterWithName: @"CIFlashTransition" ];
      [ gameOverFilter setDefaults ];
      [ gameOverFilter setValue: [ CIVector vectorWithX: ( gSMSViewWidth / 2 ) Y: scFlashXOrigin ]
            forKey: @"inputCenter" ];
      [ gameOverFilter setValue: [ CIVector vectorWithX: 0 Y: 0 Z: gSMSViewWidth W: gSMSViewHeight ]
            forKey: @"inputExtent" ];
      [ gameOverFilter setValue: [ CIColor colorWithRed: 255 green: 204 blue: 153 ]
            forKey: @"inputColor" ];
      [ gameOverFilter retain ];
   }
   
   return self;
}

- ( void ) dealloc
{
   [ backgroundImage release ];
   [ gameOverFilter release ];
   [ offscreenImage release ];
   
   [ super dealloc ];
}


#pragma mark actions

- ( void ) drawTitleViewOffscreen
{
   drawTitle = YES;

   [ NSGraphicsContext saveGraphicsState ];
   [ NSGraphicsContext setCurrentContext: [ NSGraphicsContext
         graphicsContextWithBitmapImageRep: offscreenImage ]];
   [ self drawBackground ];
   [ NSGraphicsContext restoreGraphicsState ];

   [ self setNeedsDisplay: YES ];
}

// This is invoked by the application delegate based on a timer firing.
- ( void ) updateOffscreenImage : ( NSArray* ) newSprites
{
   drawTitle = NO;
   
   sprites = newSprites;
   
   [ NSGraphicsContext saveGraphicsState ];
   [ NSGraphicsContext setCurrentContext: [ NSGraphicsContext
         graphicsContextWithBitmapImageRep: offscreenImage ]];
   
   [ self drawBackground ];
   
   // Ask each sprite for its image to be drawn to the offscreen buffer.
   unsigned spriteIndex;
   for( spriteIndex = 0; spriteIndex < [ sprites count ]; spriteIndex++ )
   {
      Sprite* sprite = [ sprites objectAtIndex: spriteIndex ];
      if( [ sprite image ] != nil )
      {
         [[ sprite image ] drawInRect: [ sprite rect ] fromRect: NSZeroRect
               operation: NSCompositeSourceOver fraction: [ sprite visibility ]];
      }
   }
   
   [ NSGraphicsContext restoreGraphicsState ];
}


#pragma mark accessors

- ( void ) setGameOver : ( BOOL ) gameNowOver;
{
   gameOver = gameNowOver;
   gameOverFilterTime = 0.0;
}


#pragma mark overrides

- ( void ) drawRect : ( NSRect ) rect
{
   CGRect cg = CGRectMake(NSMinX(rect), NSMinY(rect), NSWidth(rect), NSHeight(rect));
   
   CIContext* context = [[ NSGraphicsContext currentContext ] CIContext ];
   
   // The Core Image image is initialized based on the offscreen buffer on which all Core
   //    Graphics drawing has already been done.
   CIImage* image = [[ CIImage alloc ] initWithBitmapImageRep: offscreenImage ];
   CIImage* resultImage = image;
   
   if( context != nil )
   {
      // If we are not drawing the title screen (i.e., if we are playing the game).
      if( drawTitle == NO )
      {
         // If the game has not recently ended (i.e., if we are not displaying the game over
         //    transition ).
         if( gameOver == NO )
         {
            // Ask each sprite to apply its image filter.
            unsigned spriteIndex;
            for( spriteIndex = 0; spriteIndex < [ sprites count ]; spriteIndex++ )
            {
               resultImage = [[ sprites objectAtIndex: spriteIndex ] filteredImage: resultImage ];
            }
         }
         else
         {
            // If the game over transition has completed, stop the game.
            if( gameOverFilterTime > 1.0 )
            {
               gameOver = NO;
               [[ NSApp delegate ] stopGame: self ];
            }
            else
            {
               [ gameOverFilter setValue: resultImage forKey: @"inputImage" ];
               [ gameOverFilter setValue: [ self generateTitleImage ] forKey: @"inputTargetImage" ];
               [ gameOverFilter setValue: [ NSNumber numberWithFloat: gameOverFilterTime ]
                     forKey: @"inputTime" ];
               
               resultImage = [ gameOverFilter valueForKey: @"outputImage" ];
               
               gameOverFilterTime += scGameOverTransitionIncrement;
            }
         }
      }
      
      if( drawTitle == YES )
      {
         CIFilter* compositeFilter = [ CIFilter filterWithName: @"CISourceOverCompositing"
            keysAndValues: @"inputImage", [ self generateTitleImage ],
            @"inputBackgroundImage", resultImage, nil ];
         
         resultImage = [ compositeFilter valueForKey: @"outputImage" ];
      }
      
      [ context drawImage: resultImage atPoint: cg.origin fromRect: cg ];
   }
   
   [ image release ];
}


#pragma mark private

- ( void ) drawBackground
{
   NSPoint point = { 0, 0 };
   [ backgroundImage drawAtPoint: point fromRect: gSMSViewRect operation: NSCompositeCopy
         fraction: 1.0 ];
}

- ( CIImage* ) generateTitleImage
{
   NSURL* url = [ NSURL fileURLWithPath: [[ NSBundle mainBundle ]
         pathForResource: @"title" ofType: @"gif" ]];
   CIImage* titleImage = [[ CIImage alloc ] initWithContentsOfURL: url ];
   
   // Apply the bloom filter to the title.
   CIFilter* bloomFilter = [ CIFilter filterWithName: @"CIBloom"
         keysAndValues: @"inputImage", titleImage,
         @"inputRadius", [ NSNumber numberWithFloat: 10.0 ],
         @"inputIntensity", [ NSNumber numberWithFloat: 1.0 ],
         nil ];
   
   [ titleImage release ];
   
   return [ bloomFilter valueForKey: @"outputImage" ];
}


#pragma mark protocols

- ( BOOL ) acceptsFirstResponder
{
   return YES;
}

- ( BOOL ) resignFirstResponder
{
   return YES;
}

- ( BOOL ) becomeFirstResponder
{
   return YES;
}

// Capture the keys used to play the game
- ( void ) keyDown : ( NSEvent* ) event
{
   SpaceDefenderDelegate* appDelegate = [ NSApp delegate ];
   
   if( [ event keyCode ] == 0x7B /* left arrow */ )
   {
      [ appDelegate moveLeft: self ];
   }
   else if( [ event keyCode ] == 0x7C /* right arrow */ )
   {
      [ appDelegate moveRight: self ];
   }
   else if([ event keyCode ] == 0x31 /* space */ )
   {
      [ appDelegate fire: self ];
   }
}


@end
