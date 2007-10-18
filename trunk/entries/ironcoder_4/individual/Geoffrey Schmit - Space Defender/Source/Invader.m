 //
//  Invader.m
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import "Invader.h"
#import "SpaceDefenderConstants.h"

static const float scRippleRadius = 150.0;
static const float scRippleTimeIncrement = 0.05;

@implementation Invader

- ( id ) initWithImageName: (NSString* ) newName point: ( NSPoint ) newPoint
{
   self = [ super initWithImageName: newName point: newPoint ];
   if( self )
   {
      NSURL* url = [ NSURL fileURLWithPath: [[ NSBundle mainBundle ]
            pathForResource: @"Shading" ofType: @"tiff" ]];
      CIImage* shadingImage = [[ CIImage alloc ] initWithContentsOfURL: url ];
      [ self setFilter: [ CIFilter filterWithName: @"CIRippleTransition"
            keysAndValues: @"inputExtent",
            [ CIVector vectorWithX: 0 Y: 0 Z: gSMSViewWidth W: gSMSViewHeight ],
            @"inputShadingImage", shadingImage,
            @"inputWidth", [ NSNumber numberWithFloat: 25.0 ],
            @"inputScale", [ NSNumber numberWithFloat: 50.0 ],
            nil ]];
      [ shadingImage release ];
   }
   
   return self;
   
}

- ( BOOL ) moveRight
{
   if( [ self exists ] == YES )
   {
      [ self translateX: gSMSXIncrement Y: 0 ];
      return YES;
   }
   
   return NO;
}

- ( BOOL ) moveLeft
{
   if( [ self exists ] == YES )
   {
      [ self translateX: -gSMSXIncrement Y: 0 ];
      return YES;
   }
   
   return NO;
}

- ( BOOL ) moveDown
{
   if( [ self exists ] == YES )
   {
      [ self translateX: 0 Y: -gSMSInvaderYSpacing ];
      return YES;
   }
   
   return NO;
}

- ( BOOL ) isHit : ( NSRect ) targetRect
{
   if( [ self exists ] == YES )
   {
      if( [ super isHit: targetRect ] == YES )
      {
         // If the invader is hit, it no longer exists and needs to display its image filter.
         [ self setExists: NO ];
         [ self setApplyFilter: YES ];
         
         transitionTime = 0.0;
         
         // Update the image filter with the current location of the invader.
         NSPoint centerPoint = [ self rect ].origin;
         [[ self filter ] setValue: [ CIVector vectorWithX: centerPoint.x Y: centerPoint.y ]
               forKey: @"inputCenter" ];

         return YES;
      }
   }
   
   return NO;
}

- ( CIImage* ) filteredImage : ( CIImage* ) backgroundImage
{
   if( [ self applyFilter ] == YES )
   {
      // Update the ripple transition with the current background and time.
      [[ self filter ] setValue: backgroundImage forKey: @"inputImage" ];
      [[ self filter ] setValue: backgroundImage forKey: @"inputTargetImage" ];
      [[ self filter ] setValue: [ NSNumber numberWithFloat: transitionTime ]
            forKey: @"inputTime" ];
      
      // We don't want the ripple to spread across the entire view; so, clip it and then
      //    composite it against the background.
      CIImage* maskImage = [[ CIFilter filterWithName: @"CIRadialGradient"
            keysAndValues: @"inputCenter",
            [ CIVector vectorWithX: [ self rect ].origin.x Y: [ self rect ].origin.y ],
            @"inputRadius0", [ NSNumber numberWithFloat: 0.0 ],
            @"inputRadius1", [ NSNumber numberWithFloat: scRippleRadius ],
            @"inputColor0", [ CIColor colorWithRed: 255 green: 255 blue: 255 ],
            @"inputColor1", [ CIColor colorWithRed: 0 green: 0 blue: 0 ],
            nil ] valueForKey: @"outputImage" ];
      
      CIFilter* crop = [ CIFilter filterWithName: @"CIDarkenBlendMode"
            keysAndValues: @"inputImage", maskImage,
            @"inputBackgroundImage", [[ self filter ] valueForKey: @"outputImage"],
            nil ];
      
      CIFilter* compositeFilter = [ CIFilter filterWithName: @"CILightenBlendMode"
            keysAndValues: @"inputImage", backgroundImage,
            @"inputBackgroundImage", [ crop valueForKey: @"outputImage" ],
            nil ];
      
      transitionTime += scRippleTimeIncrement;
      
      // If the transition has completed, stop applying the filter.
      if( transitionTime > 1.0 )
      {
         [ self setApplyFilter: NO ];
      }
      
      return [ compositeFilter valueForKey: @"outputImage" ];
   }
   else
   {
      return [ super filteredImage: backgroundImage ];
   }
}


@end
