//
//  IronLifeView.h
//  IronLife
//
//  Created by 23 on 3/30/07.
//  Copyright (c) 2007, Chris Parrish. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <Quartz/Quartz.h>

@interface IronLifeView : ScreenSaverView 
{

				QCView*			_compositionView;
	
	IBOutlet	NSWindow*		_configurationSheet;
}

- (IBAction) doOK:(id)sender;
- (IBAction) doCancel:(id)sender;

@end
