//
//  Lifesaver.h
//  LifeSaver
//
//  Created by Jason Terhorst on 3/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Lifesaver : NSObject {
	
	float xpos;
	float ypos;
	float zpos;
	
	NSString * color;
	BOOL captured;
	
	NSImage * image;
	
	
}

- (float)xpos;
- (float)ypos;
- (float)zpos;
- (void)setXPos:(float)newPos;
- (void)setYPos:(float)newPos;
- (void)setZPos:(float)newPos;

- (NSString *)color;
- (void)setColor:(NSString *)aColor;
- (BOOL)captured;
- (void)setCaptured:(BOOL)key;

- (void)drawBackInView:(NSView *)aView;
- (void)drawFrontInView:(NSView *)aView;

@end
