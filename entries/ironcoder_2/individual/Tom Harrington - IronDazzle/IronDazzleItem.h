//
//  IronDazzleItem.h
//  IronDazzle
//
//  Created by Tom Harrington on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Items will draw themselves in the supplied CGContextRef.  They have no idea if they're
// visible, that's handled over in IronDazzleView's -updateConfetti:.

@interface IronDazzleItem : NSObject {
	//CGPoint location;
	CGPoint vector;
	//CGSize size;
	CGRect rect;
	NSPoint originalScreenLocation;
	NSPoint previousScreenLocation;
}

- (id)initWithLocation:(CGPoint)newLocation vector:(CGPoint)newVector originalScreenLocation:(NSPoint)originalLocation;
//- (void)drawInContext:(NSGraphicsContext *)nsctx;
- (CGPoint)location;
- (void)moveWithCurrentScreenOrigin:(NSPoint)screenLocation;
- (void)drawLayer:(CGLayerRef)layer inContext:(CGContextRef)context;
- (CGRect)rect;
@end
