//
//  NoTimeSprite.h
//  NoTime
//
//  Created by Duncan Wilcox on 7/23/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NoTimeSprite : NSObject
{
	NSMutableArray *images;
	CGSize size;
	NSTimeInterval last;
	int state;
}

- (id)initWithFiles:(NSArray *)names;
- (void)drawAtPoint:(CGPoint)p;

@end
