//
//  ProcessTimer.m
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-21.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#import "ProcessTimer.h"

#import "ProcessTimerView.h"
#import "ProcessTimerErrors.h"

#include <sys/signal.h>
#include <unistd.h>
#include <sys/errno.h>
#include <string.h>
#include <math.h>

@implementation ProcessTimer

- init {
	if((self = [super init])) {
		searchPath = [[[[[NSProcessInfo processInfo] environment] objectForKey:@"PATH"] componentsSeparatedByString:@":"] mutableCopy];
		if(!searchPath) {
			searchPath = [[NSMutableArray alloc] initWithObjects:
				@"/usr/local/bin",
				@"/opt/local/bin",
				@"/usr/bin",
				@"/bin",
				nil];
		}
		arguments = [[NSMutableArray alloc] init];

		localizedStatusString = [NSLocalizedString(@"None", /*comment*/ nil) copy];

		startTime = nil;

		timerOptionsVisible = YES; //And they are, in the nib.
		timerWindowController = [[NSWindowController alloc] initWithWindowNibName:@"Timer" owner:self];
	}
	return self;
}
- (void)dealloc {
	[executable release];
	[searchPath release];
	[arguments release];
	[localizedStatusString release];

	[startTime release];
	[processRunTimer invalidate];
	[processRunTimer release];

	[timerWindowController release];

	[super dealloc];
}

#pragma mark Accessors

- (NSString *)executable {
	return executable;
}
- (void)setExecutable:(NSString *)newExecutable {
	if(executable != newExecutable) {
		[executable release];
		executable = [newExecutable copy];
	}
}

- (NSMutableArray *)searchPath {
	return searchPath;
}
- (void)setSearchPath:(NSMutableArray *)newSearchPath {
	if(searchPath != newSearchPath) {
		[searchPath release];
		searchPath = [newSearchPath copy];
	}
}

- (unsigned)countOfSearchPath {
	return [searchPath count];
}
- (NSMutableArray *)objectInSearchPathAtIndex:(unsigned)idx {
	return [searchPath objectAtIndex:idx];
}
- (void)insertObject:(NSMutableArray *)obj inSearchPathAtIndex:(unsigned)idx {
	[searchPath insertObject:obj atIndex:idx];
}
- (void)removeObjectFromSearchPathAtIndex:(unsigned)idx {
	[searchPath removeObjectAtIndex:idx];
}
- (void)replaceObjectInSearchPathAtIndex:(unsigned)idx withObject:(NSMutableArray *)obj {
	[searchPath replaceObjectAtIndex:idx withObject:obj];
}

- (NSMutableArray *)arguments {
	return arguments;
}
- (void)setArguments:(NSMutableArray *)newArguments {
	if(arguments != newArguments) {
		[arguments release];
		arguments = [newArguments mutableCopy];
	}
}

- (unsigned)countOfArguments {
	return [arguments count];
}
- (NSMutableArray *)objectInArgumentsAtIndex:(unsigned)idx {
	return [arguments objectAtIndex:idx];
}
- (void)insertObject:(NSMutableArray *)obj inArgumentsAtIndex:(unsigned)idx {
	[arguments insertObject:obj atIndex:idx];
}
- (void)removeObjectFromArgumentsAtIndex:(unsigned)idx {
	[arguments removeObjectAtIndex:idx];
}
- (void)replaceObjectInArgumentsAtIndex:(unsigned)idx withObject:(NSMutableArray *)obj {
	[arguments replaceObjectAtIndex:idx withObject:obj];
}

- delegate {
	return delegate;
}
- (void)setDelegate:newDelegate {
	delegate = newDelegate;
}

- (NSString *)localizedStatusString {
	return localizedStatusString;
}
- (void)setLocalizedStatusString:(NSString *)newLocalizedStatusString {
	if(localizedStatusString != newLocalizedStatusString) {
		[localizedStatusString release];
		localizedStatusString = [newLocalizedStatusString copy];
	}
}

