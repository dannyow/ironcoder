//
//  PixureSaverView.m
//  PixureSaver
//
//  Created by Joseph Wardell on 4/1/07.
//  Copyright (c) 2007, Old Jewel Software. All rights reserved.
//

#import "PixureSaverView.h"
#import "NSImage_CenteredDrawingAdditions.h"
#import "PixureController.h"
#import "OJW_PixureSaverDefaults.h"

@implementation PixureSaverView

#pragma mark -
#pragma mark General Accessors


- (NSDictionary*)filenameAttributes;
{
	return [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
		[NSFont boldSystemFontOfSize:[self isPreview] ? 13.0 : 55.0],
		[NSColor blackColor],
		nil]
		
													 forKeys:[NSArray arrayWithObjects:
														 NSFontAttributeName,
														 NSForegroundColorAttributeName,
														 nil]
		];
}



#pragma mark -
#pragma mark Screen Saver Methods


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
	}
    return self;
}



- (void)startAnimation
{
    [super startAnimation];

	// don't worry about animating if in preview...
	if ([self isPreview])
		return;
	
	[[PixureController PixureController] startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];

	// don't worry about animating if in preview...
	if ([self isPreview])
		return;

	[[PixureController PixureController] stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];

	NSRect bds = [self bounds];

	if ([[OJW_PixureSaverDefaults defaults] boolForKey:@"drawPictureName"] ||
		[[OJW_PixureSaverDefaults defaults] boolForKey:@"drawThumbnail"])
	{
		// may get to something more attractive later...
		NSRect bannerRect = [self bounds];
		bannerRect.size.height = 89.0;
		if ([self isPreview])
			bannerRect.size.height = 34.0;
		
		[[NSColor colorWithDeviceHue:0.0 saturation:0.0 brightness:1.0 alpha:0.37] setFill];
		NSRectFill(bannerRect);
		
		NSPoint corner = [self bounds].origin;	corner.x += [self isPreview] ? 8.0 : 17; corner.y += [self isPreview] ? 8.0 : 17;
		if ([[OJW_PixureSaverDefaults defaults] boolForKey:@"drawThumbnail"])
		{
			NSImage* thumb = [[PixureController PixureController] thumbnailForPath:[[PixureController PixureController] pathToSourceFile]];
			if (nil != thumb)
			{
				NSRect thumbRect = NSMakeRect(corner.x, corner.y, 89.0, 55.0);
				
				// if not drawing name, then center
				if (![[OJW_PixureSaverDefaults defaults] boolForKey:@"drawPictureName"])
					thumbRect.size.width = bannerRect.size.width - corner.y;
					
				if ([self isPreview])
				{
					thumbRect.size.height = 34.0;
					thumbRect.size.width = 55.0;
				}
				[thumb drawCenteredinRect:thumbRect operation:NSCompositeSourceOver fraction:21.0/34.0];
				corner.x += 144.0; // to allow for the name to be drawn correctly
				if ([self isPreview])
					corner.x -= 55.0;
			}
		}

		if ([[OJW_PixureSaverDefaults defaults] boolForKey:@"drawPictureName"])
		{
			NSString* filename = [[[[PixureController PixureController] pathToSourceFile] lastPathComponent] stringByDeletingPathExtension];
			[filename drawAtPoint:corner withAttributes:[self filenameAttributes]];
			corner.y += 34.0;
		}
		
		// we drew a banner, center the image slightly higher to avoid an imbalance in the composition
		if (![self isPreview])	{	bds.size.height -= 89.0; bds.origin.y += 89.0;	}
	}	

	if (![self isPreview])
		[[[PixureController PixureController] imageToShow] drawCenteredinRect:bds operation:NSCompositeSourceOver fraction:1.0];

}

- (void)animateOneFrame
{
	[self setNeedsDisplay:YES];
    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    return [[OJW_PixureSaverDefaults OJW_PixureSaverDefaults] preferencesWindow];
}



@end
