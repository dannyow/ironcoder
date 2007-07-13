//
//  T3CategoryNSGraphicsContext.h
//  IronCoder v2
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <AppKit/NSGraphicsContext.h>
//#import "CGContext.h"

@interface NSGraphicsContext (T3CategoryNSGraphicsContext)

- (CGContextRef) coreGraphicsContext;

@end
