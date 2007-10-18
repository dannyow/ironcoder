//
//  FESCloseController.h
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class FESCharacter;
@class FESCloseView;

enum FESTurnType
{
   FESUp,
   FESDown,
   FESLeft,
   FESRight,
   FESUpLeft,
   FESUpRight,
   FESDownLeft,
   FESDownRight,
   FESFart,
   FESTeleport,
   FESPass,
   FESNoTurn
};
typedef enum FESTurnType FESTurnType;

@interface FESCloseController : NSObject {
   NSMutableArray *foes;
   FESCharacter *avatar;
   FESCharacter *lover;
   IBOutlet FESCloseView *view;
   IBOutlet NSButton *weaponButton;
   IBOutlet NSButton *ventButton;
   
   BOOL gotLover;
   BOOL usedWeapon;
   
   NSArray *maps;
   int currentMap;
   NSSound *mapSound;
}

-(IBAction)fart:(id)sender;
-(IBAction)vents:(id)sender;
-(IBAction)openHelp:(id)sender;

-(void)draw;

-(void)clickInSquareX:(int)xPos Y:(int)yPos;
-(void)executeTurn:(FESTurnType)turn;

-(void)testVictory;

-(void)initializeGame;

@end
