//
//  main.m
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-21.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char **argv) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSDictionary *defaultPrefs = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:( 32.0f/255.0f)
																		 green:(149.0f/255.0f)
																		  blue:( 27.0f/255.0f)
																		 alpha:1.0f]],
			@"Foreground color",
		[NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedWhite:0.14f alpha:1.0f]],
			@"Background color",
		nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultPrefs];

	int status = NSApplicationMain(argc, argv);

	[pool release];
	return status;
}
