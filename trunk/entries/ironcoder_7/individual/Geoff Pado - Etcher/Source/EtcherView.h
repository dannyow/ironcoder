//
//  EtcherView.h
//  Etcher
//
//  Created by Geoff Pado on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EtcherView : NSView {
	NSBezierPath *drawPath;
	NSColor *strokeColor;
	id delegate;
}

- (id)delegate;
- (void)setDelegate:(id)aValue;
- (void)dropOpacity;
- (void)clearPath;

@end
