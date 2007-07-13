//
//  QuitterMain.m
//  Quit Beads
//
//  Created by Peter Hosey on 2006-03-05.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#include <Carbon/Carbon.h>

int main(void) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"quit application \"Beads\""];
	NSDictionary *errorDict = nil;
	[script executeAndReturnError:&errorDict];
	[script release];

	[pool release];
	return (errorDict != nil);
}
