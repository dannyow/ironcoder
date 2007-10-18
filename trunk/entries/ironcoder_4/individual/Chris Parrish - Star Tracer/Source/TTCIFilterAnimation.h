//
//  TTCIFilterAnimation.h
//  SpaceTime
//
//  Created by 23 on 10/29/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TTCIFilterAnimation : NSAnimation
{
	NSView*				_ownerView;
	CIFilter*			_filter;
		
	NSMutableDictionary*	_parameters;
		// maps an input key for the animating filter
		// to the completed progress value
		// initial value is taken from filter when this
		// object is initialized
}

- (id) initWithView:(NSView*)view
			 filter:(CIFilter*)filter
		   duration:(float)seconds;


- (void) animateAttribute:(NSString*)key
			   startValue:(id)start
				 endValue:(id)end;
				 


@end
