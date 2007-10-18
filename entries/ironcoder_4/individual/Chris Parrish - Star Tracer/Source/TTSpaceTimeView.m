//
//  TTSpaceTimeView.m
//  SpaceTime
//
//  Created by 23 on 10/27/06.
//  Copyright 2006 23. All rights reserved.
//

#import "TTSpaceTimeView.h"
#import "TTCategoryNSColor.h"
#import "TTCIFilterAnimation.h"

//----- constants

const	unsigned int	kDefaultStarCount	=	10;

const	int				kStarRadiusCount	=	5;
const	float			kCrossScale			=	50.0;
const	float			kCrossOpacity		=	-8.0;
const	float			kCrossWidth			=	3.0;
const	float			kEpsilon			=	-1.0;

const	float			kStarImageWidth		=	200.0;
const	float			kStarImageHeight	=	200.0;

const	float			kHighightRadius			=	3.0;
const	float			kHighlightCrossScale	=	16.0;
const	float			kHighlightCrossOpacity	=	0.0;
const	float			kHighlightCrossWidth	=	0.6;
const	float			kHightlightEpsilon		=	-0.02;

const	float			kConstellationPathWidth	=	3.0;

//----- private

@interface TTSpaceTimeView ( PrivateMethods )

- (void) distributeStars;
- (void) drawTransition;
- (void) drawStarField;
- (void) drawConstellation;
- (CIImage*) starFilterResult:(NSArray*)filters;
- (void) drawStarFilterResults:(NSArray*)filters;
- (void) drawConstellationPath;
- (void) addConstellationPoint:(NSPoint)location;
- (void) animateStar:(CIFilter*)star;
- (void) animateConstellationReset;
- (void) startNewConstellationPath;

@end


@implementation TTSpaceTimeView

- (id)initWithFrame:(NSRect)frame
{
    self = [ super initWithFrame:frame ];
    if (self)
	{		
		//----- set up the star shine filter
		
		_starShineFilter = [ [ CIFilter filterWithName:@"CIStarShineGenerator" ] retain ];
		[ _starShineFilter setDefaults ];
		
		NSDictionary* initialAttributes =
			[ NSDictionary dictionaryWithObjectsAndKeys:
				[ NSNumber numberWithFloat:kCrossScale ], @"inputCrossScale",
				[ NSNumber numberWithFloat:kCrossOpacity ], @"inputCrossOpacity",
				[ NSNumber numberWithFloat:kCrossWidth ], @"inputCrossWidth",
				[ NSNumber numberWithFloat:kEpsilon], @"inputEpsilon",
				[ NSNumber numberWithFloat:2.0], @"inputRadius",
				[ CIVector vectorWithX:( kStarImageWidth / 2.0 ) Y:( kStarImageHeight / 2.0 ) ], @"inputCenter",
				nil ];

		[ _starShineFilter setValuesForKeysWithDictionary:initialAttributes ];

		//----- setup an attributes dictionary for constellation star filters
		
		_constellationStarAttributes =
			[ [ NSDictionary dictionaryWithObjectsAndKeys:
				[ NSNumber numberWithFloat:kHighlightCrossScale ], @"inputCrossScale",
				[ NSNumber numberWithFloat:kHighlightCrossOpacity ], @"inputCrossOpacity",
				[ NSNumber numberWithFloat:kHighlightCrossWidth ], @"inputCrossWidth",
				[ NSNumber numberWithFloat:kHightlightEpsilon], @"inputEpsilon",
				[ NSNumber numberWithFloat:kHighightRadius], @"inputRadius",
				[ CIVector vectorWithX:( kStarImageWidth / 2.0 ) Y:( kStarImageHeight / 2.0 ) ], @"inputCenter",
				nil ] retain ];
		
		//----- create a weighted star radius probability, favor smaller radius		
		
		_radiusProbability = malloc( sizeof(float) * kStarRadiusCount );
		
		_radiusProbability[ 0 ] = 0.5;
		_radiusProbability[ 1 ] = 0.92;
		_radiusProbability[ 2 ] = 0.95;
		_radiusProbability[ 3 ] = 0.98;
		_radiusProbability[ 4 ] = 0.99;
		
		//----- setup the constellation path
		
		[ self startNewConstellationPath ];
		
		_constellationColor = [ [ [ NSColor grayColor ] colorWithAlphaComponent:0.5 ] retain ];
		
		//----- Distribute a field of stars across frame
		
		_starArray = [ [ NSMutableArray arrayWithCapacity:kDefaultStarCount ] retain];
		[ self distributeStars:kDefaultStarCount ];
		
		_constellationPoints = [ [ NSMutableArray arrayWithCapacity:10 ] retain];
	
		//----- load the default shading image
		
		NSBundle* classBundle = [ NSBundle bundleForClass:[ self class ] ];
		NSString* filePath = [ classBundle pathForImageResource:@"Default_Shading.tif" ];
		NSURL* shadingURL = [ NSURL fileURLWithPath:filePath ];
		
		_shadingImage = [ [ CIImage imageWithContentsOfURL:shadingURL ] retain ];
		
		_drawStarField = YES;
		_drawConstellation = YES;
	}
	
    return self;
}

