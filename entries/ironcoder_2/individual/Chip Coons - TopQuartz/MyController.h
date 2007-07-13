//
//  MyController.h
//  TopQuartz
//
//  Created by Chip Coons on 7/21/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Storage;
@class TopQuartzView;

@interface MyController : NSObject {
	//Add a TextView to the window and uncomment & connect in IB 
	//IBOutlet *textView
	IBOutlet TopQuartzView *graphicsView;
	NSTimer *renderTimer;
	
	Storage *myContainer;
}	


@end
