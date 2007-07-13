//
//  IronDazzleView.h
//  IronDazzle
//
//  Created by Tom Harrington on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IronDazzleView : NSView {
	NSTimer *confettiTimer;
	NSMutableArray *confettiItems;
	CGLayerRef clockLayer;
	float colorCycle;
}

- (void)addConfettiItemWithVector:(CGPoint)vector;
@end
