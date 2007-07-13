//
//  TLCGImageView.h
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TLCGImageView : NSView {
	CGImageRef mImage;
}

- (void)setCGImage:(CGImageRef)image;
@end
