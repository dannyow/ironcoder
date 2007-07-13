//
//  TapDanceController.m
//  TapDance
//
//  Created by Michael Ash on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TapDanceController.h"

#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>

#import "Boid.h"


enum { kMouseEvent, kKeyboardEvent, kSwitchEvent };

@interface TapDanceController (Private)

- (NSImage *)_stopImage;
- (NSImage *)_goImage;
- (NSTimeInterval)_idleInterval;
- (NSTimeInterval)_totalAccumulatedTimeUntilTime: (NSTimeInterval)now;
- (void)_dumpToDictionary;
- (void)_eventReceivedType: (int)isMouse;
- (void)_prodPulseTimer;
- (void)_pulse: (NSTimer *)timer;
- (void)_resetUploadTimer;

@end

@implementation TapDanceController

static CGEventRef EventTapCallback( CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon )
{
	[(id)refcon _eventReceivedType: type == kCGEventMouseMoved ? kMouseEvent : kKeyboardEvent];
	
	return event;
}

static OSStatus AppSwitchCallback( EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData )
{
	[(id)inUserData _eventReceivedType: kSwitchEvent];
	
	return noErr;
}

+ (void)initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat: 60.0], @"uploadInterval",
			nil]];
}

- init
{
	if( ( self = [super init] ) )
	{
		if( !AXAPIEnabled() )
		{
			[[NSAlert alertWithMessageText: @"You must enable access for assistive devices for TapDance to function." defaultButton: @"Quit" alternateButton: nil otherButton: nil informativeTextWithFormat: @"Please enable this in System Preferences and then relaunch TapDance"] runModal];
			exit( 0 );
		}
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	mTimes = [[NSMutableDictionary alloc] init];
	
	mTapPort = CGEventTapCreate( kCGSessionEventTap,
								 kCGTailAppendEventTap,
								 kCGEventTapOptionListenOnly,
								 (1 << kCGEventMouseMoved) |
								 (1 << kCGEventKeyDown) |
								 (1 << kCGEventKeyUp),
								 EventTapCallback,
								 self );
	
	CFRunLoopSourceRef source = CFMachPortCreateRunLoopSource( NULL, mTapPort, 0 );
	CFRunLoopAddSource( CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode );
	CFRelease( source );
	
	EventTypeSpec spec = { kEventClassApplication, kEventAppFrontSwitched };
	InstallApplicationEventHandler( AppSwitchCallback, 1, &spec, self, NULL );
	
	[self _eventReceivedType: kSwitchEvent];
	
	[self _resetUploadTimer];
}

@end

@implementation TapDanceController (Private)

- (NSImage *)_stopImage
{
	if( !mStopImage )
	{
		mStopImage = [[NSImage alloc] initWithSize: NSMakeSize( 128, 128 )];
		
		float side = 128 / (2 + sqrtf( 2 ));;
		
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path moveToPoint: NSMakePoint( 0, side )];
		[path lineToPoint: NSMakePoint( 0, 128 - side )];
		[path lineToPoint: NSMakePoint( side, 128 )];
		[path lineToPoint: NSMakePoint( 128 - side, 128 )];
		[path lineToPoint: NSMakePoint( 128, 128 - side)];
		[path lineToPoint: NSMakePoint( 128, side )];
		[path lineToPoint: NSMakePoint( 128 - side, 0 )];
		[path lineToPoint: NSMakePoint( side, 0 )];
		[path closePath];
		
		[mStopImage lockFocus];
		[[NSColor redColor] setFill];
		[path fill];
		[mStopImage unlockFocus];
		
	}
	return mStopImage;
}

- (NSImage *)_goImage
{
	if( !mGoImage )
	{
		mGoImage = [[NSImage alloc] initWithSize: NSMakeSize( 128, 128 )];
		
		[mGoImage lockFocus];
		[[NSColor greenColor] setFill];
		[[NSBezierPath bezierPathWithOvalInRect: NSMakeRect( 0, 0, 128, 128 )] fill];
		[mGoImage unlockFocus];
	}
	return mGoImage;
}

- (NSTimeInterval)_idleInterval
{
	return 5.0;
}

- (NSTimeInterval)_totalAccumulatedTimeUntilTime: (NSTimeInterval)now
{
	return mAccumulatedTime + MIN( now - mLastActivityTime, [self _idleInterval] );
}

