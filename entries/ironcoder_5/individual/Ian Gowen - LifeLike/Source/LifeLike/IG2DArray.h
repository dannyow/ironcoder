//
//  IG2DArray.h
//  LifeLike
//
//  Created by Ian Gowen on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IG2DArray : NSObject {
	NSMutableArray *backend;
	int width;
	int height;
}
- (IG2DArray*) initWithWidth:(int)w height:(int)h;
- (id) objectAtRow:(int)row column:(int)column;
- (void) replaceObjectAtRow:(int)row column:(int)column withObject:(id)object;

- (NSNumber *) neighborsAtRow:(int)row column:(int)column;
- (NSArray *) getNeighborsAtRow:(int)row column:(int)column;

- (int)width;
- (int)height;


@end
