//
//  Sprite.h
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface Sprite : NSObject
{
   BOOL exists;
   NSRect rect;
   
   NSString* imageName;
   NSImage* image;
   float visibility;
   
   CIFilter* filter;
   BOOL applyFilter;
}

- ( id ) initWithImageName: (NSString* ) name point: ( NSPoint ) newPoint;

- ( BOOL ) translateX: ( signed )x Y: (signed) y;
- ( BOOL ) isHit: ( NSRect ) targetRect;
- ( CIImage* ) filteredImage: ( CIImage* ) backgroundImage;

- ( BOOL ) exists;
- ( void ) setExists: ( BOOL ) doesExist;

- ( NSRect ) rect;
- ( void ) setRect: ( NSRect ) newRect;

- ( NSString* ) imageName;
- ( void ) setImageName: ( NSString* ) newName;

- ( NSImage* ) image;

- ( float ) visibility;
- ( void ) setVisibility: ( float ) newVisibility;

- ( CIFilter* ) filter;
- ( void ) setFilter: ( CIFilter* ) newFilter;

- ( BOOL ) applyFilter;
- ( void ) setApplyFilter: ( BOOL ) doApplyFilter;


@end