- (void)_dumpToDictionary
{
	NSString *bundleID = [mCurrentApp objectForKey: @"NSApplicationBundleIdentifier"];
	if( bundleID )
	{
		NSNumber *totalNumber = [mTimes objectForKey: bundleID];
		NSTimeInterval total = totalNumber ? [totalNumber doubleValue] : 0.0;
		total += mAccumulatedTime;
		[mTimes setObject: [NSNumber numberWithDouble: total] forKey: bundleID];
	}
}

- (void)_eventReceivedType: (int)type
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	mAccumulatedTime = [self _totalAccumulatedTimeUntilTime: now];
	mLastActivityTime = now;
	
	if( type == kSwitchEvent )
	{
		if( mCurrentApp )
		{
			[self _dumpToDictionary];
			[mCurrentApp release];
		}
		
		mAccumulatedTime = 0.0;
		mLastActivityTime = 0.0;
		
		mCurrentApp = [[[NSWorkspace sharedWorkspace] activeApplication] retain];
		[self _dumpToDictionary]; // ensure an entry exists
		mLastActivityTime = now;
	}
	
	[self _prodPulseTimer];
	
	if( [NSWindow hasBoids] )
	{
		NSDisableScreenUpdates();
		[[NSApp windows] makeObjectsPerformSelector: @selector( deboidify )];
		[[[NSApp orderedWindows] objectAtIndex: 0] makeKeyAndOrderFront: nil];
		NSEnableScreenUpdates();
	}
	if( mBoredomTimer )
	{
		[mBoredomTimer invalidate];
		[mBoredomTimer release];
		mBoredomTimer = nil;
	}
}

- (void)_prodPulseTimer
{
	if( !mPulseTimer )
	{
		mPulseTimer = [[NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector( _pulse: ) userInfo: nil repeats: YES] retain];
		[self _pulse: mPulseTimer];
	}
}

- (NSArray *)_timesArray
{
	NSMutableArray *array = [NSMutableArray array];
	
	NSString *curBundleID = [mCurrentApp objectForKey: @"NSApplicationBundleIdentifier"];
	
	NSEnumerator *keyEnum = [mTimes keyEnumerator];
	id key, obj;
	while( ( key = [keyEnum nextObject] ) )
	{
		obj = [mTimes objectForKey: key];
		
		if( [key isEqualToString: curBundleID] )
		{
			NSTimeInterval total = [self _totalAccumulatedTimeUntilTime: [NSDate timeIntervalSinceReferenceDate]];
			total += [obj doubleValue];
			obj = [NSNumber numberWithDouble: total];
		}
		
		[array addObject: [NSDictionary dictionaryWithObjectsAndKeys:
			key, @"bundleID",
			obj, @"time",
			nil]];
	}
	
	return array;
}

- (void)_pulse: (NSTimer *)timer
{
	[mArrayController setContent: [self _timesArray]];
	
	if( [NSDate timeIntervalSinceReferenceDate] - mLastActivityTime > [self _idleInterval] )
	{
		[NSApp setApplicationIconImage: [self _stopImage]];
		[mPulseTimer invalidate];
		[mPulseTimer release];
		mPulseTimer = nil;
		
		mBoredomTimer = [[NSTimer scheduledTimerWithTimeInterval: 30.0 target: self selector: @selector( _bored: ) userInfo: nil repeats: NO] retain];
	}
	else
	{
		[NSApp setApplicationIconImage: [self _goImage]];
	}
}

- (void)_bored: (NSTimer *)timer
{
	NSDisableScreenUpdates();
	[[NSApp windows] makeObjectsPerformSelector: @selector( boidify )];
	NSEnableScreenUpdates();
}

- (void)_upload: (NSTimer *)timer
{
	NSString *strurl = [[NSUserDefaults standardUserDefaults] objectForKey: @"uploadURL"];
	if( strurl )
	{
		NSURL *url = [NSURL URLWithString: strurl];
		if( url )
		{
			NSData *data = [NSPropertyListSerialization dataFromPropertyList: [self _timesArray] format: NSPropertyListXMLFormat_v1_0 errorDescription: NULL];
			
			NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL: url];
			[req setHTTPBody: data];
			[req setHTTPMethod: @"POST"];
			
			[NSURLConnection connectionWithRequest: req delegate: nil];
		}
	}
	
	[self _resetUploadTimer];
}

- (void)_resetUploadTimer
{
	NSTimeInterval interval = [[NSUserDefaults standardUserDefaults] floatForKey: @"uploadInterval"];
	interval = MAX( interval, 60.0 );
	[NSTimer scheduledTimerWithTimeInterval: interval target: self selector: @selector( _upload: ) userInfo: nil repeats: NO];
}

@end

