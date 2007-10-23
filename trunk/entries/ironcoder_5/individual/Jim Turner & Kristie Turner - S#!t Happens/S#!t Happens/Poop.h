//
//  Poop.h
//  IronCoderV
//
//  Created by Jim and Krisie Turner on 3/31/07.
//  Please see the LICENSE.txt file for license information
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>

#define MOUSECURSORHEIGHT 10.0

#define POOPWIDTH 75.0
#define POOPHEIGHT 160.0

#define POOPPILEWIDTH 118.0
#define POOPPILEHEIGHT 264.0

@interface Poop : NSView 
{
	NSImage *poopFalling;
	NSImage *poopPile;
	
	BOOL poopIsStillAKlingon;
	BOOL poopHitBottom;
	BOOL poopDetachedTooLow;
	BOOL flowerGrowing;
	BOOL flowerDying;
	
	int poopKlingonAmountToShow;
	NSPoint fallingPoopOrigin;
	
	NSTimer *poopToFlowerTimer;
	unsigned int tickCounter;
}

-(void) performUpdate;

@end
