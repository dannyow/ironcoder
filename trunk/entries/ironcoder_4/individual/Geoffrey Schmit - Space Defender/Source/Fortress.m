//
//  Fortress.m
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import "Fortress.h"


static const unsigned scNumberOfHitsBeforeDestruction = 3;
static const float scBumpScaleIncrement = 0.2;

@implementation Fortress


- ( id ) initWithPoint : ( NSPoint ) newPoint
{
   self = [ super initWithImageName: @"Fortress.gif" point: newPoint ];
   if( self )
   {
      numberOfHitsBeforeDestruction = scNumberOfHitsBeforeDestruction;
      
      [ self setFilter: [ CIFilter filterWithName: @"CIBumpDistortion"
            keysAndValues: @"inputRadius", [ NSNumber numberWithFloat: 100.0 ],
            nil ]];
   }
   
   return self;
}

- ( BOOL ) isHit : ( NSRect ) targetRect
{
   if( [ self exists ] == YES )
   {
      if( [ super isHit: targetRect ] == YES )
      {
         // If a fortress is hit, display an image filter and decrease its visibility.
         
         [ self setApplyFilter: YES ];
         [ self setVisibility: ( [ self visibility ] - ( 1.0 / numberOfHitsBeforeDestruction )) ];
         
         // If a fortress is hit three times, it is destroyed.
         if( --numberOfHitsBeforeDestruction == 0 )
         {
            [ self setExists: NO ];
         }
         
         // Update the filter parameters.
         filterScale = 0.0;
         filterScaleIncrement = scBumpScaleIncrement;
         
         [ filter setValue:
               [ CIVector vectorWithX: [ self rect ].origin.x Y: [ self rect ].origin.y ]
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
      [[ self filter ] setValue: backgroundImage forKey: @"inputImage" ];
      [[ self filter ] setValue: [ NSNumber numberWithFloat: filterScale ] forKey: @"inputScale" ];
      
      filterScale += filterScaleIncrement;
      
      // If the bump distortion has reached its maximum, begin to decrease it.
      if( filterScale > 1.0 )
      {
         filterScaleIncrement = -scBumpScaleIncrement;
         filterScale += filterScaleIncrement;
      }
      // If the dump distortion is back to no distortion, stop applying the image filter.
      else if( filterScale < 0 )
      {
         [ self setApplyFilter: NO ];
      }
      
      return [[ self filter ] valueForKey: @"outputImage" ];
   }
   else
   {
      return [ super filteredImage: backgroundImage ];
   }
}


@end
