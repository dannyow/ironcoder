//
//  LifeRecordView.h
//  LifeRecord
//
//  Created by Tom Harrington on 4/1/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

@class QCView;


@interface LifeRecordView : ScreenSaverView 
{
	QCView *qtzView;
	NSTimer *snapshotTimer;
	NSTimer *flashTimer;
	float flashLevel;
	float flashStep;

	IBOutlet NSWindow *configSheet;
	IBOutlet NSTextField *shapshotIntervalField;
	int snapshotInterval;
	BOOL changeFilter;
	IBOutlet NSButton *changeFilterButton;
	IBOutlet NSTextField *snapshotSaveLocationField;
	NSString *snapshotSaveLocation;
	int snapshotIndex;
	ScreenSaverDefaults *defaults;
	IBOutlet NSTextField *snapshotMaxSavedField;
	int snapshotMaxSaved;
}

- (IBAction)cancelClick:(id)sender;
- (IBAction)okClick:(id)sender;
@end
