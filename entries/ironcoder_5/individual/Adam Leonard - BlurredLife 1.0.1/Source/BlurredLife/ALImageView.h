//
//  ALImageView.h
//  BlurredLife
//
//  Created by Adam Leonard on 3/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ALImageView : NSImageView 
{
	NSImage *_image;
	NSImage *scaledImage;
    NSImageScaling _scaling;
	
	NSRect scaledImageRect;
	
	BOOL shouldShowBorder;
	
}

- (void)setImage:(NSImage*)image;
- (void)setImageWithoutNeedingDisplay:(NSImage *)image;
- (void)setImageScaling:(NSImageScaling)newScaling;
- (NSImage*)image;
- (NSImageScaling)imageScaling;

- (NSRect)scaledImageRect;
- (void)setScaledImageRect:(NSRect)aScaledImageRect;

- (NSImage *)scaledImage;
- (void)setScaledImage:(NSImage *)aScaledImage;

- (BOOL)shouldShowBorder;
- (void)setShouldShowBorder:(BOOL)flag;

@end
