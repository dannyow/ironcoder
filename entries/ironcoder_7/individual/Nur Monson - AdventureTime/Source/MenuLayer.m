//
//  MenuLayer.m
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "MenuLayer.h"
//#import "QTMovie+ext.h"

@implementation MenuLayer

- (id)init
{
	if( (self = [super init]) ) {
		_choices = nil;
		NSError *error = nil;
		_selectSound = [[QTMovie movieWithFile:@"/System/Library/Sounds/Tink.aiff" error:&error] retain];
		//_selectSound = [[QTMovie movieNamedLikeSound:@"Tink.aiff" error:&error] retain];
	}

	return self;
}

- (void)dealloc
{
	// do I need to remove them from the super layer? I don't think so.
	[_choices release];
	[_choiceStrings release];
	[_selectSound release];

	[super dealloc];
}

- (void)setChoices:(NSArray *)newChoices
{
	if( newChoices == nil ) {
		[_choices makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
		[_choices release];
		_choices = nil;
		[_choiceStrings release];
		_choiceStrings = nil;
		return;
	}
	NSMutableArray *choices = [NSMutableArray array];
	_choiceStrings = [[NSArray alloc] initWithArray:newChoices];
	
	unsigned int choiceIndex;
	for( choiceIndex = 0; choiceIndex < [newChoices count]; choiceIndex++ ) {
		NSString *aChoiceString = [newChoices objectAtIndex:choiceIndex];
		
		ChoiceLayer *aChoice = [ChoiceLayer layer];
		[[aChoice textLayer] setString:aChoiceString];
		
		aChoice.position = CGPointMake(400.0f, 400.0f - 25.0f - 40.0f*(float)choiceIndex);
		[aChoice setDelegate:self];
		
		[choices addObject:aChoice];
		[self addSublayer:aChoice];
	}
	
	[_choices release];
	_choices = [[NSArray alloc] initWithArray:choices];
	_selection = 0;
	[(ChoiceLayer *)[_choices objectAtIndex:_selection] setSelected:YES];
}
- (NSArray *)choices
{
	return _choiceStrings;
}

- (unsigned int)selection
{
	return (unsigned int)_selection;
}

- (void)selectItemAtIndex:(int)newIndex
{
	if( _choices == nil )
		return;
	
	int oldSelection = _selection;
	_selection = newIndex;

	if( _selection >= (int)[_choices count] )
		_selection = 0;
	else if( _selection < 0 )
		_selection = [_choices count]-1;
	
	[(ChoiceLayer *)[_choices objectAtIndex:oldSelection] setSelected:NO];
	[(ChoiceLayer *)[_choices objectAtIndex:_selection] setSelected:YES];
	[_selectSound stop];
	[_selectSound play];
}

- (void)selectNext
{
	[self selectItemAtIndex:_selection+1];
}
- (void)selectPrevious
{
	[self selectItemAtIndex:_selection-1];
}

#pragma mark Delegate Methods

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
	CABasicAnimation *anim = nil;
	if( [_choices containsObject:layer] && [key isEqualToString:kCAOnOrderOut] ) {
		anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
		//anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		anim.duration = 5.0;
		anim.fromValue = [NSNumber numberWithFloat:1.0f];
		anim.toValue = [NSNumber numberWithFloat:0.0f];
		//[layer addAnimation:anim forKey:kCAOnOrderOut];
	}
	return anim;
}
@end
