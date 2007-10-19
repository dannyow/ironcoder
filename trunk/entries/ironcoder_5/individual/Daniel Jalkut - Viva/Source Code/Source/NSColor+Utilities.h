//
//  NSColor+Utilities.h
//  Viva
//
//  Created by Daniel Jalkut on 9/2/06.
//  Copyright 2006 Red Sweater Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Utilities)

- (NSColor*) colorByAveragingWithColor:(NSColor*)otherColor;

@end
