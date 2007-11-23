//
//  AdventureScene.h
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "AdventureEvent.h"

@interface AdventureScene : NSObject {
	NSMutableArray *_events;
	// keeps track of what event the app is playing (only used by player)
	unsigned int _eventIndex;
	
	QTMovie *_song;
	NSString *_songName;
	NSMutableDictionary *_branches;
	NSString *_name;
	
	// stores the list of all media that it has loaded
	NSMutableDictionary *_mediaDict;
}

- (id)initWithDictionary:(NSDictionary *)sceneDict;

// sets the event index to zero
- (void)reset;
- (NSDictionary *)branches;

- (void)unloadResources;
- (void)loadResourcesFromPath:(NSString *)thePath withMediaDict:(NSDictionary *)aMediaDict;
- (NSDictionary *)mediaDict;
- (QTMovie *)song;
- (NSString *)name;

- (void)addBranch:(NSString *)theBranch toScene:(AdventureScene *)newScene;
- (void)removeBranch:(NSString *)branchToRemove;

- (void)addEvent:(AdventureEvent *)newEvent;
- (void)removeEvent:(AdventureEvent *)eventToRemove;
- (NSArray *)events;

// returns nil when no more events are available
- (AdventureEvent *)nextEvent;
@end
