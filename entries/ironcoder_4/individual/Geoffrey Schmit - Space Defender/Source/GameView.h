//
//  GameView.h
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 27/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface GameView : NSView
{
   // All Core Graphics drawing is done to an offscreen image which will be converted to a Core
   //    Image before the Core Image filters are applied.
   NSBitmapImageRep* offscreenImage;
   
   // The static background image.
   NSImage* backgroundImage;
   
   // The array of sprites for the next frame to be displayed.
   NSArray* sprites;
   
   CIFilter* gameOverFilter;
   float gameOverFilterTime;
   BOOL gameOver;
   
   BOOL drawTitle;
}

- ( void ) drawTitleViewOffscreen;
- ( void ) updateOffscreenImage : ( NSArray* ) sprites;
- ( void ) setGameOver : ( BOOL ) gameNowOver;


@end