- (void) dealloc
{
	[ _starArray release ];
	[ _starShineFilter release ];
	[ _constellationStarAttributes release ];
	[ _currentPath release ];
	[ _constellationPaths release ];
	[ _constellationColor release ];
	[ _shadingImage release ];
	
	if ( _radiusProbability )
		free ( _radiusProbability );
		
	[ super dealloc ];
}

#pragma mark NSControl

- (BOOL) acceptsFirstResponder
{
	return YES;
}

#pragma mark Background

- (void) distributeStars:(unsigned int)numberOfStars;
{
	sranddev();
	
	NSRect bounds = [ self bounds ];
	
	const	float	xMin	=	0.0;
	const	float	yMin	=	0.0;
	const	float	xMax	=	NSMaxX( bounds );
	const	float	yMax	=	NSMaxY( bounds );
	
	float	x		= 0.0;
	float	y		= 0.0;
	int		radius	= 0;
	
	float	radiusProbabilty = 0.0;
	
	CIColor*	starColor = nil;
	
	int i = 0;
	
	[ _starArray removeAllObjects ];
		
	for ( i = 0; i < numberOfStars; i++ )
	{
		x = xMin + ( ( ( xMax - xMin ) * rand() )  / (float)RAND_MAX ); 
		y = yMin + ( ( ( yMax - yMin ) * rand() ) / (float)RAND_MAX );
		
		radiusProbabilty =  rand() / (float)RAND_MAX; 

		radius = kStarRadiusCount;
		while ( radius > 0 )
		{
			if ( radiusProbabilty >= _radiusProbability[ radius - 1 ] )
				break;
			
			radius--;
		}
	
		starColor = [ [ NSColor randomStarColor ] coreImageColor ];
		
		[ _starShineFilter setValue:[ CIVector vectorWithX:x Y:y ]  forKey:@"inputCenter" ];
		[ _starShineFilter setValue:[ NSNumber numberWithInt:( radius + 1 ) ] forKey:@"inputRadius" ];
		[ _starShineFilter setValue:starColor forKey:@"inputColor" ];
		[ _starArray  addObject:[ _starShineFilter copy ] ];
	}
	
	[ _starFieldImage release ];
	_starFieldImage = [ [ self starFilterResult:_starArray ] retain ];
	
	[ self setNeedsDisplay:YES ];
}

#pragma mark Constellation

- (void) resetConstellation
{
	[ self animateConstellationReset ];

	[ _constellationPaths removeAllObjects ];
	[ _constellationPoints removeAllObjects ];
	[ self startNewConstellationPath ];
	
	[ self setNeedsDisplay:YES ];
}

- (void) startNewConstellationPath
{
	if ( _constellationPaths == nil )
	{
		_constellationPaths = [ [ NSMutableArray arrayWithCapacity:3 ] retain ];		
	}
	
	_currentPath = [ NSBezierPath bezierPath ];
	[ _currentPath setLineWidth:kConstellationPathWidth ];

	[ _constellationPaths addObject:_currentPath ];
}


#pragma mark Drawing

