//
//  TTSpaceTimeView.h
//  SpaceTime
//
//  Created by 23 on 10/27/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CIFilter;

@interface TTSpaceTimeView : NSView
{
			NSDictionary*		_constellationStarAttributes;
			CIFilter*			_starShineFilter;
			NSMutableArray*		_starArray;
			
			CIImage*			_starFieldImage;
			CIFilter*			_backgroundFilter;
			
			float*				_radiusProbability;
			NSMutableArray*		_constellationPoints;
			
			NSBezierPath*		_currentPath;
			NSMutableArray*		_constellationPaths;
			NSColor*			_constellationColor;
			
			CIFilter*			_transitionFilter;
			CIImage*			_shadingImage;
			
			BOOL				_drawStarField;
			BOOL				_drawConstellation;
}

- (void) distributeStars:(unsigned int)numberOfStars;
	// randomly distribute numberOfStars across view

- (void) animateRedistribute:(unsigned int)numberOfStars;
	// redistribute numberOfStars with animated transition

- (void) resetConstellation;
	// removes all constellation stars
	
@end
