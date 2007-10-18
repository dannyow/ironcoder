//
//  CFrameRate.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 10/29/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * @class CFrameRate
 * @abstract A class for keeping track of the number of 'frames' per second.
 * @discussion This is a standalone class because I found I was using this code in multiple places and/or moving it from class to class. As a standalone class it can easily be encapsulated as needed.
 */

@interface CFrameRate : NSObject {
	NSTimeInterval firstFrameTime;
	float frameCount;
	float fps;
}

- (void)updateFrameRate;
- (void)updateFrameRate:(NSTimeInterval)inTimeInterval;
- (void)reset;

- (float)fps;

@end