- (void)drawRect:(NSRect)rect
{
	// Draw the whole bounds for now, optimize to the dirty rect later if time

	//----- if a transition is in progress, we draw that instead of our normal content
	
	if ( _transitionFilter != nil )
	{
		[ self drawTransition ];
		return;
	}
	
	[ [ NSColor blackColor ] set ];

	[ NSBezierPath fillRect:[ self bounds ] ];

	[ self drawStarField ];
	
	[ self drawConstellation ];
}

- (void) drawTransition
{
	CIContext* context = [ [ NSGraphicsContext currentContext ] CIContext ];
	
	NSRect bounds = [ self bounds ];
	CGRect sourceRect = *(CGRect*)&bounds;
	CIImage* transitionImage = [ _transitionFilter valueForKey:@"outputImage" ];
	
	[ context drawImage:transitionImage atPoint:CGPointZero fromRect:sourceRect ];
}

- (void) drawStarField
{
	if ( !_drawStarField )
		return;
		
	CIContext* context = [ [ NSGraphicsContext currentContext ] CIContext ];
	
	NSRect bounds = [ self bounds ];
	CGRect sourceRect = *(CGRect*)&bounds;

	[ context drawImage:_starFieldImage atPoint:CGPointZero fromRect:sourceRect ];	
}

- (void) drawConstellation
{
	if ( !_drawConstellation )
		return;
		
	//----- draw the constellation path
	
	[ self drawConstellationPath ];
	
	//----- draw all the stars in the constellation
	
	[ self drawStarFilterResults:_constellationPoints ];	
}

- (void) drawConstellationPath
{
	[ _constellationColor set ];
	
	NSEnumerator* enumerator = [ _constellationPaths objectEnumerator ];
	NSBezierPath* currentPath = nil;
	
	while ( currentPath = [ enumerator nextObject ] )
	{
		[ currentPath stroke ];
	}

}

- (void) drawStarFilterResults:(NSArray*)filters
{
	CIContext* context = [ [ NSGraphicsContext currentContext ] CIContext ];
   
	CGRect sourceRect = CGRectMake
						(
							0.0,
							0.0,
							kStarImageWidth,
							kStarImageHeight
						);
	CGPoint destPoint = CGPointZero;
	
	CIImage*		starImage = nil;
	CIFilter*		starFilter = nil;
	CIVector*		starCenter = nil;
	
	NSEnumerator*	enumerator = [ filters objectEnumerator ];
	
	while ( starFilter = [ enumerator nextObject ] )
	{
		starCenter = [ starFilter valueForKey:@"inputCenter" ];
		starImage  = [ starFilter valueForKey:@"outputImage" ];
		
		destPoint.x = [ starCenter X ];
		destPoint.y = [ starCenter Y ];
		
		sourceRect.origin.x		=	destPoint.x - ( kStarImageWidth / 2.0 );
		sourceRect.origin.y		=	destPoint.y - ( kStarImageHeight / 2.0 );
	
		destPoint.x -= kStarImageWidth / 2.0;
		destPoint.y -= kStarImageHeight / 2.0;
		
		// it might be faster to draw the star images with source over
		// onto the background and then draw the result of that to the CIContext
		// UPDATE : it takes much longer to composite all the stars
		//          in a source over, but having a single CIImage at the end 
		//          is faster for our lazy updates that draw the whole view
		
		[ context drawImage:starImage atPoint:destPoint fromRect:sourceRect ];
	}
}

- (CIImage*) starFilterResult:(NSArray*)filters
{
	CIImage*		starImage = nil;
	CIImage*		accumulatedImage = nil;
	CIFilter*		starFilter = nil;
	CIFilter*		sourceOverFilter = nil;
	
	NSEnumerator*	enumerator = [ filters objectEnumerator ];
	
	accumulatedImage = [ [ enumerator nextObject ] valueForKey:@"outputImage" ];
	
	while ( starFilter = [ enumerator nextObject ] )
	{
		starImage  = [ starFilter valueForKey:@"outputImage" ];
		
		sourceOverFilter = [ CIFilter filterWithName:@"CISourceOverCompositing"
									   keysAndValues:
									   @"inputImage", starImage,
									   @"inputBackgroundImage", accumulatedImage, nil ];
									   
		accumulatedImage = [ sourceOverFilter valueForKey:@"outputImage" ];
	}
	
	return accumulatedImage;
}

