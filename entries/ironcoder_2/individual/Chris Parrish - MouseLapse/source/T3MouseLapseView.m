//
//  T3MouseLapseView.m
//  MouseLapse
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import "T3MouseLapseView.h"
#import "T3MouseLapseUtility.h"
#import "T3RadialShader.h"
#import "T3CategoryNSGraphicsContext.h"

const	float		kNaturalRadius			=	5.0;

@interface T3MouseLapseView ( PrivateMethods )

- (void) updatePoints;

@end

#pragma mark -


@implementation T3MouseLapseView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
	
    if (self)
	{
		fFillRed		=	1.0;
		fFillBlue		=	0.5;
		fFillGreen		=	0.0;
		
		fNumberOfMarkers	=	-1;
		
		fMouseHasMoved		=	YES;
		fCurrentRadius		=	kNaturalRadius;
		
		fMarkers			=	nil;
		
		[ self setNumberOfMarkers: 10 ];
		
		[ self updateWithMousePosition:[ NSEvent mouseLocation ] ];
		
		// TODO :
		//    does not account for multiple displays
		//    will be incorrect if screen resolution is changed after we are initialized
		//    would be better to grab it as need or register for notifications of resolution change
		
		fScreenRect = [ [ NSScreen mainScreen ] frame ];
		
		fRadialShader = [ [ T3RadialShader sphericalRadialShader ] retain ];
    }
	
    return self;
}

- (void) dealloc
{
	[ fRadialShader release ];
	
	if ( fMarkers )
		free( fMarkers );
	
	[super dealloc];
}

#pragma mark -

- (void) setNumberOfMarkers:(int) count
{
	if ( count == fNumberOfMarkers )
		return;
	
	fNumberOfMarkers = count;
	
	if ( fMarkers )
		free( fMarkers );
		
	fMarkers = malloc( sizeof( T3MouseMarker[ fNumberOfMarkers ] ) );

	int i;
	for  ( i = 0; i < fNumberOfMarkers; i++ )
	{
		T3MouseMarker marker = { fCurrentMouse, kNaturalRadius, 1.0 };
		fMarkers[ i ] = marker;
	}		
}


#pragma mark -

- (void)drawRect:(NSRect)rect
{
	//----- CG for teh win !
	
	NSGraphicsContext*	context		= [ NSGraphicsContext currentContext ];
	CGContextRef		coreContext	= [ context coreGraphicsContext ];
	
	CGContextSetRGBFillColor( coreContext, fFillRed, fFillBlue, fFillGreen,  1.0 );
	
	CGContextFillRect( coreContext, CGRectMakeFromNSRect( &rect ) );
	
	NSRect viewBounds = [ self bounds ];
		
	// translate to draw the sphere centered at the point in our view relative to the
	// unit coordiante we stashed for the location
	// if location is at (0.5, 0.5), we will draw at the center of our view
	
	NSPoint		currentPoint;
	float		currentRadius;
	float		currentAlpha;
	
	float		x;
	float		y;

	NSRect sphereRect;
		
	int i;	
	for ( i = fNumberOfMarkers - 1; i >= 0; i-- )
	{
		currentPoint	= fMarkers[ i ].location;
		currentRadius	= fMarkers[ i ].radius;
		currentAlpha	= fMarkers[ i ].alpha;		
		x				=	( ( currentPoint.x * viewBounds.size.width ) - ( currentRadius  / 2.0 ) );
		y				=	( ( currentPoint.y * viewBounds.size.height ) - ( currentRadius / 2.0 ) );

		sphereRect		= NSMakeRect( x , y , currentRadius, currentRadius );

		CGContextSetAlpha( coreContext, currentAlpha );
		
		[ fRadialShader paintShader:context inRect:sphereRect ];
	}
}

- (void) updateWithMousePosition:(NSPoint) position
{
	fFillRed		=	position.y / fScreenRect.size.height;
	fFillBlue		=	position.x / fScreenRect.size.width;
	
	float	x		=	( position.x / fScreenRect.size.width );
	float	y		=	( position.y / fScreenRect.size.height );

	NSPoint	newPoint	=	NSMakePoint( x, y );
	
	if ( NSEqualPoints(newPoint,fCurrentMouse) )
	{
		fMouseHasMoved = NO;
	}
	else
	{
		fMouseHasMoved = YES;
	}
	
	fCurrentMouse		=	newPoint;
	
	if ( fMouseHasMoved )
	{
		fCurrentRadius -= 1.0;
		
		if ( fCurrentRadius < kNaturalRadius )
			fCurrentRadius = kNaturalRadius;			
	}
	else 
	{
		fCurrentRadius += 1.0;
		
		if ( fCurrentRadius > 23.0 )
		{
			fCurrentRadius = 20.0;
		}
	}
	
	[ self updatePoints ];
	
	[ self setNeedsDisplay:YES ];
}

@end

#pragma mark -

@implementation T3MouseLapseView ( PrivateMethods )

- (void) updatePoints
{
	float alphaStep = 1.0 / fNumberOfMarkers;

	int i;	
	for ( i = fNumberOfMarkers - 1; i > 0; i-- )
	{
		fMarkers[ i ]			=	fMarkers[ i - 1 ];
		fMarkers[ i ].alpha		-=	alphaStep;
		fMarkers[ i ].radius	-=  1.0;
		if ( fMarkers[ i ].radius < kNaturalRadius )
		{
			fMarkers[ i ].radius = kNaturalRadius;
		}
	} 
	
	fMarkers[ 0 ].location	=	fCurrentMouse;
	fMarkers[ 0 ].radius	=	fCurrentRadius;
	fMarkers[ 0 ].alpha		=	1.0;
	
}

@end
