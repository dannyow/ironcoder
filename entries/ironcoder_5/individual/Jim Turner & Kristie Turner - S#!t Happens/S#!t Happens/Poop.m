//
//  Poop.m
//  IronCoderV
//
//  Created by Jim and Kristie Turner on 3/31/07.
//  Please see the LICENSE.txt file for license information
//

#import "Poop.h"


@implementation Poop

- (id)initWithFrame:(NSRect)frame 
{
    if( self = [super initWithFrame:frame] )
	{
		poopFalling = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"poopFalling.png"]];
		poopPile    = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:@"poopPile.png"]];

		if( !poopFalling || !poopPile )
		{
			NSLog( @"Shit! no shit!!" );
			return( nil );
		}
		else
		{
			[poopFalling retain];
			[poopPile retain];
			
			poopKlingonAmountToShow = 0;
			poopIsStillAKlingon = YES;
			poopHitBottom       = NO;
			poopDetachedTooLow  = NO;
			flowerGrowing       = NO;
			flowerDying         = NO;
			tickCounter         = 0;
			poopToFlowerTimer   = nil;
		}
    }
	else
	{
		NSLog( @"failed to init poop" );
	}

    return self;
}

-(void) dealloc
{
	[poopFalling release];
	[poopPile release];
	
	[super dealloc];
}

-(void) performUpdate
{	
	tickCounter++;

	// Setup the timer to switch the poop from a pile to a flower if the poop hit the bottom
	// and the timer isn't already valid
	// The timer isn't a repeating one as I was seeing some very odd animation happening (flowers
	// showing up out of order, poop piles coming back to life, etc) when it was.  I'm not entirely
	// sure, but I gotta think it's something to do with the ScreenSaverView's animation loop and 
	// creating another timer inside of it.  I'd look into it more, but I'm running out of time:)
//	if( poopHitBottom && ![poopToFlowerTimer isValid] )
	if( poopHitBottom && (poopToFlowerTimer == nil) )
	{
		poopToFlowerTimer = [NSTimer scheduledTimerWithTimeInterval:SSRandomFloatBetween( 1.0, 3.0 )
															 target:self 
														   selector:@selector(changePoopPile:) 
														   userInfo:nil 
															repeats:NO];
	}

	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	// At what point are we at in the animation?  Do we care about mouse locations anymore?
	if( poopIsStillAKlingon )
	{
		// If we're still a-klingon, track with the mouse
		[self setFrameOrigin:NSMakePoint(([NSEvent mouseLocation].x - (POOPWIDTH / 2)), ([NSEvent mouseLocation].y - (POOPHEIGHT+MOUSECURSORHEIGHT)))];
	}
	else
	{
		if( !poopHitBottom )
		{		
			// We need to fall to the bottom of the screen
			[self setFrameOrigin:NSMakePoint( fallingPoopOrigin.x, fallingPoopOrigin.y - 9 )];
		
			// Have we met the bottom of the screen's visible frame?
			NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];

			// Wait, did we detach with part of us below the screen frame?  Let's just 
			// animate ourselves out of view and not create a pile.
			if( fallingPoopOrigin.y < visibleFrame.origin.x )
			{
				poopDetachedTooLow = YES;
			}

			// We just met the bottom (and we're not already below it!  YAY!)
			if( ([self frame].origin.y <= visibleFrame.origin.x) && !poopDetachedTooLow )
			{
				poopHitBottom = YES;
				
				[self setFrameSize:NSMakeSize( POOPPILEWIDTH, POOPPILEHEIGHT )];
			}

			if( poopDetachedTooLow )
			{
				// Why the weird math?  Because we want the poop to be offscreen before we remove it
				// but the OS will stop animating the view before it + the height of the graphic are completely
				// below visibleFrame.origin.x because its no longer seen.  Damn efficient drawing system.
				// We'll fudge it enough so that the view will get removed in almost every situation.
				if( (fallingPoopOrigin.y + (POOPHEIGHT - 15)) < visibleFrame.origin.x )
				{
					[self removeFromSuperview];
				}
			}
		}

		if( poopHitBottom )
		{
			[self setFrameSize:[poopPile size]];
		}
	}

	// Even though we might still be attached, keep track of where we're at so when we do "detach", we don't 
	// jump to where we started our initial animation from.
	fallingPoopOrigin = [self frame].origin;


	if( poopKlingonAmountToShow < POOPHEIGHT )
	{
		// Stupid documentation... compositeToPoint: doesn't take into account the graphic's alpha channel.  So overlapping images
		// would clip each other.  dissolveToPoint: calculates the alpha value, so no more clipping!  Huzzah!
		[poopFalling dissolveToPoint:NSMakePoint(0.0, POOPHEIGHT-poopKlingonAmountToShow) fromRect:NSMakeRect(0,0,POOPWIDTH,++poopKlingonAmountToShow) fraction:1.0];
	}
	else
	{
		if( !poopHitBottom )
		{
			[poopFalling dissolveToPoint:NSZeroPoint fraction:1.0];
			poopIsStillAKlingon = NO;
		}
		else
		{
			[poopPile dissolveToPoint:NSZeroPoint fraction:1.0];
		}
	}
}

// This is ugly, but it's the best I could do.
-(void) changePoopPile:(NSTimer *)timer
{
	if( [[poopPile name] isEqualToString:@"poopPile_2"] )
	{
		// We're done.
		[poopToFlowerTimer invalidate];
		[self removeFromSuperview];
		
		return;
	}

	NSArray *whichGraphic = [[poopPile name] componentsSeparatedByString:@"_"];

	int number = 0;
	number = [[whichGraphic objectAtIndex:1] intValue];
	NSString *nextGraphic;
	
	if( number == 4 )
	{
		if( [[whichGraphic objectAtIndex:0] isEqualToString:@"flower"] )
		{
			// Need to start dying
			nextGraphic = @"dead_1";
		}
		else
		{
			// Need to decompose
			nextGraphic = @"poopPile_2";
		}
	}
	else
	{
		nextGraphic = [NSString stringWithFormat:@"%@_%d", ([whichGraphic objectAtIndex:0]) ? [whichGraphic objectAtIndex:0] : @"flower", ++number];
	}
	
	[poopPile release];
	
	poopPile = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForImageResource:[nextGraphic stringByAppendingPathExtension:@"png"]]];
	if( !poopPile )
	{
		// A bad thing happened
	}
	[poopPile setName:nextGraphic];

	poopToFlowerTimer = nil;
}

@end
