//
//  DPBackgroundWindow.m
//  DesktopPattern
//
//  Created by August Mueller on 11/17/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "DPBackgroundWindow.h"
#import "DPView.h"

@implementation DPBackgroundWindow

- (void) awakeFromNib {
    
    NSRect backBounds = [self frame];
    backBounds.origin = NSZeroPoint;
    
    DPView *backView = [[DPView alloc] initWithFrame:backBounds];
    [backView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [[self contentView] addSubview:backView positioned:NSWindowBelow relativeTo:nil];
    
    NSScreen *mainScreen = [NSScreen mainScreen];
    
    [self setFrame:[mainScreen frame] display:YES];
    
    [self setLevel:kCGDesktopWindowLevel];
    
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen {
    return frameRect;
}

@end
