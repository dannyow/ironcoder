//
//  PixureTestController.h
//  PixureTest
//
//  Created by Joseph Wardell on 3/30/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PixureTestView;
@class PixureSystem;

@interface PixureTestController : NSObject {
	IBOutlet NSImageView* sourceImageView;
	IBOutlet PixureTestView* pixureImageView;

	PixureSystem* system;
	
	NSTimeInterval lastUpdateTime;
	
	BOOL evolving;
}

- (IBAction)chooseSourceImage:(id)sender;

// sender's intValue tells how many generations, or can just advance one generation 
- (IBAction)advanceGenerations:(id)sender;

- (IBAction)startEvolving:(id)sender;
- (IBAction)stopEvolving:(id)sender;

- (IBAction)showPreferencesWindow:(id)sender;


- (PixureSystem*)system;

// convenience accessors
- (unsigned int)generationsPassed;
- (unsigned int)rows;
- (unsigned int)columns;
- (unsigned int)newPixuresinLastGeneration;
- (unsigned int)numberOfPixures;
@end
