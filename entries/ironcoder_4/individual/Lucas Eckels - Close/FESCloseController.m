//
//  FESCloseController.m
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "FESCloseController.h"
#import "FESCharacter.h"
#import "FESFoe.h"
#import "FESCloseConstants.h"
#import "FESCloseView.h"

@implementation FESCloseController

-(void)awakeFromNib;
{
   srand(time(NULL));

   gotLover = NO;
   usedWeapon = NO;
   currentMap = 0;

   NSString *path = [[NSBundle mainBundle] pathForResource:@"Maps" ofType:@"plist"];
   
   maps = [[NSArray alloc] initWithContentsOfFile:path];
   [self initializeGame];
}

-(void)dealloc;
{
   [avatar release];
   [foes release];
   [lover release];
   
   [maps release];
   [mapSound release];
   
   [super dealloc];
}

-(IBAction)openHelp:(id)sender;
{
   NSString *readme = [[NSBundle mainBundle] pathForResource:@"Readme" ofType:@"rtf"];
   if (readme != nil)
   {
      [[NSWorkspace sharedWorkspace] openFile:readme];
   }
}

-(IBAction)fart:(id)sender;
{
   [self executeTurn:FESFart];
}

-(IBAction)vents:(id)sender;
{
   [self executeTurn:FESTeleport];
}

-(void)clickInSquareX:(int)xPos Y:(int)yPos;
{
   int avatarXPos = [avatar xPos];
   int avatarYPos = [avatar yPos];
   
   FESTurnType turn = FESNoTurn;
   
   if (xPos == avatarXPos-1)
   {
      if (yPos == avatarYPos-1)
      {
         turn = FESDownLeft;
      }
      else if (yPos == avatarYPos)
      {
         turn = FESLeft;
      }
      else if (yPos == avatarYPos+1)
      {
         turn = FESUpLeft;
      }
   }
   else if (xPos == avatarXPos)
   {
      if (yPos == avatarYPos-1)
      {
         turn = FESDown;
      }
      else if (yPos == avatarYPos)
      {
         turn = FESPass;
      }
      else if (yPos == avatarYPos+1)
      {
         turn = FESUp;
      }
   }
   else if (xPos == avatarXPos+1)
   {
      if (yPos == avatarYPos-1)
      {
         turn = FESDownRight;
      }
      else if (yPos == avatarYPos)
      {
         turn = FESRight;
      }
      else if (yPos == avatarYPos+1)
      {
         turn = FESUpRight;
      }
   }
   
   [self executeTurn:turn];
   
}

-(void)executeTurn:(FESTurnType)turn;
{
   NSDictionary *mapDef = [maps objectAtIndex:currentMap];

   bool killNeighborFoes = NO;
   int xPos = [avatar xPos];
   int yPos = [avatar yPos];
   
   switch (turn)
   {
      case FESUp:
         ++yPos;
         break;
      case FESDown:
         --yPos;
         break;
      case FESLeft:
         --xPos;
         break;
      case FESRight:
         ++xPos;
         break;
      case FESUpLeft:
         ++yPos;
         --xPos;
         break;
      case FESUpRight:
         ++yPos;
         ++xPos;
         break;
      case FESDownLeft:
         --yPos;
         --xPos;
         break;
      case FESDownRight:
         --yPos;
         ++xPos;
         break;
      case FESTeleport:
         xPos = rand() % FIELD_WIDTH;
         yPos = rand() % FIELD_HEIGHT;
         break;
      case FESFart:
         if (usedWeapon)
         {
            [view blurAndDisplayString:@"You've already used it this level"];
            return;
         }
         CIColor *color = [CIColor colorWithString:[mapDef valueForKey:@"weaponColor"]];
         [view displayStinkCloudAtPoint:NSMakePoint((xPos+0.5)*CHARACTER_WIDTH, (yPos+0.5)*CHARACTER_HEIGHT) radius:2*CHARACTER_HEIGHT color:color];
         killNeighborFoes = YES;
         usedWeapon = YES;
         break;
      case FESPass:
         break; // nothing to do
      case FESNoTurn:
         return; // do not execute a turn
   }

   [avatar setXPos:xPos];
   [avatar setYPos:yPos];

   FESFoe *foeArray[FIELD_WIDTH*FIELD_HEIGHT];
   memset(foeArray, 0, FIELD_WIDTH*FIELD_HEIGHT*sizeof(FESFoe*));
   
   NSEnumerator *foeEnum = [foes objectEnumerator];
   FESFoe *foe;
   while (foe = [foeEnum nextObject])
   {
      if (killNeighborFoes)
      {
         if (abs([foe xPos] - xPos) < 2 && abs([foe yPos] - yPos) < 2)
         {
            [foe setDead:YES];
         }
      }
      
      [foe nextTurn:avatar];
      int index = [foe xPos]*FIELD_HEIGHT + [foe yPos];
      FESFoe *existingFoe = foeArray[index];
      if (existingFoe == nil)
      {
         foeArray[index] = foe;
      }
      else
      {
         [existingFoe setDead:YES];
         [foe setDead:YES];
      }
   }
   
   int avatarIndex = [avatar xPos]*FIELD_HEIGHT + [avatar yPos];
   if (avatarIndex > 0 && foeArray[avatarIndex] != nil)
   {
      // you've been hit, restart the level
      [view blurAndDisplayString:@"Your space has been invaded!"];
      [view initializeTransition];
      [self initializeGame];
      [view displayTransition];
   }
   
   if (!gotLover && [avatar xPos] == [lover xPos] && [avatar yPos] == [lover yPos])
   {
      NSString *str = [mapDef valueForKey:@"loverString"];
      [view blurAndDisplayString:str];
      gotLover = YES;
   }
   
   [self testVictory];
   
   
   [view setNeedsDisplay:YES];
   
}

