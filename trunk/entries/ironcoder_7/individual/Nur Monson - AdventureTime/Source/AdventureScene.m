//
//  AdventureScene.m
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "AdventureScene.h"


@implementation AdventureScene

- (id)init
{
	if( (self = [super init]) ) {
		_events = [[NSMutableArray alloc] init];
		_eventIndex = 0;
		_song = nil;
		_name = nil;
		// someone else has to resolve this for us.
		_branches = [[NSMutableDictionary alloc] init];
		_mediaDict = nil;
	}

	return self;
}

- (void)dealloc
{
	[_events release];
	[_branches release];
	[_song release];
	[_songName release];
	[_mediaDict release];
	[_name release];

	[super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)sceneDict
{
	if( (self = [super init]) ) {
		_events = [[NSMutableArray alloc] init];
		_eventIndex = 0;
		_song = nil;
		_songName = [[sceneDict objectForKey:@"song"] retain];
		
		for( NSDictionary *eventDict in (NSArray *)[sceneDict objectForKey:@"events"] ) {
			AdventureEvent *newEvent = [[AdventureEvent alloc] initWithDictionary:eventDict];
			[_events addObject:newEvent];
			[newEvent release];
		}
		if( [_events count] == 0 ) {
			[self release];
			return nil;
		}
		
		_name = [[sceneDict objectForKey:@"name"] retain];
		_branches = nil;
		NSDictionary *branchDict = [sceneDict objectForKey:@"branches"];
		if( branchDict )
			_branches = [[NSMutableDictionary alloc] initWithDictionary:branchDict];
	}
	
	return self;
}

- (void)reset
{
	_eventIndex = 0;
}
- (NSDictionary *)branches
{
	if( !_branches )
		return nil;
	
	return [NSDictionary dictionaryWithDictionary:_branches];
}

- (void)unloadResources
{
	[_song release];
	_song = nil;

	[_mediaDict release];
	_mediaDict = nil;
	
	[_events makeObjectsPerformSelector:@selector(unloadResources)];
}

- (void)loadResourcesFromPath:(NSString *)thePath withMediaDict:(NSDictionary *)aMediaDict
{
	[self unloadResources];
	_mediaDict = [[NSMutableDictionary alloc] init];
	NSMutableDictionary *mergedMediaDict = [[NSMutableDictionary alloc] initWithDictionary:aMediaDict];
	
	if( _songName && [_songName length] > 0 ) {
		_song = [aMediaDict objectForKey:_songName];
		if( !_song ) {
			_song = [[QTMovie alloc] initWithFile:[thePath stringByAppendingPathComponent:_songName] error:nil];
			[_song setMovieAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],QTMovieLoopsAttribute,nil]];
		} else
			[_song retain];
		
		if( _song ) {
			[_mediaDict setObject:_song forKey:_songName];
			[mergedMediaDict setObject:_song forKey:_songName];
		}
	}
	
	for( AdventureEvent *anEvent in _events ) {
		[anEvent loadResourcesFromPath:thePath withMediaDict:mergedMediaDict];
		NSDictionary *eventMedia = [anEvent mediaDict];
		/* add event media contents into both media dictionaries
		 * it's true that we will be setting some objects that are
		 * already in the media dicts, but it doesn't matter because
		 * we're setting them to the same thing. It just makes for easier reading
		 * this way.
		 */
		for( NSString *aKey in [eventMedia allKeys] ) {
			[_mediaDict setObject:[eventMedia objectForKey:aKey] forKey:aKey];
			[mergedMediaDict setObject:[eventMedia objectForKey:aKey] forKey:aKey];
		}
	}
	[mergedMediaDict release];
}
- (NSDictionary *)mediaDict
{
	return [NSDictionary dictionaryWithDictionary:_mediaDict];
}

- (QTMovie *)song
{
	return _song;
}
- (NSString *)name
{
	return _name;
}

- (void)addBranch:(NSString *)theBranch toScene:(AdventureScene *)newScene;
{
	/* I don't see how it would hurt to allow branching to self
	if( newScene == self )
		return;
	 */
	
	[_branches setObject:newScene forKey:theBranch];
}
- (void)removeBranch:(NSString *)branchToRemove;
{
	[_branches removeObjectForKey:branchToRemove];
}

- (void)addEvent:(AdventureEvent *)newEvent
{
	[_events addObject:newEvent];
}
- (void)removeEvent:(AdventureEvent *)eventToRemove
{
	[_events removeObject:eventToRemove];
}
- (NSArray *)events
{
	return [NSArray arrayWithArray:_events];
}

- (AdventureEvent *)nextEvent
{
	if( _eventIndex >= [_events count] )
		return nil;

	AdventureEvent *nextEvent = [_events objectAtIndex:_eventIndex];
	_eventIndex++;
	
	return nextEvent;
}

@end
