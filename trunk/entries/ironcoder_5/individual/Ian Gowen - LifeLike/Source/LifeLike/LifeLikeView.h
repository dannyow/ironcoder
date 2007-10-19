//
//  LifeLikeView.h
//  LifeLike
//
//  Created by Ian Gowen on 3/31/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "IG2DArray.h"

@interface LifeLikeView : ScreenSaverView 
{
	IG2DArray *grid;
	IG2DArray *oldGrid;
	int pixelSize;
	float speed;
	NSRect viewFrame;
	
	NSSet* birthConditions;
	NSSet* sustainConditions;
	
	/* Configure sheet */
	IBOutlet id configSheet;
	/* This is hideous */
	IBOutlet NSButton *survival0;
	IBOutlet NSButton *survival1;	
	IBOutlet NSButton *survival2;
	IBOutlet NSButton *survival3;	
	IBOutlet NSButton *survival4;
	IBOutlet NSButton *survival5;	
	IBOutlet NSButton *survival6;
	IBOutlet NSButton *survival7;	
	IBOutlet NSButton *survival8;
	IBOutlet NSButton *birth0;
	IBOutlet NSButton *birth1;	
	IBOutlet NSButton *birth2;
	IBOutlet NSButton *birth3;	
	IBOutlet NSButton *birth4;
	IBOutlet NSButton *birth5;	
	IBOutlet NSButton *birth6;
	IBOutlet NSButton *birth7;	
	IBOutlet NSButton *birth8;	
	IBOutlet NSStepper *randomness;
	IBOutlet NSTextField *randomnessField;
	IBOutlet NSSlider *pixelSizeSlider;
}

/* Configure sheet */
- (IBAction)cancelClick:(id)sender;
- (IBAction)okClick:(id)sender;

@end
