//
//  Sprite.m
//  SpaceDefender
//
//    Base class for all objects that are drawn to the game view.
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import "Sprite.h"
#import "SpaceDefenderConstants.h"


@implementation Sprite

- ( id ) initWithImageName: (NSString* ) newName point: ( NSPoint ) newPoint
{
   self = [ super init ];
   if( self )
   {
      [ self setExists: YES ];
      
      NSRect newRect;
      newRect.origin = newPoint;
      newRect.size.width = 0;
      newRect.size.height = 0;
      [ self setRect: newRect ];
      
      [ self setImageName: newName ];
      [ self setVisibility: 1.0 ];

      [ self setApplyFilter: NO ];
   }
   
   return self;
}

- ( void ) dealloc
{
   [ image release ];
   
   [ super dealloc ];
}

- ( BOOL ) translateX: ( signed )x Y: (signed) y
{
   NSRect newRect = [ self rect ];
   newRect.origin.x += x;
   newRect.origin.y += y;
   
   if( NSContainsRect( gSMSViewRect, newRect ) == YES )
   {
      [ self setRect: newRect ];
      return YES;
   }
   else
   {
      return NO;
   }
}

- ( BOOL ) isHit: ( NSRect ) targetRect
{
   return NSIntersectsRect( targetRect, rect );
}

- ( CIImage* ) filteredImage: ( CIImage* ) backgroundImage
{
   // This base class simply returns the image that was specified as a parameter; subclasses may
   //    apply image filters.
   return backgroundImage;
}

- ( BOOL ) exists
{
   return exists;
}

- ( void ) setExists: ( BOOL ) doesExist
{
   exists = doesExist;
}

- ( NSRect ) rect
{
   return rect;
}

- ( void ) setRect: ( NSRect ) newRect
{
   rect = newRect;
}

- ( NSString* ) imageName
{
   return imageName;
}

- ( void ) setImageName: ( NSString* ) newName
{
   if( ! [ imageName isEqualTo: newName ] )
   {
      if( newName != nil )
      {
         newName = [ newName copy ];
      }
      
      [ imageName release ];
      imageName = newName;
      
      [ image release ];
      
      if( newName != nil )
      {
         image = [ NSImage imageNamed: imageName ];
         [ image retain ];
         NSRect newRect = [ self rect ];
         newRect.size = [ image size ];
         [ self setRect: newRect ];
      }
      else
      {
         image = nil;
      }
   }
}

- ( NSImage* ) image
{
   // Only return an image if the sprite exists.
   if( exists == YES )
   {
      return image;
   }
   else
   {
      return nil;
   }
}

- ( float ) visibility
{
   return visibility;
}

- ( void ) setVisibility: ( float ) newVisibility
{
   visibility = newVisibility;
}

- ( CIFilter* ) filter
{
   return filter;
}

- ( void ) setFilter: ( CIFilter* ) newFilter
{
   if( newFilter != nil )
   {
      newFilter = [ newFilter copy ];
   }
   
   [ filter release ];
   filter = newFilter;
}

- ( BOOL ) applyFilter
{
   return applyFilter;
}

- ( void ) setApplyFilter: ( BOOL ) doApplyFilter
{
   applyFilter = doApplyFilter;
}


@end
