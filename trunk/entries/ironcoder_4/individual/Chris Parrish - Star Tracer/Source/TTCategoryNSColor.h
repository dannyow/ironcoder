//
//  TTCategoryNSColor.h
//  SpaceTime
//
//  Created by 23 on 10/28/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSColor (TTCategoryNSColor)

+ (NSColor*) randomStarColor;
	// returns a random color suitable for use to draw a star

- (CIColor*) coreImageColor;
	// creates and returns a core image color initialized with receiver
	
@end
