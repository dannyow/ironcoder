//
//  DPAppDelegate.m
//  DesktopPattern
//
//  Created by August Mueller on 11/16/07.
//  Copyright 2007 Flying Meat Inc. All rights reserved.
//

#import "DPAppDelegate.h"

#define BEST_BYTE_ALIGNMENT 16
#define COMPUTE_BEST_BYTES_PER_ROW(bpr)		( ( (bpr) + (BEST_BYTE_ALIGNMENT-1) ) & ~(BEST_BYTE_ALIGNMENT-1) )


@implementation DPAppDelegate

- (void) awakeFromNib {
    [configWindow center];
    _patternContext = [self createBitmapContextOfSize:NSMakeSize(10, 10)];
    _bigContext = [self createBitmapContextOfSize:NSMakeSize(100, 100)];
}

- (void) dealloc {
    
    unsigned int *base = CGBitmapContextGetData(_patternContext);
    CGContextRelease(_patternContext);
    free(base);
    
    base = CGBitmapContextGetData(_bigContext);
    CGContextRelease(_bigContext);
    free(base);
    
    [super dealloc];
}

- (CGContextRef) createBitmapContextOfSize:(NSSize)size {
    
    // Minimum bytes per row is 4 bytes per sample * number of samples.
    size_t bytesPerRow = size.width * 4;
    // Round to nearest multiple of BEST_BYTE_ALIGNMENT.
    bytesPerRow = COMPUTE_BEST_BYTES_PER_ROW(bytesPerRow);
    
    unsigned char *rasterData = calloc(1, bytesPerRow * size.height);
    
    CGContextRef ctx = CGBitmapContextCreate(rasterData, size.width, size.height, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedFirst);
    
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    
    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height));
    
    return ctx;
}

- (CGContextRef)patternContext {
    return _patternContext;
}
- (NSString *)layerCountMessage {
    return [[layerCountMessage retain] autorelease];
}

- (void)setLayerCountMessage:(NSString *)value {
    if (layerCountMessage != value) {
        [layerCountMessage release];
        layerCountMessage = [value copy];
    }
}


- (void) sendNewImage {
    
    // CoreAnimation is fast... but not that fast.  So we create a 10x bigger image to send to the layers- which speeds things up.
    
    CGImageRef img = CGBitmapContextCreateImage(_patternContext);
    
    NSSize patternSize  = NSMakeSize(100, 100);
    int x = 0, y = 0;
    
    
    while (x < patternSize.width) {
        
        while (y < patternSize.height){
            
            CGContextDrawImage(_bigContext, CGRectMake(x, y, 10, 10), img);
            
            y += 10;
        }
        
        x += 10;
        y = 0;
    }
    
    CGImageRelease(img);
    
    img = CGBitmapContextCreateImage(_bigContext);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PatternChange" object:(id)img];
    
    CGImageRelease(img);
}
@end
