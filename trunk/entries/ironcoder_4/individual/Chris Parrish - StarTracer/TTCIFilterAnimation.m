//
//  TTCIFilterAnimation.m
//  SpaceTime
//
//  Created by 23 on 10/29/06.
//  Copyright 2006 23. All rights reserved.
//

#import "TTCIFilterAnimation.h"

@interface TTCIFilterAnimation ( PrivateMethods )

- (void) updateForProgress:(NSAnimationProgress)progress;

@end

@implementation TTCIFilterAnimation

- (id) initWithView:(NSView*)view
             filter:(CIFilter*)filter
			 duration:(float)seconds
{
	self = [ super initWithDuration:seconds animationCurve:NSAnimationEaseInOut ];

    if (self)
	{
        [ self setFrameRate:20.0 ];
        [ self setAnimationBlockingMode:NSAnimationNonblocking ];
		
		_ownerView = view;
		_filter = [ filter retain ];
		_parameters = [ [ NSMutableDictionary alloc ] init ];							
    }
	
    return self;
}

- (void) dealloc
{
	[ _filter release ];
	[ _parameters release ];
	
	[ super dealloc ];
}

#pragma mark CIFilter Attributes

- (void) animateAttribute:(NSString*)key
			   startValue:(id)start
				 endValue:(id)end
{
	NSArray* extrema = [ NSArray arrayWithObjects:start, end, nil ];
	[ _parameters setObject:extrema forKey:key ];
}				 

#pragma mark NSAnimation

- (void) setCurrentProgress:(NSAnimationProgress)progress
{
    [ super setCurrentProgress:progress ];
	
	[ self updateForProgress:progress ];
}


- (void) updateForProgress:(NSAnimationProgress)progress
{
	if ( !_parameters || [ _parameters count ] <= 0 )
		return;
		
	NSArray* keys = [ _parameters allKeys ];
	NSEnumerator* keyEnumerator = [ keys objectEnumerator ];
	NSString* currentKey, *classString;
	NSDictionary* attributes = [ _filter attributes ];
	
	while ( currentKey = [ keyEnumerator nextObject ] )
	{
		//----- only animating floats for now
		
		NSDictionary* parameter = [ attributes objectForKey:currentKey ];
		classString = [ parameter objectForKey:kCIAttributeClass ];	
	
		if ( ![ classString isEqualToString:@"NSNumber" ] )
			return;
		
		NSArray* extrema = [ _parameters objectForKey:currentKey ];		
		double start = [ [ extrema objectAtIndex:0 ] doubleValue ];
		double end = [ [ extrema objectAtIndex:1 ] doubleValue ];
		
		double value = start + ( ( end - start ) * progress );
		
		[ _filter setValue: [ NSNumber numberWithDouble:value ] forKey:currentKey ];
	}

	// TODO : limit the inval rect to the area that has actually changed if possible
	//        to improve performance. This is hard to do with generator filters that
	//        product images with infinte extent
	
	[ _ownerView setNeedsDisplay:YES ];
}


@end
