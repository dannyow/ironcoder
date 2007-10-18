//
//  CIContext_CloseExtension.m
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "CIContext_CloseExtension.h"

//CGRect rectCenteredOnPoint(CGSize desiredSize, CGSize actualSize, CGPoint point)

CGRect centerAndScaleLinkedAspect(CGRect desiredRect, CGSize rawSize)
{
   
   float widthRatio = desiredRect.size.width / rawSize.width;
   float heightRatio = desiredRect.size.height / rawSize.height;
   
   if (widthRatio < heightRatio)
   {
      rawSize.width *= widthRatio;
      rawSize.height *= widthRatio;
   }
   else
   {
      rawSize.width *= heightRatio;
      rawSize.height *= heightRatio;
   }
   
   CGRect rect = desiredRect;
   rect.origin.x += (rect.size.width - rawSize.width) / 2;
   rect.origin.y += (rect.size.height - rawSize.height) / 2;
   rect.size = rawSize;
   
   return rect;
}

@implementation CIContext (CIContext_CloseExtension)

-(void)drawImage:(CIImage*)image scaledInRect:(CGRect)dstRect fromRect:(CGRect)srcRect;
{
   CGRect realDstRect = centerAndScaleLinkedAspect(dstRect, srcRect.size);
        
   [self drawImage:image inRect:realDstRect fromRect:srcRect];
   
}
@end
