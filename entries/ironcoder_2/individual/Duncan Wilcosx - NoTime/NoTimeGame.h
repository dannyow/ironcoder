//
//  NoTimeGame.h
//  NoTime
//
//  Created by Duncan Wilcox on 7/22/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NoTimeGame : NSObject
{
	// game state
	int gamestate;
	
	// threading
	NSConditionLock *playLock;
	NSConditionLock *termLock;
	BOOL done;
	NSMutableDictionary *data;
	NSTimeInterval start;
	NSTimeInterval lastAlpha;
	NSTimeInterval end;
	int lastEventPos;
	float bonus;
	BOOL bonus1taken;
	BOOL bonus2taken;
	BOOL bonus3taken;
	BOOL bonus4taken;
	BOOL IRCMonsterKilled;
	BOOL NewsMonsterKilled;
}

- (void)stop;
- (id)valueForKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;

@end
