//
//  AdventureTimeDelegate.m
//  AdventureTime
//
//  Created by Nur Monson on 11/9/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import "AdventureTimeDelegate.h"


@implementation AdventureTimeDelegate

- (void) awakeFromNib
{
	[_adventureView setDelegate:self];
	
	_gamePath = [[NSBundle mainBundle] pathForResource:@"game" ofType:@"adventure"];
	[_gamePath retain];
	_gameDict = [[NSDictionary alloc] initWithContentsOfFile:[_gamePath stringByAppendingPathComponent:@"game.plist"]];
	
	_scenes = [[NSMutableArray alloc] init];
	NSArray *sceneDictArray = [_gameDict objectForKey:@"scenes"];
	for( NSDictionary *sceneDict in sceneDictArray ) {
		AdventureScene *newScene = [[AdventureScene alloc] initWithDictionary:sceneDict];
		[_scenes addObject:newScene];
		[newScene release];
	}
	
	_currentScene = [_scenes objectAtIndex:0];
	[_currentScene loadResourcesFromPath:_gamePath withMediaDict:nil];
	[[_currentScene song] play];
	AdventureEvent *nextEvent = [_currentScene nextEvent];
	if( !nextEvent )
		printf("no next event\n");
	[_adventureView setEvent:nextEvent];
}

- (void)dealloc
{
	[_gameDict release];
	[_gamePath release];

	[super dealloc];
}

- (void)loadNewScene:(unsigned int)newSceneIndex
{
	[_adventureView setMenuChoices:nil];
	if( newSceneIndex >= [_scenes count] )
		return;
	
	AdventureScene *oldScene = _currentScene;
	_currentScene = [_scenes objectAtIndex:newSceneIndex];
	
	if( _currentScene == oldScene )
		[_currentScene reset];
	else {
		[_currentScene loadResourcesFromPath:_gamePath withMediaDict:[oldScene mediaDict]];
		if( [oldScene song] != [_currentScene song] ) {
			[[oldScene song] stop];
			[[_currentScene song] play];
		}
		[oldScene unloadResources];
	}
	AdventureEvent *nextEvent = [_currentScene nextEvent];
	[_adventureView setEvent:nextEvent];
}

#pragma mark AdventureView Delegate Methods

// called by the view when it wants a new event (i.e. the user clicked the view or pressed a key)
- (void)adventureViewWantsNextEvent:(AdventureView *)theAdventureView
{
	AdventureEvent *nextEvent = [_currentScene nextEvent];
	if( !nextEvent ) {
		// we need to present the user with choices
		// or if there are no choices, we are done. Do nothing and wait for the user to quit.
		NSDictionary *newBranches = [_currentScene branches];
		if( !newBranches ) {
			[_adventureView clearTextandHideCursor];
			return;
		}
		NSArray *newChoices = [newBranches allKeys];
		if( [newChoices count] == 1 ) {
			[self loadNewScene:[[newBranches objectForKey:[newChoices objectAtIndex:0]] unsignedIntValue]];
			return;
		}
		[_adventureView setMenuChoices:newChoices];
	} else {
		[_adventureView setEvent:nextEvent];
	}
}
// the user made a choice
- (void)adventureView:(AdventureView *)theAdventureView choiceMade:(NSUInteger)choiceIndex
{
	NSNumber *sceneIndex = [[_currentScene branches] objectForKey:[[_adventureView menuChoices] objectAtIndex:choiceIndex]];
	[self loadNewScene:[sceneIndex unsignedIntValue]];
	/*
	[_adventureView setMenuChoices:nil];
	if( [sceneIndex unsignedIntValue] >= [_scenes count] )
		return;
	
	QTMovie *oldSong = [_currentScene song];
	AdventureScene *oldScene = _currentScene;
	_currentScene = [_scenes objectAtIndex:[sceneIndex unsignedIntValue]];

	if( _currentScene == oldScene )
		[_currentScene reset];
	else {
		[_currentScene loadResourcesFromPath:_gamePath withMediaDict:[oldScene mediaDict]];
		if( oldSong != [_currentScene song] ) {
			[oldSong stop];
			[[_currentScene song] play];
		}
		[oldScene unloadResources];
	}
	AdventureEvent *nextEvent = [_currentScene nextEvent];
	[_adventureView setEvent:nextEvent];
	 */
}
@end
