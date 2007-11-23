//
//  DPFatView.h
//  DesktopPattern
//
//  Created by August Mueller on 11/16/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DPFatView : NSView {

}

- (void) setColorBasedOnPoint:(NSPoint)p inContext:(CGContextRef)context;

@end
