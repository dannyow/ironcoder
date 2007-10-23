//
//  SSView.m
//  IronCoderV
//
//  Created by Jim and Krisie Turner on 3/30/07.
//  Please see the LICENSE.txt file for license information
//

#import "SSView.h"
#import "Poop.h"

@implementation SSView

-(id)initWithFrame:(NSRect)rect isPreview:(BOOL)isBool
{	
	if( self = [super initWithFrame:rect isPreview:isBool] )
	{
		poopInPlay = [NSMutableArray new];
		iNeedANewPoop = NO;
	}
		
	return( self );
}

-(void)animateOneFrame
{
	NSEnumerator *poopEnum = [[self subviews] objectEnumerator];
	Poop *obj;
	
	while( obj = [poopEnum nextObject] )
	{
		[obj performUpdate];
	}

	if( iNeedANewPoop )
	{
		iNeedANewPoop = NO;
		
		NSRect newRect = NSMakeRect(([NSEvent mouseLocation].x - (POOPWIDTH/ 2)),([NSEvent mouseLocation].y - MOUSECURSORHEIGHT), POOPWIDTH, POOPHEIGHT );

		Poop *p = [[Poop alloc] initWithFrame:newRect];
		[self addSubview:p];

		[p release];
	}
}

-(void) createANewPoop
{
	iNeedANewPoop = YES;
}


-(void)drawRect:(NSRect)aRect
{
//	NSLog( @"SSView's drawRect fired???" );
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}


@end