-(void)draw;
{
   NSEnumerator *foeEnum = [foes objectEnumerator];
   FESCharacter *foe;
   while (foe = [foeEnum nextObject])
   {
      [foe draw];
   }
   
   [avatar draw];
   
   if (!gotLover)
   {
      [lover draw];
   }
   
}

-(void)initializeGame;
{
   // cleanup old game
   [avatar release];
   [foes release];
   [lover release];
   lover = nil;
   if (mapSound != nil)
   {
      [mapSound stop];
      [mapSound release];
      mapSound = nil;
   }
   
   if (currentMap >= [maps count])
   {
      currentMap = 0;
   }
   
   NSDictionary *mapDef = [maps objectAtIndex:currentMap];
   
   [view setMapName:[mapDef valueForKey:@"mapName"]];

   NSString *soundName = [mapDef valueForKey:@"sound"];
   if (soundName != nil)
   {
      NSString *soundPath = [[NSBundle mainBundle] pathForResource:soundName ofType:@"mov"];
      if (soundPath != nil)
      {
         mapSound = [[NSSound alloc] initWithContentsOfFile:soundPath byReference:NO];
         [mapSound setDelegate:self];
         [mapSound play];
      }
   }

   [weaponButton setImage:[NSImage imageNamed:[mapDef valueForKey:@"weaponButtonImage"]]];
   [ventButton setImage:[NSImage imageNamed:[mapDef valueForKey:@"ventButtonImage"]]];
   
   gotLover = YES; // default to not needing to get her
   usedWeapon = NO;
   
   avatar = [[FESCharacter alloc] initWithImage:[mapDef valueForKey:@"avatarImage"]];
   [avatar setXPos:[[mapDef valueForKey:@"avatarStartX"] intValue]];
   [avatar setYPos:[[mapDef valueForKey:@"avatarStartY"] intValue]];
   
   NSNumber *loverPresent = [mapDef valueForKey:@"loverPresent"];
   if (loverPresent != nil && [loverPresent boolValue])
   {
      lover = [[FESCharacter alloc] initWithImage:[mapDef valueForKey:@"loverImage"]];
      [lover setXPos:[[mapDef valueForKey:@"loverXPos"] intValue]];
      [lover setYPos:[[mapDef valueForKey:@"loverYPos"] intValue]];
      gotLover = NO; // need to get her
   }
   
   NSString *foeLiveImage = [mapDef valueForKey:@"foeImage"];
   NSString *foeDeadImage = [mapDef valueForKey:@"deadFoeImage"];
   int foeCount = [[mapDef valueForKey:@"foeCount"] intValue];
   
   foes = [[NSMutableArray alloc] initWithCapacity:foeCount];
   for (unsigned int i = 0; i < foeCount; ++i)
   {
      FESFoe *foe = [[FESFoe alloc] initWithLiveImage:foeLiveImage deadImage:foeDeadImage];
      bool occupied = YES;
      int foeXPos, foeYPos;
      while (occupied)
      {
         foeXPos = rand() % FIELD_WIDTH;
         foeYPos = rand() % FIELD_HEIGHT;
         
         int xDist = abs(foeXPos - [avatar xPos]);
         int yDist = abs(foeYPos - [avatar yPos]);
         
         if (xDist > 1 && yDist > 1)
         {
            occupied = NO;
         }
      }
      
      [foe setXPos:foeXPos];
      [foe setYPos:foeYPos];
      
      [foes addObject:foe];
      [foe release];   
   }
      
   [view setNeedsDisplay:YES];
}

-(void)testVictory;
{
   if (!gotLover)
   {
      return;
   }
   
   NSEnumerator *foeEnum = [foes objectEnumerator];
   FESFoe *foe;
   while (foe = [foeEnum nextObject])
   {
      if ([foe isDead] == NO)
      {
         return;
      }
   }
   
   ++currentMap;
   [view initializeTransition];
   [self initializeGame];
   [view displayTransition];
   
}

-(void)sound:(NSSound*)sound didFinishPlayed:(BOOL)aBool
{
   if (aBool)
   {
      [sound play];
   }
   
}
@end
