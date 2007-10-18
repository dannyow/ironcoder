//
//  ProcessTimer.h
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-21.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

extern NSString *ProcessTimerProcessWillLaunchNotification;
extern NSString *ProcessTimerProcessDidLaunchNotification;
extern NSString *ProcessTimerProcessWillExitNotification;
extern NSString *ProcessTimerProcessDidExitNotification;
//A timer “dies” when its window (either the New Timer window or the timer window) is closed.
extern NSString *ProcessTimerWillDieNotification;
extern NSString *ProcessTimerDidDieNotification;

@class ProcessTimerView;

@interface ProcessTimer : NSObject {
	NSString *executable;
	NSMutableArray *searchPath;
	NSMutableArray *arguments;
	/*Valid status strings:
	 *	None ←not yet launched
	 *	Running
	 *	Exited (STATUS)
	 */
	NSString *localizedStatusString;

	//The meat. (The flying meat, if you will. *dodges tomatoes*)
	pid_t processIdentifier;
	NSCalendarDate *startTime;
	NSTimer *processRunTimer;
	unsigned days, hours, minutes, seconds; //Sent to timer view via KVO
	NSTimeInterval fractionOfSecond;

	id delegate;

	NSWindowController *timerWindowController;
	IBOutlet NSWindow *newTimerWindow;
	IBOutlet NSWindow *timerWindow;
	BOOL timerOptionsVisible;
	IBOutlet NSView *timerOptionsView;
	//These views are used to get the rects to show/hide the timer options.
	IBOutlet NSView *timerOptionsShownView, *timerOptionsHiddenView;
	IBOutlet ProcessTimerView *timerView;
	IBOutlet NSPanel *searchPathEditor;
}

- (NSString *) executable;
- (void) setExecutable:(NSString *)newExecutable;

- (NSMutableArray *) searchPath;
- (void) setSearchPath:(NSMutableArray *)newSearchPath;

- (unsigned) countOfSearchPath;
- (NSMutableArray *) objectInSearchPathAtIndex:(unsigned)idx;
- (void) insertObject:(NSMutableArray *)obj inSearchPathAtIndex:(unsigned)idx;
- (void) removeObjectFromSearchPathAtIndex:(unsigned)idx;
- (void) replaceObjectInSearchPathAtIndex:(unsigned)idx withObject:(NSMutableArray *)obj;

- (NSMutableArray *) arguments;
- (void) setArguments:(NSMutableArray *)newArguments;

- (unsigned) countOfArguments;
- (NSMutableArray *) objectInArgumentsAtIndex:(unsigned)idx;
- (void) insertObject:(NSMutableArray *)obj inArgumentsAtIndex:(unsigned)idx;
- (void) removeObjectFromArgumentsAtIndex:(unsigned)idx;
- (void) replaceObjectInArgumentsAtIndex:(unsigned)idx withObject:(NSMutableArray *)obj;

- delegate;
- (void)setDelegate:newDelegate;

- (NSString *) localizedStatusString;

#pragma mark Actions

- (IBAction)runNewTimerWindow:sender;
- (IBAction)launch:sender;
- (IBAction)chooseExecutable:sender;
- (IBAction)runSearchPathEditor:sender;
- (IBAction)toggleTimerOptions:sender;
- (IBAction)sendSIGHUP:sender;
- (IBAction)sendSIGINT:sender;
- (IBAction)sendSIGTERM:sender;
- (IBAction)sendSIGKILL:sender;

#pragma mark Actions: From the search path editor window

- (IBAction)searchPathEditorOK:sender;

@end