- (BOOL)timerOptionsVisible {
	//If the frame origin of the options-shown view is 0.0f, then the options are shown (because the height of the timer window's content view is equal to the height of the options-shown view).
	//Otherwise, they are not shown.
	return timerOptionsVisible;
}
/*Shows and hides the Timer Options part of the timer window.
 *With the timer options hidden, the bottom of the window is 20pt below the bottom of the disclosure triangle.
 *With the timer options shown,  the bottom of the window is 20pt below the bottom of the timer options view.
 */
- (void)setTimerOptionsVisible:(BOOL)flag animate:(BOOL)animate {
	[self willChangeValueForKey:@"timerOptionsVisible"];

	NSView *viewOfCorrectSize = flag ? timerOptionsShownView : timerOptionsHiddenView;
	NSRect frame = [viewOfCorrectSize frame];
	//Hiding when shown: frame.origin.y is positive.
	//Showing when hidden: frame.origin.y is negative.
	float delta = frame.origin.y;
	if(delta != 0.0f) {
		NSRect origFrame = [timerWindow frame];
		frame = origFrame;
		frame.origin.y    += delta;
		frame.size.height -= delta;
		if(!animate)
			[timerWindow setFrame:frame display:NO];
		else {
			NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
				timerWindow, NSViewAnimationTargetKey,
				[NSValue valueWithRect:origFrame], NSViewAnimationStartFrameKey,
				[NSValue valueWithRect:frame], NSViewAnimationEndFrameKey,
				nil];
			NSViewAnimation *viewAnim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:dict]];
			[viewAnim setAnimationBlockingMode:NSAnimationNonblocking];
			[viewAnim setDelegate:self]; //Release the animation after it ends.
			[viewAnim startAnimation];
		}

		timerOptionsVisible = !timerOptionsVisible;
	}

	[self  didChangeValueForKey:@"timerOptionsVisible"];
}
- (void)setTimerOptionsVisible:(BOOL)flag {
	[self setTimerOptionsVisible:flag animate:YES];
}

- (void)animationDidEnd:(NSAnimation*)animation {
	[animation autorelease];
	//Poking this key will update the disclosure triangle.
	[self willChangeValueForKey:@"timerOptionsVisible"];
	[self  didChangeValueForKey:@"timerOptionsVisible"];
}

#pragma mark Actions

//Menu item. Also sent on launch.
- (IBAction)runNewTimerWindow:sender {
	[timerWindowController window];
	[newTimerWindow makeKeyAndOrderFront:sender];
}

#pragma mark Actions: From the new timer window

