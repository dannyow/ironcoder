//
//  FESCharacter.h
//  Close
//
//  Created by Lucas Eckels on 10/28/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface FESCharacter : NSObject {
   CIImage *image;
//   NSImage *image;
   int xPos;
   int yPos;
}

-(id)initWithImage:(NSString*)imageName;

-(void)draw;

-(int)xPos;
-(int)yPos;

-(void)setXPos:(int)pos;
-(void)setYPos:(int)pos;

@end
