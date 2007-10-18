//
//  CMyController.m
//  CoreVideoViewTest
//
//  Created by Jonathan Wight on 11/21/2005.
//  Copyright Toxic Software 2005. All rights reserved.
//

#import "CMyController.h"

#import <QuartzCore/QuartzCore.h>

@implementation CMyController

- (void)awakeFromNib
{
CIFilter *theFilter = [CIFilter filterWithName:@"CIPointillize"];
[theFilter setDefaults];
[outletMovieView setFilter:theFilter];
}

@end
