//
//  LaserBase.m
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import "LaserBase.h"
#import "SpaceDefenderConstants.h"


@implementation LaserBase

- ( id ) initWithPoint: ( NSPoint ) newPoint
{
   self = [ super initWithImageName: @"LaserBase.gif" point: newPoint ];
   if( self )
   {
      [ self setFilter: [ CIFilter filterWithName: @"CIColorInvert" ]];
   }
   
   return self;
}

- ( BOOL ) moveRight
{
   return [ self translateX: gSMSXIncrement Y: 0 ];
}

- ( BOOL ) moveLeft
{
   return [ self translateX: -gSMSXIncrement Y: 0 ];
}

- ( BOOL ) isHit: ( NSRect ) targetRect
{
   // Assume that this object always exists since, otherwise, the game would be over.
   
   if( [ super isHit: targetRect ] == YES )
   {
      // When the laser base is hit, it will apply the color invert image filter for the next
      //    frame.
      [ self setApplyFilter: YES ];
      
      return YES;
   }
   else
   {
      return NO;
   }
}

- ( CIImage* ) filteredImage: ( CIImage* ) backgroundImage
{
   if( [ self applyFilter ] == YES )
   {
      [[ self filter ] setValue: backgroundImage forKey: @"inputImage" ];
      
      // The image filter is only apply for a single frame.
      [ self setApplyFilter: NO ];
      
      return [[ self filter ] valueForKey: @"outputImage" ];
   }
   else
   {
      return [ super filteredImage: backgroundImage ];
   }
}

@end