- (IBAction)launch:sender {
	//For an error message.
	NSString *localizedDescription = nil;

	if((!executable) || ([executable length] == 0U))
		localizedDescription = NSLocalizedString(@"You must enter an executable name — either a name alone (e.g. “ps”) or a path (e.g. “/bin/ps”).", /*comment*/ nil);

	if(!localizedDescription) {
		[self setTimerOptionsVisible:NO animate:NO];
		//XXX Bind views (esp. fg and bg color controls, to SharedUserDefaults) of timer window.
		//XXX This includes the time numbers.
		NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
		NSDictionary *colorOptions = [NSDictionary dictionaryWithObjectsAndKeys:
			NSUnarchiveFromDataTransformerName, NSValueTransformerNameBindingOption,
			nil];
		//XXX These need to be bound through us, not directly, or the controls will affect *every* timer view.
		[timerView bind:@"foregroundColor"
	       	   toObject:udc
	    	withKeyPath:@"values.Foreground color"
	        	options:colorOptions];
		[timerView bind:@"backgroundColor"
	       	   toObject:udc
	    	withKeyPath:@"values.Background color"
	        	options:colorOptions];

		//Hook up the timer view to its time numbers.
		[timerView bind:@"days"
	       	   toObject:self
	    	withKeyPath:@"days"
	        	options:nil];
		[timerView bind:@"hours"
	       	   toObject:self
	    	withKeyPath:@"hours"
	        	options:nil];
		[timerView bind:@"minutes"
	       	   toObject:self
	    	withKeyPath:@"minutes"
	        	options:nil];
		[timerView bind:@"seconds"
	       	   toObject:self
	    	withKeyPath:@"seconds"
	        	options:nil];
		[timerView bind:@"fractionOfSecond"
	       	   toObject:self
	    	withKeyPath:@"fractionOfSecond"
	        	options:nil];

		//Show timer window over new-timer window.
		NSRect timerWindowFrame = [timerWindow frame];
		NSRect newTimerWindowFrame = [newTimerWindow frame];
		float offsetX = (newTimerWindowFrame.size.width  - timerWindowFrame.size.width ) * 0.5f;
		float offsetY =  newTimerWindowFrame.size.height - timerWindowFrame.size.height;
		timerWindowFrame.origin.x = newTimerWindowFrame.origin.x + offsetX;
		timerWindowFrame.origin.y = newTimerWindowFrame.origin.y + offsetY;
		[timerWindow setFrame:timerWindowFrame display:NO];
		[timerWindow makeKeyAndOrderFront:nil];
		[newTimerWindow performClose:nil];

		//Run subprocess.
		processIdentifier = fork();
		if(processIdentifier == 0) {
			//We are the child process.
			//XXX Set PATH here.
			NSString *PATH = [searchPath componentsJoinedByString:@":"];
			if(setenv("PATH", [PATH fileSystemRepresentation], /*overwrite*/ 1) < 0) {
				NSLog(@"Could not set search path: %s - aborting", strerror(errno));
				_exit(1);
			}

			//The executable name goes at the head of the argument list.
			[arguments insertObject:[executable lastPathComponent] atIndex:0U];

			unsigned count = [arguments count];
			char **argv = malloc(sizeof(char *) * (count + 1U));
			if(!argv) {
				NSLog(@"Could not allocate memory for %u arguments, therefore could not exec - aborting", [arguments count]);
				_exit(1);
			}
			for(unsigned i = 0U; i < count; ++i) {
				argv[i] = (char *)[[arguments objectAtIndex:i] fileSystemRepresentation];
			}
			argv[count] = NULL;
			execvp([executable fileSystemRepresentation], argv);
			NSLog(@"Could not exec (%s) - aborting", strerror(errno));
			_exit(1);
		} else if(processIdentifier < 0) {
			localizedDescription = [NSString stringWithFormat:NSLocalizedString(@"fork() failed, returning error: %s", /*comment*/ nil), strerror(errno)];
		} else {
			//We're the owning process — start the timer.
			startTime = [[NSCalendarDate alloc] init];
			[self setLocalizedStatusString:NSLocalizedString(@"Running", /*comment*/ nil)];
			processRunTimer = [[NSTimer scheduledTimerWithTimeInterval:0.05
			                                                    target:self
			                                                  selector:@selector(updateProcess:)
			                                                  userInfo:nil
			                                                   repeats:YES] retain];
		}
	} //if(!localizedDescription)

	if(localizedDescription) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			NSLocalizedString(@"Launch error", /*comment*/ nil), NSLocalizedDescriptionKey,
			localizedDescription, NSLocalizedFailureReasonErrorKey,
			nil];
		NSError *error = [NSError errorWithDomain:PROCESSTIMER_ERROR_DOMAIN code:unrecognizedCharacterError userInfo:userInfo];
		[timerWindow presentError:error
	           	   modalForWindow:timerWindow
	         	     	 delegate:nil
	       	   didPresentSelector:NULL
	           	  	  contextInfo:NULL];
  	}
}
- (IBAction)chooseExecutable:sender {
	static BOOL hasSetDirectory = NO;
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	if(!hasSetDirectory) {
		[openPanel setDirectory:@"/usr/bin"];
		hasSetDirectory = YES;
	}
	[openPanel setDelegate:self];
	[openPanel setTreatsFilePackagesAsDirectories:YES]; //Descend into .apps.
	[openPanel setAllowsMultipleSelection:NO];

	[openPanel beginSheetForDirectory:nil
	                             file:nil
	                            types:nil
	                   modalForWindow:newTimerWindow
	                    modalDelegate:self
	                   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
	                      contextInfo:NULL];
}
- (IBAction)runSearchPathEditor:sender {
	[NSApp beginSheet:searchPathEditor
	   modalForWindow:newTimerWindow
	    modalDelegate:self
	   didEndSelector:@selector(searchPathEditor:returnCode:contextInfo:)
	      contextInfo:NULL];
}

