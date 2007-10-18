//
//  ETNSImageAdditions.h
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface NSImage(ETNSImageAdditions)

- (CIImage *)toCIImage;

@end