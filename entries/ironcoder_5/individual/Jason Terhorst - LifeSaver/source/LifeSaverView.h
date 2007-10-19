//
//  LifeSaverView.h
//  LifeSaver
//
//  Created by Jason Terhorst on 3/30/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "Lifesaver.h"


@interface LifeSaverView : ScreenSaverView 
{
	//NSColor * mainColor;
	
	NSRect cursorRect;
	
	NSTimer * candyTimer;
	NSMutableArray * lotsOfCandy;
	int captureCounter;
	
	NSImage * handImage;
}

@end
