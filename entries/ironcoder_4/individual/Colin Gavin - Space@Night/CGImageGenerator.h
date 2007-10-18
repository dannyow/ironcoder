//
//  CGImageGenerator.h
//  gavincolin@gmail.com
//
//  Created by Colin Gavin on 10/28/06.

#import <Cocoa/Cocoa.h>


@interface CGImageGenerator : NSObject
+(CIImage *)starWithRadius:(float)radius color:(NSColor *)color;
+(CIImage *)tintImage:(NSImage *)img withColor:(NSColor *)color;
+(CIImage *)addGlowToImage:(CIImage *)img amount:(float)blurAmount;
@end
