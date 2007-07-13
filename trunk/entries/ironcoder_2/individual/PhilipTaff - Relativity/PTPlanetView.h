//
//  PTPlanetView.h
//  Relativity
//
//  Created by Philip on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PTClock.h"


@interface PTPlanetView : NSView 
{
	PTClock *clock;
	NSTimer *clockTimer;
	NSSize clockSize;
	CGImageRef image;
	CGRect drawingRect;
}

@end
