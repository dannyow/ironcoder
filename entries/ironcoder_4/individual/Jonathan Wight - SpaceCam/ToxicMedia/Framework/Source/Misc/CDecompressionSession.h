//
//  CDecompressionSession.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/20/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QuartzCore/QuartzCore.h>
#import <QuickTime/QuickTime.h>

@class CCarbonHandle;

@interface CDecompressionSession : NSObject {
	ICMDecompressionSessionRef sessionRef;
	CCarbonHandle *imageDescription;
	NSDictionary *desiredPixelBufferAttributes;
	TimeScale timeScale;
	id delegate;
}

-(ICMDecompressionSessionRef)sessionRef;

- (NSDictionary *)desiredPixelBufferAttributes;
- (void)setDesiredPixelBufferAttributes:(NSDictionary *)inDesiredPixelBufferAttributes;

- (id)delegate;
- (void)setDelegate:(id)inDelegate;

- (void)decodeFrame:(Ptr)inPointer dataLength:(long)inLength time:(TimeValue)inTime;

- (void)didDecodeImageBuffer:(CVImageBufferRef)inImageBuffer;

@end

#pragma mark -

@interface CDecompressionSession (CDecompressionSession_Extensions)

- (id)initWithSGChannel:(SGChannel)inChannel;

@end

#pragma mark -

@interface NSObject (CDecompressionSession_Delegate)

- (void)decompressionSession:(CDecompressionSession *)inDecompressionSession didDecodeImageBuffer:(CVImageBufferRef)inImageBuffer;

@end
