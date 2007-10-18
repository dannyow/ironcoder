//
//  FESFoe.m
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "FESFoe.h"
#import "FESCloseConstants.h"
#import "FESCloseController.h"
#import "CIContext_CloseExtension.h"

@implementation FESFoe

-(id)initWithLiveImage:(NSString*)liveName deadImage:(NSString*)deadName;
{
   if (self = [super initWithImage:liveName])
   {
      dead = NO;
      
      liveImage = [image retain];
      deadImage = nil;
      
      NSString *path = [[NSBundle mainBundle] pathForImageResource:deadName];
      if (path != nil)
      {
         NSURL *url = [NSURL fileURLWithPath:path];
         
         deadImage = [[CIImage alloc] initWithContentsOfURL:url];
      }
   }
   
   return self;
}

-(void)nextTurn:(FESCharacter*)avatar;
{
   if (!dead)
   {
      int avatarXPos = [avatar xPos];
      int avatarYPos = [avatar yPos];
      
      int myXPos = [self xPos];
      int myYPos = [self yPos];
      if (myXPos < avatarXPos)
      {
         ++myXPos;
      }
      else if (myXPos > avatarXPos)
      {
         --myXPos;
      }
      
      if (myYPos < avatarYPos)
      {
         ++myYPos;
      }
      else if (myYPos > avatarYPos)
      {
         --myYPos;
      }
      
      [self setXPos:myXPos];
      [self setYPos:myYPos];
   }
}

-(BOOL)isDead;
{
   return dead;
}

-(void)setDead:(BOOL)aDead;
{
   if (!dead && aDead)
   {
      [image release];
      image = [deadImage retain];
   }
   
   dead = aDead;
}

@end
