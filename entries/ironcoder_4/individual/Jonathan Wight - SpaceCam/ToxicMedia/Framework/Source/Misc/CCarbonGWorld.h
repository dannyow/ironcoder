//
//  CCarbonGWorld.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 11/10/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CCarbonGWorld : NSObject {
	GWorldPtr gworld;
}

- (id)initWithSize:(NSSize)inSize;

- (GWorldPtr)gworld;
- (GDHandle)device;

@end
