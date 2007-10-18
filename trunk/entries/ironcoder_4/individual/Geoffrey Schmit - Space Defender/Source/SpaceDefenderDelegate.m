//
//  SpaceDefenderDelegate.m
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 27/10/2006.
//  Copyright Sugar Maple Software, Inc 2006. All rights reserved.
//

#import "SpaceDefenderDelegate.h"
#import "SpaceDefenderConstants.h"
#import "GameView.h"
#import "Invader.h"
#import "Fortress.h"
#import "LaserBase.h"
#import "Laser.h"
#import "Bomb.h"


// static constants
static unsigned sInvadersXMargin;
static unsigned sInvadersLeftBounds;
static unsigned sInvadersRightBounds;
static unsigned sInvadersTopBounds;
static unsigned sIncrementBetweenInvaderRows;
static unsigned sIncrementBetweenInvaderColumns;
static unsigned sEmptyInvaderColumns;

static unsigned sNumberOfInvadersPerRow;
static unsigned sNumberOfTopRowInvaders;
static unsigned sNumberOfMiddleRowInvaders;
static unsigned sNumberOfBottomRowInvaders;
static unsigned sNumberOfInvaders;

static unsigned sNumberOfHorizontalMoves;

static unsigned sFortressesXMargin;
static unsigned sFortressesLeftBounds;
static unsigned sFortressesRightBounds;
static unsigned sFortressesTopBounds;
static unsigned sIncrementBetweenFortressColumns;
static unsigned sNumberOfFortresses;

static unsigned sLaserBaseLeftBounds;
static unsigned sLaserBaseTopBounds;

static signed sPercentChanceInvaderFires;

static signed sInvadersFrameInterval;
static signed sFiringFrameInterval;
static signed sDroppingFrameInterval;

static unsigned sNumberOfLives;
static unsigned sLivesSpritesLeftBounds;
static unsigned sLivesSpritesTopBounds;
static unsigned sYIncrementBetweenLivesSprites;

@interface SpaceDefenderDelegate ( PrivateAPI )
   - ( void ) nextFrame: ( NSTimer* ) timer;
   - ( void ) gameOver;
@end

@implementation SpaceDefenderDelegate

+ ( void ) initialize
{
   // initialize statics
   sInvadersXMargin = 50;
   sInvadersLeftBounds = sInvadersXMargin;
   sInvadersRightBounds = gSMSViewWidth - sInvadersXMargin;
   sInvadersTopBounds = gSMSViewHeight;
   sIncrementBetweenInvaderRows = 50;
   sIncrementBetweenInvaderColumns = 50;
   sEmptyInvaderColumns = 4;
   
   sNumberOfInvadersPerRow =
         (( sInvadersRightBounds - sInvadersLeftBounds ) / sIncrementBetweenInvaderColumns ) -
         sEmptyInvaderColumns;
   sNumberOfTopRowInvaders = sNumberOfInvadersPerRow;
   sNumberOfMiddleRowInvaders = 2 * sNumberOfInvadersPerRow;
   sNumberOfBottomRowInvaders = 2 * sNumberOfInvadersPerRow;
   sNumberOfInvaders = sNumberOfTopRowInvaders +
         sNumberOfMiddleRowInvaders + sNumberOfBottomRowInvaders;
   
   sNumberOfHorizontalMoves = 20;
   
   sFortressesXMargin = 150;
   sFortressesLeftBounds = sFortressesXMargin;
   sFortressesRightBounds = gSMSViewWidth - sFortressesXMargin;
   sFortressesTopBounds = 50;
   sIncrementBetweenFortressColumns = 150;
   sNumberOfFortresses = (( sFortressesRightBounds - sFortressesLeftBounds ) /
         sIncrementBetweenFortressColumns ) + 1;
   
   sLaserBaseLeftBounds = gSMSViewWidth / 2;
   sLaserBaseTopBounds = 10;
   
   sPercentChanceInvaderFires = 10;
   
   // The invaders move every 5 frames.
   sInvadersFrameInterval = 5;
   
   // The laser and bomb moves every frame.
   sFiringFrameInterval = 1;
   sDroppingFrameInterval = 1;
   
   sNumberOfLives = 3;
   sLivesSpritesLeftBounds = 10;
   sLivesSpritesTopBounds = gSMSViewHeight - 30;
   sYIncrementBetweenLivesSprites = 30;
}

- ( id ) init
{
   self = [ super init ];
   if( self )
   {
      srandom( time( NULL ));
   }
   
   return self;
}

- ( void ) dealloc
{
   [ super dealloc ];
}


#pragma mark actions

