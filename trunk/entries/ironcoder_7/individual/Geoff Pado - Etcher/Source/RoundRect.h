//
//  RoundRect.h
//  Etcher
//
//  Created by Geoff Pado on 11/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (RoundRect)

+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;
- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;

@end
