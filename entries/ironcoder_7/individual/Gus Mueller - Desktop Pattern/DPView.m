//
//  DPView.m
//  DesktopPattern
//
//  Created by August Mueller on 11/16/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "DPView.h"
#import "DPAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation DPView

- (id)initWithFrame:(NSRect)frameRect; {
    
    self = [super initWithFrame:frameRect];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(patternDidChange:) name:@"PatternChange" object:nil];
    
    return self;
}


- (void) setupLayer {
    
    [self setWantsLayer:YES];
    
    CALayer *layer      = [self layer];
    NSSize mySize       = [self bounds].size;
    NSSize patternSize  = NSMakeSize(CGBitmapContextGetWidth([appDelegate patternContext]) * 10, CGBitmapContextGetHeight([appDelegate patternContext]) * 10);
    int x = 0, y = 0;
    
    
    while (x < mySize.width) {
        
        while (y < mySize.height){
            
            CALayer *sublayer = [CALayer layer];
            
            sublayer.frame = CGRectMake(x, y, patternSize.width, patternSize.height);
            
            [layer addSublayer:sublayer];
            
            y += patternSize.height;
        }
        
        x += patternSize.width;
        y = 0;
    }
    
    if ([[[self layer] sublayers] count] > 200) {
        [appDelegate setLayerCountMessage:[NSString stringWithFormat:@"(%d layers created)", [[[self layer] sublayers] count]]];
    }
    
}

- (void) patternDidChange:(NSNotification*)note {
    
    if (![self layer]) {
        [self setupLayer];
    }
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    
    CGImageRef img = (CGImageRef)[note object];
    
    for (CALayer *layer in [[self layer] sublayers]) {
        layer.contents = (id)img;
    }
    
    [CATransaction commit];
}
@end
