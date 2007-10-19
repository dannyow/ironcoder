//
//  NSImage_CenteredDrawingAdditions.m
//  PodcastAV
//
//  Created by Joseph Wardell on 8/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSImage_CenteredDrawingAdditions.h"


@implementation NSImage (CenteredDrawing)

- (NSRect)boundsOfCenteredImageInRect:(NSRect)inRect
{
		NSRect srcRect = NSZeroRect;
		srcRect.size = [self size];

		// create a destination rect scaled to fit inside the frame
		NSRect drawnRect = srcRect;
		if (drawnRect.size.width > inRect.size.width)
		{
			drawnRect.size.height *= inRect.size.width/drawnRect.size.width;
			drawnRect.size.width = inRect.size.width;
		}

		if (drawnRect.size.height > inRect.size.height)
		{
			drawnRect.size.width *= inRect.size.height/drawnRect.size.height;
			drawnRect.size.height = inRect.size.height;
		}

		drawnRect.origin = inRect.origin;

		// center it in the frame
		drawnRect.origin.x += (inRect.size.width - drawnRect.size.width)/2;
		drawnRect.origin.y += (inRect.size.height - drawnRect.size.height)/2;

	return drawnRect;
}

// draws the passed image into the passed rect, centered and scaled appropriately.
// note that this method doesn't know anything about the current focus, so the focus must be locked outside this method
- (void)drawCenteredinRect:(NSRect)inRect operation:(NSCompositingOperation)op fraction:(float)delta
{
		NSRect srcRect = NSZeroRect;
		srcRect.size = [self size];

		NSRect drawnRect = [self boundsOfCenteredImageInRect:inRect];
		[self drawInRect:drawnRect fromRect:srcRect operation:op fraction:delta];
}

@end
