//
//  HotKey.h
//  GameTest
//
//  Created by Karsten Kusche on 08.11.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
#ifndef __HOTKEY_H_KKS__
#define __HOTKEY_H_KKS__

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


@interface HotKey : NSObject {
	unsigned char charCode;
	unsigned char keyCode;
	unsigned short modifiers;
	EventHotKeyID hotKeyID;
	EventHotKeyRef hotKeyRef;
}

+ (id)fromEvent:(EventRecord)theEvent;
+ (id)hotKeyFromArray:(NSArray*)array;
- (EventHotKeyRef)setWithID:(unsigned int)anID;
- (void)unRegister;
- (NSArray*) asArray;

@end

#endif
