//
//  IdleChecker.m
//  Sleeper
//
//  Created by Karsten Kusche on 23.01.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "IdleChecker.h"


#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <IOKit/IOKitLib.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

/* 10^9 --  number of ns in a second */
#define NS_SECONDS 1000000000
extern int CGSServerOperationState(int);
int getIdleTime() 
{
	int time;
	mach_port_t masterPort;
	io_iterator_t iter;
	io_registry_entry_t curObj;
	
	IOMasterPort(MACH_PORT_NULL, &masterPort);
	
	/* Get IOHIDSystem */
	IOServiceGetMatchingServices(masterPort,
								 IOServiceMatching("IOHIDSystem"),
								 &iter);
	if (iter == 0) {
		return 0;
	}
	
	curObj = IOIteratorNext(iter);
	
	if (curObj == 0) {
		return 0;
	}
	
	CFMutableDictionaryRef properties = 0;
	CFTypeRef obj;
	
	if (IORegistryEntryCreateCFProperties(curObj, &properties,
										  kCFAllocatorDefault, 0) ==
		KERN_SUCCESS && properties != NULL) {
		
		obj = CFDictionaryGetValue(properties, CFSTR("HIDIdleTime"));
		CFRetain(obj);
	} else {
		obj = NULL;
	}
	
	if (obj) {
		uint64_t tHandle;
		
		CFTypeID type = CFGetTypeID(obj);
		
		if (type == CFDataGetTypeID()) {
			CFDataGetBytes((CFDataRef) obj,
						   CFRangeMake(0, sizeof(tHandle)),
						   (UInt8*) &tHandle);
		}  else if (type == CFNumberGetTypeID()) {
			CFNumberGetValue((CFNumberRef)obj,
							 kCFNumberSInt64Type,
							 &tHandle);
		} else {
			printf("%d: unsupported type\n", (int)type);
			exit(1);
		}
		
		CFRelease(obj);
		
		// essentially divides by 10^9
		tHandle >>= 30;
		time = tHandle;
	}
	
	/* Release our resources */
	IOObjectRelease(curObj);
	IOObjectRelease(iter);
	CFRelease((CFTypeRef)properties);
	return time;
}	

@implementation IdleChecker

- (void)startNewTimer
{
	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkIdletime:) userInfo:nil repeats:NO];
}

- (id)initWithSelector:(SEL)aSelector target:(id)aTarget userData:(id)anObject idleTime:(int)someSeconds
{
	if (self = [super init])
	{
		selector = aSelector;
		target = [aTarget retain];
		userData = [anObject retain];
		idleTime = someSeconds;
		[self startNewTimer];
	}
	return self;
}

- (void)changeIdleTime:(int)seconds
{
	idleTime = seconds;
}

- (int)idleTime
{
//	NSLog(@"idleTime = %i",idleTime);
	return idleTime;
}

+ (id)send:(SEL) selector to:(id) target with:(id)userData afterIdleTimeOf:(int)seconds
{
	return [[self alloc] initWithSelector: selector target:target userData: userData idleTime: seconds];
}

- (void)dealloc
{
	[target release];
	[userData release];
	
	[super dealloc];
}
- (BOOL)anyScreenCaptured
{
	NSEnumerator* screens = [[NSScreen screens] objectEnumerator];
	NSScreen* screen;
	CGDirectDisplayID screenID;
	while (screen = [screens nextObject])
	{
		screenID = (CGDirectDisplayID)[[[screen deviceDescription] objectForKey:@"NSScreenNumber"] intValue];
//		NSLog(@"checking screen: %@ with id: 0x%x",[screen description],screenID);
		if (CGDisplayIsCaptured(screenID))
		 {
			 return YES;
		 }
	}
	return NO;
}

- (void)checkIdletime:(NSTimer*)timer
{
//	NSLog(@"checking time");
	int screenIsCaptured = [self anyScreenCaptured];
//	NSLog(@"captured monitor: 0x%x",serverState);
	int time = getIdleTime();
//	NSLog(@"time = %i",time);
	if (time >= idleTime && ![NSApp isActive] && idleTime && !screenIsCaptured)
	{
		[target performSelector:selector withObject:userData];
	}
	
	[self startNewTimer];
}
@end
