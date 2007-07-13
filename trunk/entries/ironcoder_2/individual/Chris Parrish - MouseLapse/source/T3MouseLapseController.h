//
//  T3MouseLapseController.h
//  MouseLapse
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class T3MouseLapseView;

@interface T3MouseLapseController : NSObject
{
	IBOutlet	T3MouseLapseView*		fMainView;
	IBOutlet	NSWindow*				fPreferencesWindow;

				NSTimer*				fTimer;
}

@end
