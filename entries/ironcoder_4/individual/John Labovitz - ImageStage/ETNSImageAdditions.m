//
//  ETNSImageAdditions.m
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import "ETNSImageAdditions.h"


@implementation NSImage(ETNSImageAdditions)


// after: http://gigliwood.com/weblog/Cocoa/Core_Image__Practic.html

- (CIImage *)toCIImage {
		
    return [CIImage imageWithData:[self TIFFRepresentation]];
}


@end