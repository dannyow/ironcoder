//
//  ControllerView.h
//  BlurredLife
//
//  Created by Adam Leonard on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>

@interface ControllerView : NSView
{
	int picturePoints;
	int totalPoints;
	
	NSString *_selectedOption;
}
- (void)selectNextOption; //if life was selected, not life becomes selected, and vise versa
- (NSString *)selectedOption; //either @"life" or @"notLife"

- (int)picturePoints;
- (void)setPicturePoints:(int)aPicturePoints;
- (int)totalPoints;
- (void)setTotalPoints:(int)aTotalPoints;

@end
