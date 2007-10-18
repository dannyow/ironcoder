//
//  FESFoe.h
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FESCharacter.h"

@interface FESFoe : FESCharacter {
   BOOL dead;
   CIImage *liveImage;
   CIImage *deadImage;
}

-(id)initWithLiveImage:(NSString*)liveName deadImage:(NSString*)deadName;
-(void)nextTurn:(FESCharacter*)avatar;

-(BOOL)isDead;
-(void)setDead:(BOOL)aDead;

@end
