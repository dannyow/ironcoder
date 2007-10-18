//
//  LCARSview.h
//  lcarstime
//
//  Created by Jason Terhorst on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LCARSDeflectorClock.h"
#import "LCARSShieldClock.h"
#import "LCARSWarpClock.h"

@interface LCARSview : NSView {
	// create the "arch" design
	NSBezierPath * archPath;
	
	//NSBezierPath * bookendLeft;
	//NSBezierPath * bookendRight;
	
	NSImage * titleImage;
	NSImage * titleImageWhite;
	NSImage * deflectorImage;
	NSImage * deflectorImageWhite;
	NSImage * shieldImage;
	NSImage * shieldImageWhite;
	NSImage * warpImage;
	NSImage * warpImageWhite;
	NSImage * engageImage;
	NSImage * disengageImage;
	NSImage * logoImage;
	NSImage * markingImage1;
	NSImage * markingImage2;
	
	NSColor * modeColor;
	NSColor * modeHighlightColor;
	NSColor * engageColor;
	NSColor * engageHighlightColor;
	NSColor * alertColor;
	NSColor * alertHighlightColor;
	
	NSColor * deflectorButtonColor;
	NSColor * shieldButtonColor;
	NSColor * warpButtonColor;
	NSColor * engageButtonColor;
	
	NSRect deflectorRect;
	NSRect shieldRect;
	NSRect warpRect;
	NSRect engageRect;
	
	BOOL redalert;
	NSString * mode;
	
	
	NSTimer * renderTimer;
	LCARSDeflectorClock * deflectorclock;
	LCARSShieldClock * shieldclock;
	LCARSWarpClock * warpclock;
}

@end
