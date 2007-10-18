//
//  CCoreImageView.h
//  MotionDetector
//
//  Created by Jonathan Wight on 7/14/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class CToxicOpenGLViewHelper;

@interface CCoreImageView : NSView {
	CIImage *image;

	NSImageScaling scaling;
	NSImageAlignment alignment;
	BOOL flipHorizontal;
	CIFilter *flipHorizontalFilter;

	BOOL crop;
	NSRect cropRect;
	CIFilter *cropFilter;
	
	BOOL useOpenGL;
	CToxicOpenGLViewHelper *openGLHelper;
	BOOL needsReshape;
}

- (CIImage *)image;
- (void)setImage:(CIImage *)inImage;

- (NSImageScaling)scaling;
- (void)setScaling:(NSImageScaling)inScaling;

- (NSImageAlignment)alignment;
- (void)setAlignment:(NSImageAlignment)inAlignment;

- (BOOL)flipHorizontal;
- (void)setFlipHorizontal:(BOOL)flag;

- (BOOL)crop;
- (void)setCrop:(BOOL)inCrop;

- (NSRect)cropRect;
- (void)setCropRect:(NSRect)inCropRect;

- (BOOL)useOpenGL;
- (void)setUseOpenGL:(BOOL)inUseOpenGL;

- (CToxicOpenGLViewHelper *)openGLHelper;

- (CIContext *)ciContext;


/**
 * @method imageToDraw
 * @discussion Override this method in a subclass when 'image' differs from what you want to draw from 'drawImage'. This is useful when extra processing needs to performed before drawing.
 */
- (CIImage *)imageToDraw;

- (void)beginDraw;
- (void)drawImage:(NSRect)inRect;
- (void)endDraw;

@end
