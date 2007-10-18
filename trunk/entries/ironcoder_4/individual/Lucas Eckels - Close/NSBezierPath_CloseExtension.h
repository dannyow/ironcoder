//
//  NSBezierPath_CloseExtension.h
//  Close
//
//  Created by Lucas Eckels on 10/29/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (NSBezierPath_CloseExtension)

+ (NSBezierPath*)bezierPathWithRoundRectInRect:(NSRect)aRect radius:(float)radius;

@end
