//
//  LCARSShieldClock.h
//  lcarstime
//
//  Created by Jason Terhorst on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LCARSShieldClock : NSObject {
	float x, y, w, h;
	
	float hour;
	float minutes;
	float seconds;
}

- initWithRect:(CGRect*) rect;
- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) boxrect;

@end
