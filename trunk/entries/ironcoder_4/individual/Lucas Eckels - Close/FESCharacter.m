//
//  FESCharacter.m
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "FESCharacter.h"
#import "FESCloseConstants.h"
#import "FESCloseController.h"
#import "CIContext_CloseExtension.h"

@implementation FESCharacter

-(id)initWithImage:(NSString*)imageName;
{
   if (self = [super init])
   {
      xPos = yPos = 0;
      image = nil;
      
      NSString *path = [[NSBundle mainBundle] pathForImageResource:imageName];
      if (path != nil)
      {
         NSURL *url = [NSURL fileURLWithPath:path];

         image = [[CIImage alloc] initWithContentsOfURL:url];
      }
   }
   
   return self;
}

-(void)dealloc;
{
   [image release];
   [super dealloc];
}

-(void)draw;
{
   if (image != nil)
   {
      CIContext *context = [[NSGraphicsContext currentContext] CIContext];
      CGRect dstRect = RectForSpace(xPos, yPos);
      
      [context drawImage:image scaledInRect:dstRect fromRect:[image extent]];
   }
}

-(int)xPos;
{
   return xPos;
}


-(int)yPos;
{
   return yPos;
}

-(void)setXPos:(int)pos;
{
   if (pos >= 0 && pos < FIELD_WIDTH)
   {
      xPos = pos;
   }
}

-(void)setYPos:(int)pos;
{
   if (pos >= 0 && pos < FIELD_HEIGHT)
   {
      yPos = pos;
   }
}

@end
