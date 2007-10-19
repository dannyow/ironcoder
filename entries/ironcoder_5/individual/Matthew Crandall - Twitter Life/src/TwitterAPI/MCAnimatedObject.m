//
//  MCAnimatedObject.m
//  TwitterAPI
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import "MCAnimatedObject.h"


@implementation MCAnimatedObject

- (id)init {

	self = [super init];
	if (self) {
		_speed = 25;
		_location = NSMakePoint(4000, 100);
		_fading = NO;
		_opacity = 1.0;
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

- (void)setFading:(BOOL)fading {
	_fading = YES;
}

- (void)setSpeed:(int)speed {
	_speed = speed;
}

- (float)opacity {
	return _opacity;
}

- (void)setWall:(NSPoint)wall {
	_wall = wall;
}

- (void)setLocation:(NSPoint)location {
	_location = location;
}

- (void)animate {
	if (_fading) {  //fade out while fading.
		_opacity = _opacity - 0.05;
	}
	
	if (_wall.x < _location.x) { //move to designated spot left.
		_location.x = _location.x - _speed;
		if (_location.x < _wall.x)
			_location.x = _wall.x;
	}
	
	//NSLog(@"location:%f", _location.x);
}

- (void)draw {
	return;
}

- (NSRect)bounds {
	return NSZeroRect;
}

@end
