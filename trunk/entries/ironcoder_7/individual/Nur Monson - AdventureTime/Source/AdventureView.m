//
//  AdventureView.m
//  AdventureTime
//
//  Created by Nur Monson on 11/9/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "AdventureView.h"
#import "Util.h"

@interface NSObject (DelegateMethods)
- (void)adventureViewWantsNextEvent:(AdventureView *)theAdventureView;
- (void)adventureView:(AdventureView *)theAdventureView choiceMade:(NSUInteger)choiceIndex;
@end


@implementation AdventureView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_landscape = [[ATLandscape alloc] init];
		_menu = [[MenuLayer alloc] init];
		_textBox = [[TextBoxLayer alloc] init];
		_cursor = [[CursorLayer alloc] init];
    }
    return self;
}

- (void)dealloc
{
	[_landscape release];
	[_menu release];
	[_textBox release];
	[_cursor release];

	[super dealloc];
}


- (void)awakeFromNib
{
	[self setLayer:_landscape];
	[self setWantsLayer:YES];
	[_landscape addSublayer:_menu];
	_textBox.position = CGPointMake(400.0f, 120.0f);
	[_landscape addSublayer:_textBox];
	
	_cursor.bounds = CGRectMake(0.0f, 0.0f, 15.0f, 15.0f);
	// To hell with the docs. I'm calling display directly because I don't see any other way to make
	// it draw custom graphics with nil contents.
	[_cursor display];
	_cursor.position = CGPointMake(725.0f, 50.0f);
	CABasicAnimation *bounceAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
	bounceAnimation.fromValue = [NSNumber numberWithFloat:100.0f];
	bounceAnimation.toValue = [NSNumber numberWithFloat:50.0f];
	bounceAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	bounceAnimation.duration = 0.5;
	bounceAnimation.autoreverses = YES;
	bounceAnimation.repeatCount = 1e100;
	
	CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
	scaleAnimation.toValue = [NSNumber numberWithFloat:0.7f];
	scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0f];
	scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25f :0.0f :0.75f :0.0f];
	scaleAnimation.duration = 0.5f;
	scaleAnimation.autoreverses = YES;
	scaleAnimation.repeatCount = 1e100;
	[_cursor addAnimation:scaleAnimation forKey:@"scaleAnimation"];
	
	[_landscape addSublayer:_cursor];
	[_cursor addAnimation:bounceAnimation forKey:@"bounceAnimation"];
	_menu.frame = _landscape.bounds;
	_lastKeypressTime = [NSDate timeIntervalSinceReferenceDate];
	
}

- (void)setDelegate:(id)newDelegate
{
	_delegate = newDelegate;
}
- (id)delegate
{
	return _delegate;
}

- (ATLandscape *)landscape
{
	return _landscape;
}

- (TextBoxLayer *)textBox
{
	return _textBox;
}

- (MenuLayer *)menu
{
	return _menu;
}

- (void)clearTextandHideCursor
{
	[_textBox setString:nil];
	[_textBox setName:nil];
	[_cursor setHidden:YES];
}

- (void)setMenuChoices:(NSArray *)newChoices
{
	[_menu setChoices:newChoices];
	if( [_menu choices] )
		[_cursor setHidden:YES];
	else
		[_cursor setHidden:NO];
}

- (NSArray *)menuChoices
{
	return [_menu choices];
}

- (void)setEvent:(AdventureEvent *)newEvent
{
	_landscape.contents = (id)[newEvent background];
	[_landscape npcLeft].contents = (id)[newEvent npcLeft];
	[_landscape npcRight].contents = (id)[newEvent npcRight];
	
	[_textBox setString:[newEvent text]];
	[_textBox setName:[newEvent name]];
	
	// play the sound if there is one.
	[[newEvent sound] stop];
	[[newEvent sound] play];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if( [theEvent isARepeat] || [NSDate timeIntervalSinceReferenceDate]-_lastKeypressTime < 0.1 )
		return;
	// if we're not waiting, then do nothing
	//---------
	// if we don't want a choice made we'll take any key and ask for the next event
	// if we're waiting on a choice then we want the enter key or arrow keys
	unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	if( [_menu choices] ) {
		if( key == NSDownArrowFunctionKey || key == NSRightArrowFunctionKey )
			[_menu selectNext];
		else if( key == NSUpArrowFunctionKey || key == NSLeftArrowFunctionKey )
			[_menu selectPrevious];
		else if( key == NSCarriageReturnCharacter ) {
			if( [_menu choices] && _delegate && [_delegate respondsToSelector:@selector(adventureView:choiceMade:)] )
				[_delegate adventureView:self choiceMade:[_menu selection]];
			else if( [_menu choices] && _delegate && [_delegate respondsToSelector:@selector(adventureView:choiceMade:)] )
				[_delegate adventureViewWantsNextEvent:self];
		}
	} else if( _delegate && [_delegate respondsToSelector:@selector(adventureViewWantsNextEvent:)] )
		[_delegate adventureViewWantsNextEvent:self];
	
	_lastKeypressTime = [NSDate timeIntervalSinceReferenceDate];
}

@end
