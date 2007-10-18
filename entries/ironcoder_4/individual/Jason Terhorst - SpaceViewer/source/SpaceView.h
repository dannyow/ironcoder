//
//  SpaceView.h
//  SpaceViewer
//
//  Created by Students on 10/27/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface SpaceView : NSView {
	
	IBOutlet id delegate;
	
	double currentPosition;
	double nextPosition;
	
	NSTimer * scrollTimer;
	NSMutableArray * images;
	NSImage * planetsImage;
	CIImage * ciPlanets;
	CIFilter * filter;
}

- (void)setNextPosition:(double)newPos;

@end
