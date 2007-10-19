//
//  Controller.m
//  IronCoderV
//
//  Created by Jim and Krisie Turner on 3/30/07.
//  Please see the LICENSE.txt file for license information
//

#import "Controller.h"
#import "SSView.h"

@implementation Controller

-(id) init
{
	if( self = [super init] )
	{
		fart1 = [[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fart1" ofType:@"wav"] byReference:NO] retain];
		fart2 = [[[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"naughty_child" ofType:@"wav"] byReference:NO] retain];
	}

	return( self );
}

-(void) dealloc
{
	[fart1 release];
	[fart2 release];
	
	[super dealloc];
}

-(void) awakeFromNib
{
	srandomdev();
	[theView startAnimation];
	
	// Take a crap right away which will setup the timer
	[self takeADump:nil];
}

// Separate so that we can create a poop from the GUI if we want
-(IBAction)createPoop:(id)sender
{
	[fart1 play];
	[theView createANewPoop];
}

-(void)takeADump:(id)sender
{
	float newRandom = SSRandomFloatBetween(5.0, 30.0);
	
	// Lemmie dazzle you with my logic here...
	if( (newRandom > 10.0) && (newRandom < 20.0) )
	{
		[fart2 play];
	}
	else
	{
		[fart1 play];
	}
	
	[theView createANewPoop];

	genPoopTimer = [NSTimer scheduledTimerWithTimeInterval:SSRandomFloatBetween(5.0, 30.0) 
													target:self 
												  selector:@selector(takeADump:) 
												  userInfo:nil 
												   repeats:NO];
}


@end
