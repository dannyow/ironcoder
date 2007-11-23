//
//  ATLandscape.m
//  AdventureTime
//
//  Created by Nur Monson on 11/9/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ATLandscape.h"


@implementation ATLandscape

- (id)init
{
	if( (self = [super init]) ) {
		_npcRight = nil;
		_textBox = nil;
		[self setContentsGravity:kCAGravityResizeAspectFill];
		self.bounds = CGRectMake(0.0f, 0.0f, 800.0f, 600.0f);
		
		_npcLeft = [[CALayer alloc] init];
		CGRect npcFrame = [self bounds];
		npcFrame.size.width = 400.0f;
		_npcLeft.frame = npcFrame;
		[_npcLeft setContentsGravity:kCAGravityBottomRight];
		[self addSublayer:_npcLeft];
		
		_npcRight = [[CALayer alloc] init];
		npcFrame = [self bounds];
		npcFrame.size.width = 400.0f;
		npcFrame.origin.x = [self bounds].size.width - npcFrame.size.width;
		_npcRight.frame = npcFrame;
		[_npcRight setContentsGravity:kCAGravityBottomRight];
		[self addSublayer:_npcRight];
	}

	return self;
}

- (void)dealloc
{
	[_npcRight release];
	[_npcLeft release];
	[_textBox release];

	[super dealloc];
}

- (CALayer *)npcRight
{
	return _npcRight;
}
- (CALayer *)npcLeft
{
	return _npcLeft;
}

- (void)setTextBox:(CATextLayer *)newTextLayer
{
	// nothing
}
- (CATextLayer *)textBox
{
	return _textBox;
}

@end
