//
//  Building.m
//  LifeCity
//
//  Created by Steven Canfield on 31/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Building.h"


@implementation Building

- (id)initWithX:(float)x Y:(float)y Z:(float)z color:(NSColor *)aColor
{
	self = [super init];
	
	X = x;
	Y = y;
	Z = z;
	
	blocks = [[NSMutableArray alloc] init];
	
	currentWidth = 0;
	currentHeight = 0;

	buildingWidth = SSRandomIntBetween( 2, 6 );
	buildingHeight = SSRandomIntBetween( 2, 60 );
	
	blockWidth = SSRandomFloatBetween( 0.1, 0.2 );//0.05;
	blockHeight = SSRandomFloatBetween( 0.05, 0.1);//0.025;
	build = YES;
	NSColor * newColor = [NSColor colorWithCalibratedRed:[aColor redComponent] green:[aColor greenComponent] blue:[aColor blueComponent] alpha:0.7];
	color = [newColor retain];
	frameNum = 41;
	numFramesToBuild = 15;
	
	return self;
}

- (void)setNumFramesToBuild:(int)nFrames {
	numFramesToBuild = nFrames;
}

- (void)draw
{
	Rectangle * rect;
	frameNum++;
	if( frameNum > numFramesToBuild && build ) { 
		frameNum = 0;
		currentWidth++;
		// Add a new block
		rect = [[Rectangle alloc] initWithRect:NSMakeRect( X + currentWidth * (blockWidth + 0.01), Y + currentHeight * (blockHeight + 0.02), blockWidth, blockHeight ) Z:Z];
		[rect setColor:color];
		[blocks addObject:rect];
		if( currentWidth >= buildingWidth ) {
			currentWidth = 0;
			currentHeight++;
			if( currentHeight >= buildingHeight ) {
				build = NO;
			}
		}
	}
	
	int blockIndex;
	for( blockIndex = 0; blockIndex < [blocks count]; blockIndex++ ) {
		rect = [blocks objectAtIndex:blockIndex];
		[rect draw];
	}
	
}
@end