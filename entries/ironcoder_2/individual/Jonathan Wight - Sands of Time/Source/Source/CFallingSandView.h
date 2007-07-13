//
//  CFallingSandView.h
//  FallingSand
//
//  Created by Jonathan Wight on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CSandbox;

@interface CFallingSandView : NSView {
	CSandbox *sandbox;
	CGImageRef image;
	
	int currentParticle;
	float penRadius;
}

- (CSandbox *)sandbox;
- (void)setSandbox:(CSandbox *)inSandbox;

- (CGImageRef)image;
- (void)setImage:(CGImageRef)inImage;

- (int)currentParticle;
- (void)setCurrentParticle:(int)inCurrentParticle;

- (float)penRadius;
- (void)setPenRadius:(float)inPenRadius;

@end
