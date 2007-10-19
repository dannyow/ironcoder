//
//  NSImage_CenteredDrawingAdditions.h
//  PodcastAV
//
//  Created by Joseph Wardell on 8/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSImage (CenteredDrawing)
// draws the passed image into the passed rect, centered and scaled appropriately.
// note that this method doesn't know anything about the current focus, so the focus must be locked outside this method
- (NSRect)boundsOfCenteredImageInRect:(NSRect)inRect;
- (void)drawCenteredinRect:(NSRect)inRect operation:(NSCompositingOperation)op fraction:(float)delta;
@end
