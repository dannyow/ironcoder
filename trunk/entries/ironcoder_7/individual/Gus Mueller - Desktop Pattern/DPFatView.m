//
//  DPFatView.m
//  DesktopPattern
//
//  Created by August Mueller on 11/16/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "DPFatView.h"
#import "DPAppDelegate.h"

@implementation DPFatView

- (void)drawRect:(NSRect)rect {
    
    CGImageRef img = CGBitmapContextCreateImage([appDelegate patternContext]);
    
    CGContextRef screenContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    // this keeps us from getting fuzzy edges.
    CGContextSetInterpolationQuality(screenContext, kCGInterpolationNone);
    
    CGContextDrawImage(screenContext, NSRectToCGRect([self bounds]), img);
    CGImageRelease(img);
    
    CGContextSetRGBFillColor(screenContext, 0, 0, 0, 1);
    
    NSRect borderRect = NSOffsetRect([self bounds], 0.5f, 0.5f);
    borderRect.size.width --;
    borderRect.size.height --;
    
    CGContextStrokeRect(screenContext, NSRectToCGRect(borderRect));
}

- (void) mouseDown:(NSEvent*)theEvent {
    
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    p.x = floorf((p.x / 10.f));
    p.y = floorf((p.y / 10.f));
    
    [self setColorBasedOnPoint:p inContext:[appDelegate patternContext]];
    
    do {
        p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        
        p.x = floorf((p.x / 10.f));
        p.y = floorf((p.y / 10.f));
        
        
        CGContextFillRect([appDelegate patternContext], CGRectMake(p.x, p.y, 1, 1));
        
        [self setNeedsDisplay:YES];
        
        [appDelegate sendNewImage];
        
        theEvent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)];
        if ([theEvent type] == NSLeftMouseUp) {
            break;
        }
        
    }
    while (1);
    
}

- (void) setColorBasedOnPoint:(NSPoint)p inContext:(CGContextRef)context {
    
    unsigned int height     = CGBitmapContextGetHeight(context);
    unsigned int *basePtr   = CGBitmapContextGetData(context);
    unsigned int bpr        = CGBitmapContextGetBytesPerRow(context);
    unsigned int rwidth     = bpr / 4;
    unsigned int flipY      = height - p.y - 1;
    unsigned int pt         = ((rwidth * flipY)) + p.x;
    unsigned int color      = *(basePtr + pt);
    
    if (color == 0xffffffff) { // ie, it's white, so let's set it to black
        CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    }
    else {
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    }
    
}


@end
