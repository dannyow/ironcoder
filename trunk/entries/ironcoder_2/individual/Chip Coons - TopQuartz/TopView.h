//
//  TopView.h
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "sparkline.h"

@interface TopView : NSObject {
	float x,y, w, h;
	int maxData;
	sparkline *aSpark;
	NSMutableArray *displayItems;
	
}


- initWithRect:(CGRect*) rect;

- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) rect;


- (NSMutableArray *)displayItems;
- (void)setDisplayItems:(NSArray *)inputArray;

@end