#pragma mark Animation

- (void) animateStar:(CIFilter*)star
{
	//----- do some gratuitous CI animation 
	
	TTCIFilterAnimation* animation =
		[ [ TTCIFilterAnimation alloc ] initWithView:self
		                                      filter:star
											  duration:0.5 ];
	
	[ animation autorelease ];
	
	[ animation animateAttribute:@"inputRadius"
	                  startValue:[ NSNumber numberWithFloat:10.0 ]
					  endValue:[ NSNumber numberWithFloat:kHighightRadius ] ];

	[ animation animateAttribute:@"inputCrossAngle"
	                  startValue:[ NSNumber numberWithFloat:0.0 ]
					  endValue:[ star valueForKey:@"inputCrossAngle" ] ];

	[ animation startAnimation ];	
}

- (void) animateRedistribute:(unsigned int)numberOfStars
{
	//----- create CIImage of current view
	
	[ self lockFocus ];
	
	[ self drawRect:[ self bounds] ];
	
	NSBitmapImageRep* rep = [ [ [ NSBitmapImageRep alloc ] initWithFocusedViewRect:
								[ self bounds ] ] autorelease ];
	
	[ self unlockFocus ];	
	
	CIImage* startImage = [ [ [ CIImage alloc ] initWithBitmapImageRep:rep ] autorelease ];
	
	//------ redistribute
	
	[ self distributeStars:numberOfStars ];
	
	//----- create CIImage with new distribution
	
	[ self lockFocus ];
	
	[ self drawRect:[ self bounds ] ];
	
	rep = [ [ [ NSBitmapImageRep alloc ] initWithFocusedViewRect:
					[ self bounds ] ] autorelease ];
	
	[ self unlockFocus ];	
	
	CIImage* endImage = [ [ [ CIImage alloc ] initWithBitmapImageRep:rep ] autorelease ];
	
	//----- create transition filter	
								
	_transitionFilter = [ [ CIFilter filterWithName:@"CIDissolveTransition" ] retain ];
	[ _transitionFilter setDefaults ];
	[ _transitionFilter setValue:startImage forKey:@"inputImage" ];
	[ _transitionFilter setValue:endImage forKey:@"inputTargetImage" ];

	//----- animate the view
	
	TTCIFilterAnimation* animation =
		[ [ TTCIFilterAnimation alloc ] initWithView:self
		                                      filter:_transitionFilter
											  duration:0.25 ];
	[ animation autorelease ];
	
	[ animation animateAttribute:@"inputTime"
					  startValue:[ NSNumber numberWithFloat:0.0 ] 
					    endValue:[ NSNumber numberWithFloat:1.0 ] ];
	
	[ animation setDelegate:self ];
	[ animation startAnimation ];
}

