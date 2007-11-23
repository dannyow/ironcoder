//
//  ChoiceLayer.m
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "ChoiceLayer.h"


@implementation ChoiceLayer

- (id)init
{
	if( (self = [super init]) ) {
		[self setBounds:CGRectMake(0.0f, 0.0f, 400.0f, 30.0f)];
		self.borderColor = CGColorCreateGenericRGB(0.1f, 0.1f, 0.1f, 0.9f);
		self.borderWidth = 2.0f;
		self.cornerRadius = 10.0f;

		_text = [[CATextLayer alloc] init];
		_text.foregroundColor = CGColorCreateGenericRGB(0.9f, 0.9f, 0.9f, 1.0f);
		_text.fontSize = 20.0f;
		_text.alignmentMode = kCAAlignmentCenter;
		_text.bounds = CGRectMake(0.0f, 0.0f, 400.0f, 25.0f);
		_text.position = CGPointMake(200.0f, 10.0f);
		[self addSublayer:_text];
		[self setSelected:NO];
	}

	return self;
}

- (void)dealloc
{
	[_text release];
	
	[super dealloc];
}

- (CATextLayer *)textLayer;
{
	return _text;
}

- (void)setSelected:(BOOL)willSelect
{
	if( willSelect ) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		self.backgroundColor = CGColorCreateGenericRGB(0.5f, 0.5f, 0.85f, 0.8f);
		_text.foregroundColor = CGColorCreateGenericRGB(1.0f, 1.0f, 1.0f, 1.0f);
		[CATransaction commit];
	} else {
		self.backgroundColor = CGColorCreateGenericRGB(0.2f, 0.2f, 0.2f, 0.5f);
		_text.foregroundColor = CGColorCreateGenericRGB(0.9f, 0.9f, 0.9f, 1.0f);
	}
}
@end