- ( IBAction ) playGame : ( id ) sender
{
   // unused parameter
   ( void ) sender;
   
   [ self setPlayingGame: YES ];
   
   sprites = [[ NSMutableArray alloc ] initWithCapacity: 0 ];
   invaders = [[ NSMutableArray alloc ] initWithCapacity: 0 ];
   
   unsigned invaderIndex;
   unsigned currentX = sInvadersLeftBounds;
   unsigned currentY = sInvadersTopBounds;
   
   // Build all of the invaders.
   for( invaderIndex = 0; invaderIndex < sNumberOfInvaders; invaderIndex++ )
   {
      Invader* invader;

      if( invaderIndex % sNumberOfInvadersPerRow == 0 )
      {
         currentX = sInvadersLeftBounds;
         currentY -= sIncrementBetweenInvaderRows;
      }
      
      NSPoint point = NSMakePoint( currentX, currentY );
      currentX += sIncrementBetweenInvaderColumns;
      
      if( invaderIndex < sNumberOfTopRowInvaders )
      {
         invader = [[ Invader alloc ] initWithImageName: @"TopRow.gif" point: point ];
      }
      else if( invaderIndex < sNumberOfTopRowInvaders + sNumberOfMiddleRowInvaders )
      {
         invader = [[ Invader alloc ] initWithImageName: @"MiddleRow.gif" point: point ];
      }
      else
      {
         invader = [[ Invader alloc ] initWithImageName: @"BottomRow.gif" point: point ];
      }

      [ invaders addObject: invader ];
      [ sprites addObject: invader ];
      [ invader release ];
   }
   
   // Keep track of the bottom-most invader in each column since only these invaders can drop
   //    bombs.
   NSRange range;
   range.location = sNumberOfInvaders - sNumberOfInvadersPerRow;
   range.length = sNumberOfInvadersPerRow;
   bottomMostInvaders = [[ NSMutableArray alloc ] initWithCapacity: 0 ];
   [ bottomMostInvaders addObjectsFromArray: [ invaders subarrayWithRange: range ]];
   
   // Create the fortresses.
   fortresses = [[ NSMutableArray alloc ] initWithCapacity: 0 ];
   unsigned fortressIndex;
   currentX = sFortressesLeftBounds;
   currentY = sFortressesTopBounds;
   for( fortressIndex = 0; fortressIndex < sNumberOfFortresses; fortressIndex++ )
   {
      NSPoint point = NSMakePoint( currentX, currentY );
      Fortress* fortress = [[ Fortress alloc ] initWithPoint: point ];
      [ fortresses addObject: fortress ];
      [ sprites addObject: fortress ];
      [ fortress release ];
      
      currentX += sIncrementBetweenFortressColumns;
   }
   
   // Create the laser base.
   NSPoint point = NSMakePoint( sLaserBaseLeftBounds, sLaserBaseTopBounds );
   laserBase = [[ LaserBase alloc ] initWithPoint: point ];
   [ sprites addObject: laserBase ];
   
   // Create the laser which won't be displayed at first.
   laser = [[ Laser alloc ] init ];
   [ sprites addObject: laser ];
   firing = NO;
   
   // Create the bomb which won't be displayed at first.
   bomb = [[ Bomb alloc ] init ];
   [ sprites addObject: bomb ];
   dropping = NO;
   
   // Start by having the invaders move to the right.
   movingRight = YES;
   invaderSoundIndex = 1;
   
   lives = sNumberOfLives;
   // Create the sprites to represent the number of extra lives.
   livesSprites = [[ NSMutableArray alloc ] initWithCapacity: 0 ];
   unsigned livesSpriteIndex;
   currentX = sLivesSpritesLeftBounds;
   currentY = sLivesSpritesTopBounds;
   for( livesSpriteIndex = 0; livesSpriteIndex < sNumberOfLives - 1; livesSpriteIndex++ )
   {
      point = NSMakePoint( currentX, currentY );
      LaserBase* livesSprite = [[ LaserBase alloc ] initWithPoint: point ];
      [ livesSprites addObject: livesSprite ];
      [ sprites addObject: livesSprite ];
      [ livesSprite release ];
      
      currentY -= sYIncrementBetweenLivesSprites;
   }
   
   currentFrameCount = 0;
   
   // Register for notification at a rate of 20 fps.
   timer = [ NSTimer scheduledTimerWithTimeInterval: 0.05 target: self
         selector: @selector( nextFrame: ) userInfo: nil repeats: YES ];
   [ timer retain ];
   
   // Draw all of the sprites to the offscreen buffer.
   [ view updateOffscreenImage: sprites ];
}

- ( IBAction ) stopGame : ( id ) sender
{
   // unused parameter
   ( void ) sender;
   
   [ timer invalidate ];
   [ timer release ];
   [ bomb release ];
   [ laser release ];
   [ laserBase release ];
   [ fortresses release ];
   [ bottomMostInvaders release ];
   [ invaders release ];
   [ sprites release ];
   
   [ self setPlayingGame: NO ];
   
   [ view drawTitleViewOffscreen ];
}

