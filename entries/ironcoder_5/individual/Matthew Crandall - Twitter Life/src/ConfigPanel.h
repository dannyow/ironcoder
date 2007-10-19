//
//  ConfigPanel.h
//  TwitterLife
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ConfigPanel : NSObject {
	IBOutlet NSPanel *_panel;
	IBOutlet NSPopUpButton *_dataset;
	IBOutlet NSPopUpButton *_updates;
	IBOutlet NSTextField *_username;
	IBOutlet NSSecureTextField *_password;
}

- (NSPanel *)panel;
- (IBAction)cancelClick:(id)sender;

@end
