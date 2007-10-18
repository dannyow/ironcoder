//
//  BSInvaderBulletView.m
//  Invader
//
//  Created by Blake Seely on 10/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BSInvaderBulletView.h"


@implementation BSInvaderBulletView

- (void)drawRect:(NSRect)rect
{
    // Clear the drawing
    [[NSColor clearColor] set];
    [NSBezierPath fillRect:[self bounds]];
    
    // Capture an image of the background
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[self bounds]];
    CIImage *originalImage = [[CIImage alloc] initWithBitmapImageRep:rep];
    [rep release];
    
    CIFilter *holeFilter = [CIFilter filterWithName:@"CIHoleDistortion"];
    [holeFilter setDefaults];
    [holeFilter setValue:originalImage forKey:@"inputImage"];
    [holeFilter setValue:[NSNumber numberWithInt:30] forKey:@"inputRadius"];
    [holeFilter setValue:[CIVector vectorWithX:[self bounds].size.width / 2 Y:[self bounds].size.height / 2] forKey:@"inputCenter"];
    
    CIImage *distortedImage = [holeFilter valueForKey:@"outputImage"];
    
    [distortedImage drawAtPoint:NSMakePoint(0,0) fromRect:[self bounds] operation:NSCompositeCopy fraction:1.0];
    
}


@end