- (void) animateConstellationReset
{
	//----- do a core image transition to represent erase constellation
	
	//----- create CIImage of current view
	
	_drawStarField = YES;
	_drawConstellation = YES;
	
	[ self lockFocus ];
	
	[ self drawRect:[ self bounds] ];
	
	NSBitmapImageRep* rep = [ [ [ NSBitmapImageRep alloc ] initWithFocusedViewRect:
								[ self bounds ] ] autorelease ];
	
	[ self unlockFocus ];	
	
	CIImage* startImage = [ [ [ CIImage alloc ] initWithBitmapImageRep:rep ] autorelease ];
	
	//----- create CIImage of of backside view
	
	_drawStarField = NO;
	_drawConstellation = YES;
	
	[ self lockFocus ];
	
	[ self drawRect:[ self bounds] ];
	
	rep = [ [ [ NSBitmapImageRep alloc ] initWithFocusedViewRect:
			 [ self bounds ] ] autorelease ];
	
	[ self unlockFocus ];	
	
	CIImage* backsideImage =[ [ [ CIImage alloc ] initWithBitmapImageRep:rep ] autorelease ];
		
	//----- create CIImage of destination view
	
	[ self lockFocus ];
	
	_drawStarField = YES;
	_drawConstellation = NO;
	
	[ self drawRect:[ self bounds] ];
		
	rep = [ [ [ NSBitmapImageRep alloc ] initWithFocusedViewRect:
								[ self bounds ] ] autorelease ];
	
	[ self unlockFocus ];	
	
	CIImage* endImage = [ [ [ CIImage alloc ] initWithBitmapImageRep:rep ] autorelease ];

	_drawStarField = YES;
	_drawConstellation = YES;
	
	//----- create transition filter
	NSRect bounds = [ self bounds ];
	
	CIVector* extent = [ CIVector vectorWithX:bounds.origin.x
											Y:bounds.origin.y
											Z:bounds.size.height
											W:bounds.size.width ];
	
	const float angle = 30 * ( M_PI / 180.0 );
								
	_transitionFilter = [ [ CIFilter filterWithName:@"CIPageCurlTransition" ] retain ];
	[ _transitionFilter setDefaults ];
	[ _transitionFilter setValue:startImage forKey:@"inputImage" ];
	[ _transitionFilter setValue:endImage forKey:@"inputTargetImage" ];
	[ _transitionFilter setValue:backsideImage forKey:@"inputBacksideImage" ];
	[ _transitionFilter setValue:extent forKey:@"inputExtent" ];
	[ _transitionFilter setValue:_shadingImage forKey:@"inputShadingImage" ];
	[ _transitionFilter setValue:[ NSNumber numberWithFloat:angle ] forKey:@"inputAngle" ];
	[ _transitionFilter setValue:[ NSNumber numberWithFloat:100.0 ] forKey:@"inputRadius" ];
	
	
	//----- animate the view
	
	TTCIFilterAnimation* animation =
		[ [ TTCIFilterAnimation alloc ] initWithView:self
		                                      filter:_transitionFilter
											  duration:1.0 ];
	[ animation autorelease ];
	
	[ animation animateAttribute:@"inputTime"
					  startValue:[ NSNumber numberWithFloat:0.0 ] 
					    endValue:[ NSNumber numberWithFloat:1.0 ] ];
	
	[ animation setDelegate:self ];
	[ animation startAnimation ];
}

- (void)animationDidEnd:(NSAnimation*)animation
{
	//------ transition filter is done, so we can get rid of it
	//       go back to normal drawing
	
	[ _transitionFilter release ];
	_transitionFilter = nil;
}


#pragma mark Mouse Events

- (void)mouseDown:(NSEvent *)theEvent
{

	//----- if double click, close path

	if ( [ theEvent clickCount ] > 1 )
	{
		[ _currentPath closePath ];
		[ self startNewConstellationPath ];
		
		return;
	}
	
	//----- add a constellation point on mouse down
	
	NSPoint location = [ self convertPoint:[ theEvent locationInWindow ] fromView:nil ];

	[ self addConstellationPoint:location ];
	
	[ self setNeedsDisplay:YES ];
}

- (void) addConstellationPoint:(NSPoint)location
{
	//----- ecah point is a new CIFilter object
	
	CIFilter* newStar = [ _starShineFilter copy ];
	CIVector* starCenter = [ CIVector vectorWithX:location.x Y:location.y ];
	
	//----- give it some attributes to differentiate it from the background
	
	[ newStar setValuesForKeysWithDictionary:_constellationStarAttributes ];
	[ newStar setValue:starCenter forKey:@"inputCenter" ];
	
	float rotation = M_PI * ( rand() / (float)RAND_MAX );
	[ newStar setValue:[ NSNumber numberWithFloat:rotation ] forKey:@"inputCrossAngle" ];
	
	[ newStar setValue:[ [ NSColor randomStarColor ] coreImageColor ] forKey:@"inputColor" ];
	[ _constellationPoints addObject:newStar ];
	
	//----- add a point to the path
	
	if ( ![ _currentPath isEmpty] )
	{
		[ _currentPath lineToPoint:location ];
	}
	else
	{
		[ _currentPath moveToPoint:location ];
	}
	
	[ self animateStar:newStar ];
}

@end







