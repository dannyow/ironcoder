//
//  T3CategoryNSGraphicsContext.m
//  IronCoder v2
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import "T3CategoryNSGraphicsContext.h"

@implementation NSGraphicsContext (T3CategoryNSGraphicsContext)

- (CGContextRef) coreGraphicsContext
{
	return (CGContextRef) [ self graphicsPort ];
}

@end
