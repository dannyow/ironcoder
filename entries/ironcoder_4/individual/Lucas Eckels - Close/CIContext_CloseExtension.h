//
//  CIContext_CloseExtension.h
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

CGRect centerAndScaleLinkedAspect(CGRect desiredRect, CGSize rawSize);

@interface CIContext (CIContext_CloseExtension)

-(void)drawImage:(CIImage*)image scaledInRect:(CGRect)dstRect fromRect:(CGRect)srcRect;

@end
