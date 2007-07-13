//
//  NoTimeLayer.h
//  NoTime
//
//  Created by Duncan Wilcox on 7/23/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NoTimeLayer : NSObject
{
	CGLayerRef layer;
	CGSize size;
}

- (id)initWithFile:(NSString *)name;
- (void)loadFile:(NSString *)file;
- (void)setImage:(CGImageRef)image;
- (void)setSize:(CGSize)newSize;
- (CGSize)size;
- (void)drawAtPoint:(CGPoint)p;
- (void)tileInRect:(CGRect)r atOffset:(CGPoint)offs;

@end