#pragma mark Actions: From the timer window

- (IBAction)toggleTimerOptions:sender {
	[self setTimerOptionsVisible:!timerOptionsVisible];
}
- (IBAction)sendSIGHUP:sender {
	kill(processIdentifier, SIGHUP);
}
- (IBAction)sendSIGINT:sender {
	kill(processIdentifier, SIGINT);
}
- (IBAction)sendSIGTERM:sender {
	kill(processIdentifier, SIGTERM);
}
- (IBAction)sendSIGKILL:sender {
	kill(processIdentifier, SIGKILL);
}

#pragma mark Actions: From the search path editor window

- (IBAction)searchPathEditorOK:sender {
	[NSApp endSheet:searchPathEditor returnCode:NSOKButton];
}
- (void)searchPathEditor:(NSPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	[panel orderOut:nil];
}

#pragma mark NSSavePanel/NSOpenPanel delegate conformance

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode contextInfo:(void *)contextInfo {
	if(returnCode == NSOKButton) {
		[self setExecutable:[panel filename]];
	}
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
	//access will return 0 if we can execute this file or search this directory.
	return (access([filename fileSystemRepresentation], X_OK) == 0);
}

#pragma mark Update timer

- (void)updateProcess:(NSTimer *)timer {
	//Increment the time taken.
	int newDays, newHours, newMinutes, newSeconds;
	NSTimeInterval newFraction;
	double nobodyCares; //Whole part of newFraction.
	NSCalendarDate *now = [NSCalendarDate date];
	[now years:NULL
		months:NULL
		  days:&newDays
		 hours:&newHours
	   minutes:&newMinutes
	   seconds:&newSeconds
	 sinceDate:startTime];
	newFraction = modf([now timeIntervalSinceDate:startTime], &nobodyCares);

	BOOL needsDisplay = NO;
	if(days != (unsigned)newDays) {
		[self willChangeValueForKey:@"days"];
		days = newDays;
		[self  didChangeValueForKey:@"days"];
		needsDisplay = YES;
	}
	if(hours != (unsigned)newHours) {
		[self willChangeValueForKey:@"hours"];
		hours = newHours;
		[self  didChangeValueForKey:@"hours"];
		needsDisplay = YES;
	}
	if(minutes != (unsigned)newMinutes) {
		[self willChangeValueForKey:@"minutes"];
		minutes = newMinutes;
		[self  didChangeValueForKey:@"minutes"];
		needsDisplay = YES;
	}
	if(seconds != (unsigned)newSeconds) {
		[self willChangeValueForKey:@"seconds"];
		seconds = newSeconds;
		[self  didChangeValueForKey:@"seconds"];
		needsDisplay = YES;
	}
	if(fractionOfSecond != newFraction) {
		[self willChangeValueForKey:@"fractionOfSecond"];
		fractionOfSecond = newFraction;
		[self  didChangeValueForKey:@"fractionOfSecond"];
		needsDisplay = YES;
	}
	[timerView setNeedsDisplay:needsDisplay];

	//Check for exit.
	int status;
	int retval = waitpid(processIdentifier, &status, WNOHANG);
	if(retval != 0) {
		//The process has exited.
		[self setLocalizedStatusString:[NSString stringWithFormat:NSLocalizedString(@"Exited (%i)", /*comment*/ nil), status]];
		[processRunTimer invalidate];
		[processRunTimer release];
		processRunTimer = nil;
	}
}

@end
