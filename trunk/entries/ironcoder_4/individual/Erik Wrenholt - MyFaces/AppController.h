//
//  AppController.h
//  MyFaces
//
//  Created by Erik Wrenholt on 9/30/06.
//  Copyright 2006 Timestretch Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MyCIView.h>

@interface AppController : NSObject {
	NSWindow *mainWindow;
	IBOutlet MyCIView *myView;
	IBOutlet NSWindow *warning;
}

-(IBAction)randomPicture:(id)sender;
-(IBAction)quit:(id)sender;
-(IBAction)continue:(id)sender;

@end
