#import "TimeController.h"
#import "TimeGraphView.h"

static const NSTimeInterval kPeriodicUpdateInterval = 0.10;	
OSStatus MyAppChangedEventHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData);

@interface TimeController (PrivateMethods)

- (EventHandlerRef) installAppChangedEventHandler;

- (NSDate *) lastRecordedDate;
- (void) setLastRecordedDate: (NSDate *) theLastRecordedDate;

- (NSString *) frontApplication;
- (void) setFrontApplication: (NSString *) theFrontApplication;

- (void) registerAccumulatedTime;

@end

@implementation TimeController

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self resetTimeStatistics:self];
	}
	return self;
}

- (void) awakeFromNib
{
	// Install a timer to periodically "register" the elapsed time in the current application
	mPeriodicUpdateTimer = [[NSTimer timerWithTimeInterval:kPeriodicUpdateInterval target:self selector:@selector(doPeriodicUpdate:) userInfo:nil repeats:YES] retain];
	[[NSRunLoop currentRunLoop] addTimer:mPeriodicUpdateTimer forMode:(NSString*)kCFRunLoopCommonModes];

	// Install an event handler and disregard the result...
	(void) [self installAppChangedEventHandler];
	
	// Make our window translucent
	[ourWindow setOpaque:NO];
}

- (void) clearTimer
{
	[mPeriodicUpdateTimer invalidate];
	[mPeriodicUpdateTimer release];
	[mFrontApplication release];
	mPeriodicUpdateTimer = nil;
}

- (void) dealloc
{
	[self clearTimer];
	[mLastRecordedDate release];
	
	[super dealloc];
}

- (void) doPeriodicUpdate:(NSTimer*)theTimer
{
	[self registerAccumulatedTime];
}

- (EventHandlerRef) installAppChangedEventHandler
{
	OSStatus 		eventErr;
	EventTypeSpec	myEventTypes[1] = {{kEventClassApplication, kEventAppFrontSwitched}};
	EventHandlerRef	newEventHandler;
	
	// Install Carbon event handler to hear about App-Changed events
	eventErr = InstallEventHandler(GetApplicationEventTarget(), NewEventHandlerUPP(MyAppChangedEventHandler),  1, myEventTypes, self /*userdata*/, &newEventHandler);
	if (eventErr != noErr)
	{
		newEventHandler = nil;
	}

	return newEventHandler;
}

//  lastRecordedDate 
- (NSDate *) lastRecordedDate
{
    return mLastRecordedDate; 
}

- (void) setLastRecordedDate: (NSDate *) theLastRecordedDate
{
    if (mLastRecordedDate != theLastRecordedDate)
    {
        [mLastRecordedDate release];
        mLastRecordedDate = [theLastRecordedDate retain];
    }
}

//  frontApplication 
- (NSString *) frontApplication
{
    return mFrontApplication; 
}

- (void) setFrontApplication: (NSString *) theFrontApplication
{
    if (mFrontApplication != theFrontApplication)
    {
        [mFrontApplication release];
        mFrontApplication = [theFrontApplication retain];
    }
}

- (void) registerAccumulatedTime
{
	NSTimeInterval lastTime = 0.0;
	
	// Is there already some logged time for this process?
	if ([[mTimeSpentPerProcess allKeys] containsObject:mFrontApplication] == YES)
	{
		lastTime = [[mTimeSpentPerProcess objectForKey:mFrontApplication] doubleValue];
	}
	
	// Add the newly accumulated time
	lastTime += (-1 * [[self lastRecordedDate] timeIntervalSinceNow]);
	
	// Reset the accumulator date
	[self setLastRecordedDate:[NSDate date]];

	// Save the new time for this process
	[mTimeSpentPerProcess setObject:[NSNumber numberWithDouble:lastTime] forKey:mFrontApplication];
	
	// Update the TimeGraphView, causing a redisplay implicitly	
	[timeView setNamedTimeIntervals:mTimeSpentPerProcess];
}

- (IBAction) openIronCoderHomePage:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.ironcoder.org"]];
}

- (IBAction) resetTimeStatistics:(id)sender
{
	[mTimeSpentPerProcess release];
	mTimeSpentPerProcess = [[NSMutableDictionary alloc] initWithCapacity:0];
	
	[self setLastRecordedDate:[NSDate date]];
	
	// The front process is probably us, but let's be sure to start out on the right foot...
	NSString* frontName = nil;
	ProcessSerialNumber frontPSN;
	GetFrontProcess(&frontPSN);
	CopyProcessName(&frontPSN, (CFStringRef*)&frontName);
	[self setFrontApplication:frontName];
	[frontName release];
}

@end

// Plain C Implementation
OSStatus MyAppChangedEventHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
	OSStatus				result = eventNotHandledErr;
	UInt32					eventClass = GetEventClass(inEvent);
	UInt32					eventKind = GetEventKind(inEvent);

	// We only handle active app changed events...
	if ((eventClass == kEventClassApplication) && (eventKind == kEventAppFrontSwitched))
	{
		ProcessSerialNumber newFrontProcess;
		
		// Get the new process ID out
		if (GetEventParameter(inEvent, kEventParamProcessID, typeProcessSerialNumber, NULL, sizeof(ProcessSerialNumber), NULL, &newFrontProcess) == noErr)
		{
			// Get the name out 
			NSString* theProcessName;
			CopyProcessName(&newFrontProcess, (CFStringRef*)&theProcessName);
			[(TimeController*)inUserData setFrontApplication:theProcessName];
			[theProcessName release];
		}
		
		// Tell the dispatcher that we handled the event...
		result = noErr;
	}
	
	return result;
}