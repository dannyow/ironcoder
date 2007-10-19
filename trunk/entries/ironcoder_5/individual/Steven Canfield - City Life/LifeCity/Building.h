//
//  Building.h
//  LifeCity
//
//  Created by Steven Canfield on 31/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Rectangle.h"
#import <ScreenSaver/ScreenSaver.h>

@interface Building : NSObject {
	@public
	float X;
	float Y;
	float Z;

	@protected
	NSMutableArray * blocks;
	
	float blockWidth;
	float blockHeight;
	
	int buildingWidth;
	int buildingHeight;
	
	int currentHeight;
	int currentWidth;
	
	NSColor * color;
	BOOL build;
	int frameNum;
	int numFramesToBuild;
}
- (id)initWithX:(float)x Y:(float)y Z:(float)z color:(NSColor *)aColor;
- (void)draw;

@end
