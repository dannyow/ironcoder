//
//  CToxicOpenGLViewHelper.h
//  CustomOpenGLView
//
//  Created by Jonathan Wight on 8/15/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CToxicOpenGLViewHelper : NSObject <NSCoding> {
	NSView *view; // weak ref
    NSOpenGLPixelFormat *pixelFormat;
    NSOpenGLContext *openGLContext;
}

+ (NSOpenGLPixelFormat *)defaultPixelFormat;

- (NSView *)view;
- (void)setView:(NSView *)inView;

- (NSOpenGLPixelFormat *)pixelFormat;
- (void)setPixelFormat:(NSOpenGLPixelFormat *)inPixelFormat;
- (NSOpenGLContext *)openGLContext;
- (void)setOpenGLContext:(NSOpenGLContext *)inOpenGLContext;

- (CIContext *)coreImageContext;

- (void)lockFocus;
- (void)unlockFocus;

- (void)update;

@end
