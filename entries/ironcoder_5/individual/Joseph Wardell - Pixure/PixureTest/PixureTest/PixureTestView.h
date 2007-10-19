//
//  PixureTestView.h
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PixureTestController;

@interface PixureTestView : NSView {
	PixureTestController* controller;
}

- (void)setController:(PixureTestController*)inController;


@end
