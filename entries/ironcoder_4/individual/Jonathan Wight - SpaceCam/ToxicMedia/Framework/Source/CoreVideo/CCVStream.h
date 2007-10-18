//
//  CCVStream.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/29/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>
#import <QTKit/QTKit.h>

/**
 * @class CCVStream
 * @discussion This class uses a QTMovie object to provide a stream of Core Image images (CIImage).
 */
@interface CCVStream : NSObject {
	QTMovie *movie;
	CGDirectDisplayID displayID;
	NSOpenGLContext *openGLContext;

	CVDisplayLinkRef displayLink;

	NSRecursiveLock *lock;
    QTVisualContextRef qtVisualContext;
	CVImageBufferRef currentFrame;
}

- (QTMovie *)movie;
- (void)setMovie:(QTMovie *)inMovie;

- (CGDirectDisplayID)displayID;
- (void)setDisplayID:(CGDirectDisplayID)inDisplayID;

- (NSOpenGLContext *)openGLContext;
- (void)setOpenGLContext:(NSOpenGLContext *)inOpenGLContext;

- (CVDisplayLinkRef)displayLink;

- (QTVisualContextRef)qtVisualContext;

- (BOOL)imageAvailableForTimeStamp:(const CVTimeStamp *)inTimeStamp;

@end

#pragma mark -

@interface CCVStream (CCVStream_ConvenienceExtensions)

/**
 * @method setView:
 * @discussion This is a convenience method that calls setDisplayID and setOpenGLContext for you based on data taken from the inView parameter. The passed in view must respond to the "openGLContext" selector, if it doesn't you will need to call setDiplayID and setOpenGLContext manually.
 */
- (void)setView:(NSView *)inView;

@end

