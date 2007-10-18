//
//  CIImage_Extensions.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/27/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <AppKit/AppKit.h>

/**
 * @category CIImage (CIImage_Extensions)
 * @abstract TODO
 * @discussion TODO
 */
@interface CIImage (CIImage_Extensions)

+ (CIImage *)placeholderImage;
+ (CIImage *)emptyImage;

+ (CIImage *)imageWithNSImage:(NSImage *)inNSImage;
+ (CIImage *)imageNamed:(NSString *)inName;

- (NSImage *)asNSImage;
- (NSImage *)asNSImageOfSize:(CGSize)inSize;

- (NSBitmapImageRep *)asBitmapImageRep;
- (CGImageRef)asCGImage;

- (CIImage *)flippedHorizontally;
- (CIImage *)cropToSize:(CGSize)inSize;
- (CIImage *)scaleToSize:(CGSize)inSize;
- (CIImage *)scaleToSize:(CGSize)inSize maintainAspectRatio:(BOOL)inMaintainAspectRatio;

- (CIImage *)gaussianBlurred:(float)inRadius;

@end
