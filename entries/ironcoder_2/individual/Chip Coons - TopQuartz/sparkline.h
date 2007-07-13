//
//  sparkline.h
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface sparkline : NSObject {
	
	NSString *name;
	NSArray *dataArray;
	
	float x, y, w, h;
	
    float increment, alpha, r, g, b;
	
}

- initWithRect:(CGRect*) rect;

- (void)setDataArray:(NSArray *)inputArray;
- (NSArray *)dataArray;
- (void)setName:(NSString *)aString;
- (NSString *)name;

- (void)paint:(CGContextRef) context frame:(CGRect*) contextRect bounds:(CGRect*) boundsRect;


@end
