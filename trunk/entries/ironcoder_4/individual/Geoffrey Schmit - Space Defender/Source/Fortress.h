//
//  Fortress.h
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sprite.h"


@interface Fortress : Sprite
{
   float filterScale;
   float filterScaleIncrement;
   unsigned numberOfHitsBeforeDestruction;
}

- ( id ) initWithPoint : ( NSPoint ) newPoint;

- ( BOOL ) isHit : ( NSRect ) targetRect;


@end
