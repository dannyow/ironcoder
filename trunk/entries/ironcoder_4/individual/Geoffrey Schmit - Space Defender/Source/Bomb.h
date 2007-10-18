//
//  Bomb.h
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright 2006 Sugar Maple Software, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Sprite.h"

@interface Bomb : Sprite
{
   
}

- ( id ) init;

- ( BOOL ) moveDown;
- ( void ) dropFrom : ( id ) invader;

@end