- ( void ) fire : ( id ) sender
{
   ( void ) sender;
   
   // Only one laser at a time is allowed.
   if( firing == NO )
   {
      [ laser fireFrom: laserBase ];
      firing = YES;
      
      [[ NSSound soundNamed:@"laserBaseFire" ] play ];
   }
}

- ( void ) moveLeft : ( id ) sender
{
   ( void ) sender;
   
   [ laserBase moveLeft ];
}

- ( void ) moveRight : ( id ) sender
{
   ( void ) sender;
   
   [ laserBase moveRight ];
}

#pragma mark accessors

- ( BOOL ) playingGame
{
   return playingGame;
}

- ( void ) setPlayingGame : ( BOOL ) nowPlayingGame
{
   playingGame = nowPlayingGame;
}

- ( BOOL ) firing
{
   return firing;
}

- ( void ) setFiring : ( BOOL ) nowFiring
{
   firing = nowFiring;
}

- ( BOOL ) dropping
{
   return dropping;
}

- ( void ) setDropping : ( BOOL ) nowDropping
{
   dropping = nowDropping;
}


#pragma mark private

- ( void ) gameOver
{
   lives = 0;
   [ view setGameOver: YES ];
}

- ( void ) nextFrame: ( NSTimer* ) expiredTimer
{
   ( void ) expiredTimer;
   
   BOOL updateNeeded = NO;
   
   // only update the sprites if the game isn't over
   if( lives > 0 )
   {
      unsigned invaderIndex;
      
      // If the invaders move this frame....
      if( currentFrameCount % sInvadersFrameInterval == 0 )
      {
         updateNeeded = YES;
         
         BOOL moveDown = NO;
         
         // Check if it is time to move down.
         for( invaderIndex = 0; invaderIndex < [ invaders count ]; invaderIndex++ )
         {
            // Only test those invaders that haven't been destroyed.
            if( [[ invaders objectAtIndex: invaderIndex ] exists ] == YES )
            {
               if( movingRight == YES )
               {
                  if( [[ invaders objectAtIndex: invaderIndex ] rect ].origin.x + gSMSXIncrement >
                        sInvadersRightBounds -
                        [[ invaders objectAtIndex: invaderIndex ] rect ].size.width )
                  {
                     moveDown = YES;
                     break;
                  }
               }
               else
               {
                  if( [[ invaders objectAtIndex: invaderIndex ] rect ].origin.x - gSMSXIncrement <
                        sInvadersLeftBounds )
                  {
                     moveDown = YES;
                     break;
                  }
               }
            }
         }

         if( moveDown == YES )
         {
            // Change directions.
            movingRight = !movingRight;
            NSRect fortressesRect = NSMakeRect( 0, 0, gSMSViewWidth,
                  sFortressesTopBounds + [[ fortresses objectAtIndex: 0 ] rect ].size.height );
            
            // start with the bottom-most invader first in case they hit the fortresses.
            signed decrementingInvaderIndex;
            for( decrementingInvaderIndex = [ invaders count ] - 1;
                  decrementingInvaderIndex >= 0;
                  decrementingInvaderIndex-- )
            {
               [[ invaders objectAtIndex: decrementingInvaderIndex ] moveDown ];
               
               // If the invaders have reached the fortresses, the game is over.
               if( [[ invaders objectAtIndex: decrementingInvaderIndex ]
                     isHit: fortressesRect ] == YES )
               {
                  [ self gameOver ];
                  break;
               }
            }
         }
         else if( movingRight == YES )
         {
            for( invaderIndex = 0; invaderIndex < [ invaders count ]; invaderIndex++ )
            {
               [[ invaders objectAtIndex: invaderIndex ] moveRight ];
            }
         }
         else
         {
            for( invaderIndex = 0; invaderIndex < [ invaders count ]; invaderIndex++ )
            {
               [[ invaders objectAtIndex: invaderIndex ] moveLeft ];
            }
         }
         
         switch( invaderSoundIndex++ )
         {
            case 1:
               [[ NSSound soundNamed:@"invaderMove1" ] play ];
            break;
            
            case 2:
               [[ NSSound soundNamed:@"invaderMove2" ] play ];
            break;
            
            case 3:
               [[ NSSound soundNamed:@"invaderMove3" ] play ];
            break;
            
            case 4:
               [[ NSSound soundNamed:@"invaderMove4" ] play ];
               invaderSoundIndex = 1;
            break;
         }
      }
      
      // If the laser is firing and moves this frame....
      if( firing == YES && currentFrameCount % sFiringFrameInterval == 0 )
      {
         updateNeeded = YES;
         
         firing = [ laser moveUp ];
         
         // Check if the laser hit a fortress.
         unsigned fortressIndex;
         for( fortressIndex = 0; fortressIndex < [ fortresses count ]; fortressIndex++ )
         {
            if( [[ fortresses objectAtIndex: fortressIndex ] isHit: [ laser rect ]] == YES )
            {
               [ laser setExists: NO ];
               [ laser setApplyFilter: NO ];
               firing = NO;
               [[ NSSound soundNamed:@"fortressExplosion" ] play ];
            }
         }
         
         // Check if the laser hit an invader.
         unsigned invaderCount = 0;
         for( invaderIndex = 0; invaderIndex < [ invaders count ]; invaderIndex++ )
         {
            if( [[ invaders objectAtIndex: invaderIndex ] isHit: [ laser rect ]] == YES )
            {
               [ laser setExists: NO ];
               [ laser setApplyFilter: NO ];
               firing = NO;
               
               // Keep the bottom-most invader array updated.
               unsigned bottomMostInvaderIndex;
               if(( bottomMostInvaderIndex = [ bottomMostInvaders indexOfObject:
                     [ invaders objectAtIndex: invaderIndex ]] ) != NSNotFound )
               {
                  BOOL replacedBottomMostInvader = NO;
                  
                  while( invaderIndex >= sNumberOfInvadersPerRow )
                  {
                     invaderIndex -= sNumberOfInvadersPerRow;
                     if( [[ invaders objectAtIndex: invaderIndex ] exists ] == YES )
                     {
                        [ bottomMostInvaders replaceObjectAtIndex: bottomMostInvaderIndex
                              withObject: [ invaders objectAtIndex: invaderIndex ]];
                        replacedBottomMostInvader = YES;
                        break;
                     }
                  }
                  
                  if( replacedBottomMostInvader == NO )
                  {
                     [ bottomMostInvaders removeObjectAtIndex: bottomMostInvaderIndex ];
                  }
               }
               
               [[ NSSound soundNamed:@"invaderExplosion" ] play ];
            }
            
            // Keep track of how many invaders have not been destroyed.
            if( [[ invaders objectAtIndex: invaderIndex ] exists ] == YES )
            {
               invaderCount++;
            }
         }
         
         // The game ends when all the invaders are destroyed.
         if( invaderCount == 0 )
         {
            [ self gameOver ];
         }
      }
      
      // If the bomb moves this frame....
      if( currentFrameCount % sDroppingFrameInterval == 0 )
      {
         // If the bomb has already been dropped.
         if( dropping == YES )
         {
            updateNeeded = YES;
            
            dropping = [ bomb moveDown ];
            
            // Check if the bomb hit a fortress.
            unsigned fortressIndex;
            for( fortressIndex = 0; fortressIndex < [ fortresses count ]; fortressIndex++ )
            {
               if( [[ fortresses objectAtIndex: fortressIndex ] isHit: [ bomb rect ]] == YES )
               {
                  [ bomb setExists: NO ];
                  [ bomb setApplyFilter: NO ];
                  dropping = NO;
                  [[ NSSound soundNamed:@"fortressExplosion" ] play ];
               }
            }
            
            // Check if the bomb hit the laser base.
            if( [ laserBase isHit: [ bomb rect ]] == YES )
            {
               [ bomb setExists: NO ];
               [ bomb setApplyFilter: NO ];
               dropping = NO;
               [[ NSSound soundNamed:@"laserBaseExplosion" ] play ];
               if( --lives == 0 )
               {
                  [ self gameOver ];
               }
               
               // Display one less laser base to specify the loss of a life.
               if( lives > 0 )
               {
                  [[ livesSprites objectAtIndex: lives - 1 ] setExists: NO ];
               }
            }
         }
         // Randomly determine if the bomb should be dropped.
         else
         {
            if((( random() % 100 ) + 1 ) <= sPercentChanceInvaderFires )
            {
               updateNeeded = YES;
               
               [ bomb dropFrom: [ bottomMostInvaders objectAtIndex:
                     ( random() % [ bottomMostInvaders count ] ) ]];
               dropping = YES;
            }
         }
      }
      
      // Only update the offscreen buffer if necessary.
      if( updateNeeded == YES )
      {
         [ view updateOffscreenImage: sprites ];
      }
   }
   
   // Always update the view so image filters are applied.
   [ view setNeedsDisplay: YES ];
   
   currentFrameCount++;
}

#pragma mark delegate methods

- ( void ) windowWillClose: ( NSNotification* ) notification
{
   // unused parameter
   ( void ) notification;
   
   [ NSApp terminate: self ];
}


@end
