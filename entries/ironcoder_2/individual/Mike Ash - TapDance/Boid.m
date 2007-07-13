//
//  Boid.m
//  TapDance
//
//  Created by Michael Ash on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "Boid.h"


@interface BoidView : NSView {
	NSImage*	mImage;
	NSPoint		mOffset;
}
- initWithFrame: (NSRect)frame image: (NSImage *)image offset: (NSPoint)offset;
@end
@implementation BoidView
- initWithFrame: (NSRect)frame image: (NSImage *)image offset: (NSPoint)offset
{
	if( ( self = [self initWithFrame: frame] ) )
	{
		mImage = [image retain];
		mOffset = offset;
	}
	return self;
}

- (void)dealloc
{
	[mImage release];
	
	[super dealloc];
}

- (void)drawRect: (NSRect)rect
{
	NSRect fromRect = { NSZeroPoint, [mImage size] };
	[mImage drawAtPoint: NSMakePoint( -mOffset.x, -mOffset.y ) fromRect: fromRect operation: NSCompositeSourceOver fraction: 1.0];
}

@end

@implementation Boid

static NSMutableArray *gBoids = nil;

+ (void)initialize
{
	srandomdev();
}

- initWithWindow: (NSWindow *)window image: (NSImage *)image offset: (NSPoint)offset origin: (NSPoint)origin size: (NSSize)size
{
	if( ( self = [super init] ) )
	{
		mParentWin = window;
		mPos = origin;
		mVx = random() / (float)0x7fffffff * 8 - 4;
		mVy = random() / (float)0x7fffffff * 8 - 4;
		
		NSRect rect = { origin, size };
		mWin = [[NSWindow alloc] initWithContentRect: rect styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered defer: NO];
		
		rect.origin = NSZeroPoint;
		BoidView *view = [[BoidView alloc] initWithFrame: rect image: image offset: offset];
		[mWin setContentView: view];
		[view release];
		
		[mWin setHasShadow: YES];
		[mWin orderFront: nil];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (NSWindow *)window
{
	return mParentWin;
}

- (void)step
{
	float centerx = 0;
	float centery = 0;
	float avoidx = 0;
	float avoidy = 0;
	float matchx = 0;
	float matchy = 0;
	
	float optimalDistance = MAX( [mWin frame].size.width, [mWin frame].size.height );
	
	unsigned i;
	unsigned count = [gBoids count];
	for( i = 0; i < count; i++ )
	{
		Boid *boid = [gBoids objectAtIndex: i];
		if( boid == self )
			continue;
		
		NSPoint pos = [boid pos];
		centerx += pos.x;
		centery += pos.y;
		
		float dx = pos.x - mPos.x;
		float dy = pos.y - mPos.y;
		float r2 = dx * dx + dy * dy;
		if( sqrtf( r2 ) < optimalDistance )
		{
			//float m = 1.0 / (MAX( r2, 1.0 ));
			float m = 1;
			avoidx -= dx * m;
			avoidy -= dy * m;
		}
		
		matchx += [boid vx];
		matchy += [boid vy];
	}
	
	centerx /= (count - 1);
	centery /= (count - 1);
	centerx -= mPos.x;
	centery -= mPos.y;
	centerx /= 1000;
	centery /= 1000;
	matchx /= (count - 1) * 80;
	matchy /= (count - 1) * 80;
	
	mVx += (centerx + avoidx + matchx) / 10;
	mVy += (centery + avoidy + matchy) / 10;
	
	NSSize winSize = [mWin frame].size;
	NSArray *screens = [NSScreen screens];
	count = [screens count];
	NSRect screenRect = [[screens objectAtIndex: 0] frame];
	for( i = 1; i < count; i++ )
		screenRect = NSUnionRect( screenRect, [[screens objectAtIndex: i] frame] );
	screenRect = NSOffsetRect( screenRect, -winSize.width / 2.0, winSize.height / 2.0 );
	screenRect = NSInsetRect( screenRect, winSize.width, winSize.height );
	if( mPos.x < NSMinX( screenRect ) )
		mVx += 1;
	if( mPos.x > NSMaxX( screenRect ) )
		mVx -= 1;
	if( mPos.y < NSMinY( screenRect ) )
		mVy += 1;
	if( mPos.y > NSMaxY( screenRect ) )
		mVy -= 1;
	
	mVx = MIN( mVx, 4.0 );
	mVx = MAX( mVx, -4.0 );
	mVy = MIN( mVy, 4.0 );
	mVy = MAX( mVy, -4.0 );
	mPos.x += mVx;
	mPos.y += mVy;
	
	[mWin setFrameOrigin: mPos];
}

- (void)hide
{
	[mWin orderOut: nil];
}

- (NSPoint)pos
{
	return mPos;
}

- (float)vx
{
	return mVx;
}

- (float)vy
{
	return mVy;
}

@end

@implementation NSWindow (Boids)

static const int kNumBoidsSqrt = 6;

static NSTimer *gBoidTimer = nil;

+ (void)_stepBoids: (NSTimer *)timer
{
	if( [gBoids count] == 0 )
	{
		[gBoidTimer invalidate];
		[gBoidTimer release];
		gBoidTimer = nil;
	}
	else
	{
		NSDisableScreenUpdates();
		[gBoids makeObjectsPerformSelector: @selector( step )];
		NSEnableScreenUpdates();
	}
}

+ (BOOL)hasBoids
{
	return [gBoids count] > 0;
}

- (void)boidify
{
	if( ![self isVisible] )
		return;
	
	if( !gBoids )
		gBoids = [[NSMutableArray alloc] init];
	
	NSRect rect = { NSZeroPoint, [self frame].size };
	NSImage *image = [[NSImage alloc] initWithData: [self dataWithPDFInsideRect: rect]];
	
	float width = rintf( [self frame].size.width / kNumBoidsSqrt );
	float height = rintf( [self frame].size.height / kNumBoidsSqrt );
	
	NSPoint origin = [self frame].origin;
	
	int x, y;
	for( y = 0; y < kNumBoidsSqrt; y++ )
	{
		for( x = 0; x < kNumBoidsSqrt; x++ )
		{
			Boid *boid = [[Boid alloc] initWithWindow: self image: image offset: NSMakePoint( x * width, y * height ) origin: NSMakePoint( origin.x + x * width, origin.y + y * height ) size: NSMakeSize( width, height)];
			[gBoids addObject: boid];
			[boid release];
		}
	}
	
	[self orderOut: nil];
	
	if( !gBoidTimer )
		gBoidTimer = [[NSTimer scheduledTimerWithTimeInterval: 1.0/60.0 target: [self class] selector: @selector( _stepBoids: ) userInfo: nil repeats: YES] retain];
}

- (void)deboidify
{
	BOOL hasBoids = NO;
	
	unsigned i;
	unsigned count = [gBoids count];
	for( i = 0; i < count; i++ )
	{
		Boid *boid = [gBoids objectAtIndex: i];
		if( self == [boid window] )
		{
			[boid hide];
			[gBoids removeObjectAtIndex: i];
			i--;
			count--;
			
			hasBoids = YES;
		}
	}
	
	if( hasBoids )
		[self orderFront: nil];
}

@end
