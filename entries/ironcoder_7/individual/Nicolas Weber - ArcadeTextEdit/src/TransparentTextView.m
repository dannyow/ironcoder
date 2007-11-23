//
//  TransparentTextView.m
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "TransparentTextView.h"


@implementation TransparentTextView

- (id)initWithFrame:(NSRect)frame {
    if (![super initWithFrame:frame])
        return nil;

    return self;
}

- (void)awakeFromNib
{
    [(NSScrollView*)[self superview] setDrawsBackground:NO];
    
    // use the layer's background color; make the "normal" background color
    // transparent
    //[self setBackgroundColor:[NSColor colorWithDeviceRed:1 green:1 blue:1 alpha:.0]];
    NSColor* newBg = [[self backgroundColor] colorWithAlphaComponent:0.6];
    [self setBackgroundColor:newBg];
}

- (BOOL)isOpaque
{
    return NO;
}

@end
