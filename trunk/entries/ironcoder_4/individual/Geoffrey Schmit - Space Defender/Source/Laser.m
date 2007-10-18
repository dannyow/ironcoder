//
//  Laser.m
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import "Laser.h"
#import "SpaceDefenderConstants.h"

static unsigned scXOffsetFromLaserBase;
static unsigned scYOffsetFromLaserBase;
static float scRadius;


@implementation Laser

+ ( void ) initialize
{
   scXOffsetFromLaserBase = gSMSSpriteWidth / 2;
   scYOffsetFromLaserBase = gSMSSpriteWidth;
   scRadius = 7.0;
}

- ( id ) init
{
   // The laser doesn't have an image; it only applies an image filter.  So, initialize the base
   //    class with a nil image name, origin point, and specify that it doesn't exist.
   NSPoint newPoint = NSMakePoint( 0, 0 );
   self = [ super initWithImageName: nil point: newPoint ];
   if( self )
   {
      [ self setExists: NO ];
      
      // Set the rect based on the bounds of the image filter.
      NSRect newRect = [ self rect ];
      newRect.size.width = scRadius * 2;
      newRect.size.height = scRadius * 2;
      [ self setRect: newRect ];
      
      [ self setFilter: [ CIFilter filterWithName: @"CIStarShineGenerator"
            keysAndValues: @"inputColor", [ CIColor colorWithRed: 255 green: 127 blue: 0 ],
            @"inputRadius", [ NSNumber numberWithFloat: scRadius ],
            @"inputCrossScale", [ NSNumber numberWithFloat: 0.0 ],
            @"inputCrossAngle", [ NSNumber numberWithFloat: -33.3 ],
            @"inputCrossOpacity", [ NSNumber numberWithFloat: -3.14 ],
            @"inputCrossWidth", [ NSNumber numberWithFloat: 1.8 ],
            @"inputEpsilon", [ NSNumber numberWithFloat: 0.0 ],
            nil ]];
   }
   
   return self;
}

- ( BOOL ) moveUp
{
   if( [ self exists ] == YES )
   {
      if( [ self translateX: 0 Y: gSMSYIncrement ] == NO )
      {
         // If the laser has left the view, it no longer exists and the image filter should no
         //    longer be applied.
         [ self setExists: NO ];
         [ self setApplyFilter: NO ];
         return NO;
      }
      else
      {
         return YES;
      }
   }
   
   return NO;
}

- ( void ) fireFrom: ( id ) laserBase
{
   Sprite* laserBaseSprite = ( Sprite* ) laserBase;
   
   // Update the origin of the laser to just above the laser base that fired.
   NSRect newRect = [ self rect ];
   newRect.origin = [ laserBaseSprite rect ].origin;
   newRect.origin.x += scXOffsetFromLaserBase;
   newRect.origin.y += scYOffsetFromLaserBase;
   [ self setRect: newRect ];
   
   // The laser now exists and the image filter should be applied.
   [ self setExists: YES ];
   [ self setApplyFilter: YES ];
}

- ( CIImage* ) filteredImage: ( CIImage* ) backgroundImage
{
   if( [ self applyFilter ] == YES )
   {
      // Use a composite filter to combine the laser image with the rest of the view.
      CIFilter* compositeFilter = [ CIFilter filterWithName: @"CISourceOverCompositing"
            keysAndValues: @"inputImage", [[ self filter ] valueForKey: @"outputImage" ],
            @"inputBackgroundImage", backgroundImage, nil ];
      
      return [ compositeFilter valueForKey: @"outputImage" ];
   }
   else
   {
      return [ super filteredImage: backgroundImage ];
   }
}

- ( void ) setRect: ( NSRect ) newRect
{
   // Overridden in order to update the filter to reflect the new origin.
   
   [ super setRect: newRect ];
   
   [[ self filter ] setValue: [ CIVector vectorWithX: newRect.origin.x Y: newRect.origin.y ]
         forKey: @"inputCenter" ];
}


@end
