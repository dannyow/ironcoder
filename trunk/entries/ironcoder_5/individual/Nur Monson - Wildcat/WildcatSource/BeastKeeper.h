//
//  BeastKeeper.h
//  Wildcat
//
//  Created by Nur Monson on 3/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Creature.h"

@interface BeastKeeper : NSObject {

	float _rangeStart;
	float _rangeEnd;
	
	float _worldSize;
	
	NSMutableArray *_youngBeasts;
	NSMutableArray *_oldBeasts;
	NSMutableArray *_escapes;
	
}

- (id)initWithStart:(float)start end:(float)end worldSize:(float)worldSize;

- (void)setWorldSize:(float)worldSize;

- (NSArray *)escapes;
// if it doesn't belong here it's spit out
- (void)addBeasts:(NSMutableArray *)beasts;

- (void)simulate;
@end
