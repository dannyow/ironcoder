//
//  BeastKeeper.m
//  Wildcat
//
//  Created by Nur Monson on 3/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "BeastKeeper.h"

// holds a group of beasts.

@implementation BeastKeeper

- (id)init
{
	if( (self = [super init]) ) {
		_rangeStart = 0.0f;
		_rangeEnd = 1.0f;
		
		_youngBeasts = [[NSMutableArray alloc] init];
		_oldBeasts = [[NSMutableArray alloc] init];
		_escapes = [[NSMutableArray alloc] init];
	}

	return self;
}

- (id)initWithStart:(float)start end:(float)end worldSize:(float)worldSize
{
	if( (self = [super init]) ) {
		_rangeStart = start;
		_rangeEnd = end;
		_worldSize = worldSize;
		
		_youngBeasts = [[NSMutableArray alloc] init];
		_oldBeasts = [[NSMutableArray alloc] init];
		_escapes = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_escapes release];
	[_youngBeasts release];
	[_oldBeasts release];

	[super dealloc];
}

- (void)setWorldSize:(float)worldSize
{
	_worldSize = worldSize;
}

- (NSArray *)escapes
{
	NSArray *result = [NSArray arrayWithArray:_escapes];
	[_escapes removeAllObjects];
	return result;
}

- (void)addBeasts:(NSMutableArray *)beasts
{
	NSMutableArray *takenBeasts = [NSMutableArray array];

	NSEnumerator *beastEnumerator = [beasts objectEnumerator];
	Creature *aBeast;
	while( (aBeast = [beastEnumerator nextObject]) ) {
		if( [aBeast position] >= _rangeStart && [aBeast position] <= _rangeEnd ) {
			[takenBeasts addObject:aBeast];
			
			if( [aBeast age] < 500 )
				[_oldBeasts addObject:aBeast];
			else
				[_youngBeasts addObject:aBeast];
		}
	}
	
	[beasts removeObjectsInArray:takenBeasts];
}

- (void)simulate
{
	[_oldBeasts performSelector:@selector(simulate)];
	[_youngBeasts performSelector:@selector(simulate)];
	
	NSMutableArray *finds = [NSMutableArray array];
	
	// find all the escapees
	NSEnumerator *beastEnumerator = [_oldBeasts objectEnumerator];
	Creature *aBeast;
	while( (aBeast = [beastEnumerator nextObject]) ) {
		if( [aBeast position] < _rangeStart || [aBeast position] > _rangeEnd )
			[finds addObject:aBeast];
	}
	[_oldBeasts removeObjectsInArray:finds];
	[_escapes addObjectsFromArray:finds];
	[finds removeAllObjects];
	
	beastEnumerator = [_youngBeasts objectEnumerator];
	while( (aBeast = [beastEnumerator nextObject]) ) {
		if( [aBeast position] < _rangeStart || [aBeast position] > _rangeEnd )
			[finds addObject:aBeast];
	}
	[_youngBeasts removeObjectsInArray:finds];
	[_escapes addObjectsFromArray:finds];
	[finds removeAllObjects];
	
	// move any old ones from the young array
	beastEnumerator = [_youngBeasts objectEnumerator];
	while( (aBeast = [beastEnumerator nextObject]) ) {
		if( [aBeast age] < 500 )
			[finds addObject:aBeast];
	}
	[_youngBeasts removeObjectsInArray:finds];
	[_oldBeasts addObjectsFromArray:finds];
	[finds removeAllObjects];
	
	/*
	// check all old ones for anyone close enough to react
	int beastAIndex;
	for( beastAIndex = 0; beastAIndex < [_oldBeasts count]; beastAIndex++ ) {
		Creature *aCreature = [_oldBeasts objectAtIndex:beastAIndex];
		int beastBIndex;
		for( beastBIndex = 0; beastBIndex < [_oldBeasts count]; beastBIndex++ ) {
			Creature *bCreature = [_oldBeasts objectAtIndex:beastBIndex];
			
			if( aCreature != bCreature ) {
				float aPosition = [aCreature position];
				float bPosition = [bCreature position];
				
				float distance = fabsf(aPosition-bPosition);
				if( distance < 0.05f ) {
					float aHue = [[aBeast color] hueComponent];
					float bHue = [[bBeast color] hueComponent];
					
					float hueDistance = bHue - aHue;
					if( fabsf(hueDistance) < fabsf(hueDistance - 1.0f))
						hueDistance = fabsf( hueDistance );
					else
						hueDistance = fabsf(hueDistance - 1.0f);
					
				}
			}
		}
	}
	*/
}

@end
