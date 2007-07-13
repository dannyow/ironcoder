//
//  NoTimeGuy.h
//  NoTime
//
//  Created by Duncan Wilcox on 7/23/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NoTimeGuy : NSObject
{
	NSArray *images;
	int state;
	NSTimeInterval last;
	int count;
	CGSize size;
	int currentMotion;
	float skip;
}

- (void)setMotion:(int)newMotion;
- (int)currentMotion;
- (void)drawAtPoint:(CGPoint)p;
- (CGSize)size;

@end
