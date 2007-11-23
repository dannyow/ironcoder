//
//  DPAppDelegate.h
//  DesktopPattern
//
//  Created by August Mueller on 11/16/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define appDelegate (DPAppDelegate*)[NSApp delegate]

@interface DPAppDelegate : NSObject {
    CGContextRef _patternContext;
    CGContextRef _bigContext;
    IBOutlet NSWindow *configWindow;
    
    NSString *layerCountMessage;
}

- (CGContextRef) createBitmapContextOfSize:(NSSize)size;

- (CGContextRef)patternContext;

- (NSString *)layerCountMessage;
- (void)setLayerCountMessage:(NSString *)value;

- (void) sendNewImage;

@end


