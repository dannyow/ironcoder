//
//  NSImage_Extensions.h
//  FallingSand
//
//  Created by Jonathan Wight on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (NSImage_Extensions)

+ (NSImage *)imageFromCGImageRef:(CGImageRef)inCGImage;

@end
