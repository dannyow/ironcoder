//
//  TLCGImageView.m
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import "TLCGImageView.h"
#import "TLDefines.h"

@implementation TLCGImageView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setCGImage:(CGImageRef)image
{
	if (image != mImage)
	{
		CGImageRelease(mImage);
		mImage = image;
		CFRetain(mImage);
		[self setNeedsDisplay:YES];
	}
}

- (void)drawRect:(NSRect)rect
{
	if (mImage == NULL) return;
	
	CGContextRef ctx = [[NSGraphicsContext currentContext]graphicsPort];
	CGContextDrawImage(ctx, NSRectToCGRect(rect), mImage);
}

@end
