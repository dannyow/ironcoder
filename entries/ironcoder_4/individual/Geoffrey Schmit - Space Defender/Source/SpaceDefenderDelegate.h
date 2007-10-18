//
//  SpaceDefenderDelegate.h
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 27/10/2006.
//  Copyright Sugar Maple Software, Inc 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GameView;
@class LaserBase;
@class Laser;
@class Bomb;

@interface SpaceDefenderDelegate : NSObject
{
   IBOutlet GameView* view;
   
   unsigned currentFrameCount;
   
   NSMutableArray* invaders;
   NSMutableArray* bottomMostInvaders;
   BOOL movingRight;
   unsigned invaderSoundIndex;
   
   NSMutableArray* fortresses;
   
   LaserBase* laserBase;
   
   Laser* laser;
   BOOL firing;
   
   Bomb* bomb;
   BOOL dropping;
   
   NSMutableArray* sprites;
   
   NSTimer* timer;
   
   unsigned lives;
   NSMutableArray* livesSprites;
   
   BOOL playingGame;
}

- ( IBAction ) playGame : ( id ) sender;
- ( IBAction ) stopGame : ( id ) sender;

- ( void ) fire : ( id ) sender;
- ( void ) moveLeft : ( id ) sender;
- ( void ) moveRight : ( id ) sender;

- ( BOOL ) playingGame;
- ( void ) setPlayingGame : ( BOOL ) nowPlayingGame;

- ( BOOL ) firing;
- ( void ) setFiring : ( BOOL ) nowFiring;

- ( BOOL ) dropping;
- ( void ) setDropping : ( BOOL ) nowDropping;


@end
