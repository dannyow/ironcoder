//
//  main.m
//  SpaceDefender
//
//  Created by Geoffrey Schmit on 28/10/2006.
//  Copyright Sugar Maple Software, Inc 2006. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SpaceDefenderConstants.h"


// globals
unsigned gSMSViewWidth;
unsigned gSMSViewHeight;
NSRect gSMSViewRect;

unsigned gSMSXIncrement;
unsigned gSMSYIncrement;

unsigned gSMSInvaderYSpacing;

unsigned gSMSSpriteWidth;


int main(int argc, char *argv[])
{
   // initialize globals
   gSMSViewWidth = 800;
   gSMSViewHeight = 600;
   gSMSViewRect = NSMakeRect( 0, 0, gSMSViewWidth, gSMSViewHeight );

   gSMSXIncrement = 10;
   gSMSYIncrement = 10;

   gSMSInvaderYSpacing = 25;
   
   gSMSSpriteWidth = 32;
   
   return NSApplicationMain(argc,  (const char **) argv);
}
