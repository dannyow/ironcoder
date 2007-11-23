//
//  SCWindowInfo.h
//  SpaceCommander
//
//  Created by Zac White on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SCWindowInfo : NSObject {
	NSString *owningApplication;
	NSString *owningApplicationPath;
	int owningApplicationPID;
	CGRect bounds;
	int workspace;
	int windowID;
	int windowLevel;
	int windowOrder;
}

@property(copy, readwrite) NSString *owningApplication;
@property(copy, readwrite) NSString *owningApplicationPath;
@property int owningApplicationPID;
@property CGRect bounds;
@property int workspace;
@property int windowID;
@property int windowLevel;
@property int windowOrder;


@end
