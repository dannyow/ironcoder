//
//  MCAnimatedObject.h
//  TwitterAPI
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MCAnimatedObject : NSObject {
	float _opacity;
	int _speed;
	NSPoint _location;
	NSPoint _wall;
	BOOL _fading;
}

- (void)draw;
- (NSRect)bounds;
- (void)animate;

- (float)opacity;
- (void)setFading:(BOOL)fading;
- (void)setSpeed:(int)speed;
- (void)setWall:(NSPoint)wall;
- (void)setLocation:(NSPoint)location;

@end
