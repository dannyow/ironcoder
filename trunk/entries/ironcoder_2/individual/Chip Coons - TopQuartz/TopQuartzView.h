//
//  TopQuartzView.h
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TopView.h"

@interface TopQuartzView : NSView {
	TopView *tv;
}

- (void)updateData:(NSArray *)anArray;

@end
