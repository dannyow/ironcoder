//
//  BeastMaster.m
//  Wildcat
//
//  Created by Nur Monson on 3/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BeastMaster.h"


@implementation BeastMaster

- (id)init
{
	if( (self = [super init]) ) {
		_beastKeepers = [[NSMutableArray alloc] init];
		
		float keeperIndex;
		for( keeperIndex = 0.0f; keeperIndex < 10.0; keeperIndex += 1.0f ) {
			BeastKeeper *aBeastKeeper = [[BeastKeeper alloc] initWithStart:keeperIndex end:keeperIndex+1.0f worldSize:10.0f];
			[_beastKeepers addObject:aBeastKeeper];
		}

	}

	return self;
}



- (void)dealloc
{
	[_beastKeepers release];

	[super dealloc];
}

- (void)simulate
{
	NSEnumerator *keeperEnumerator = [_beastKeepers objectEnumerator];
	BeastKeeper *aKeeper;
	while( (aKeeper = [keeperEnumerator nextObject]) )
		[aKeeper simulate];
}

- (void)draw
{
	
}

@end
