/**************************************************************************************
 * Copyright (c) 2006 RogueSheep Incorporated. All rights reserved.
 *
 * $File: //RogueSheep/CompanyDocs/XCodeTemplates/Cocoa/Objective-C NSWindowController subclass.pbfiletemplate/class.h $
 * $Revision: #1 $
 * $Author: raezor $
 * $Date: 2005/06/22 $
 *
 * Created by 23 on 3/5/06.
 *
 * Description:
 *
 **************************************************************************************/

#import <Cocoa/Cocoa.h>

@interface TTWindowController : NSWindowController 
{
	IBOutlet			NSTextField*		fStatusTextField;
	
	Point				fLastMousePoint;
	AXUIElementRef		fSystemWideElementRef;
	AXUIElementRef		fCurrentElementRef;
	
	NSArray*			fSecretWordArray;
}

- (void) doTimerUpdate;

- (void) updateCurrentUIElement;

- (void) setCurrentUIElement:(AXUIElementRef)newUIElement;

- (void) updateUI;

- (NSString*) currentElementContainsSecret;

- (NSString*) stringContainsSecret:(NSString*)string;

@end
