//
//  WindowView.m
//  Etcher
//
//  Created by Geoff Pado on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WindowView.h"
#import "RoundRect.h"

@implementation WindowView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect 
{
		NSColor *redColor = [NSColor redColor];
		NSColor *bloodColor = [NSColor colorWithCalibratedRed:.5882352941176 green:0 blue:0 alpha:1];
		NSGradient *backgroundGradient = [[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:redColor, bloodColor, nil]];
		[backgroundGradient drawInBezierPath:[NSBezierPath bezierPathWithRoundedRect:[self frame] cornerRadius:15.0] angle:90];
}

@end
