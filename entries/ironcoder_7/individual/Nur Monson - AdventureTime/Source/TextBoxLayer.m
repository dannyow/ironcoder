//
//  TextBoxLayer.m
//  AdventureTime
//
//  Created by Nur Monson on 11/11/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "TextBoxLayer.h"


@implementation TextBoxLayer

- (id)init
{
	if( (self = [super init]) ) {
		_text = [[CATextLayer alloc] init];
		_text.foregroundColor = CGColorCreateGenericRGB(0.9f, 0.9f, 0.9f, 1.0f);
		_text.fontSize = 20.0f;
		_text.wrapped = YES;
		_text.bounds = CGRectMake(0.0f, 0.0f, 650.0f, 125.0f);
		_text.position = CGPointMake(350.0f, 100.0f);
		
		_textBackground = [[CALayer alloc] init];
		// trying for that FF color (yeah it should be a gradient but that's details)
		_textBackground.backgroundColor = CGColorCreateGenericRGB(0.0f, 0.0f, 0.6f, 0.7f);
		_textBackground.borderWidth = 5.0f;
		_textBackground.borderColor = CGColorCreateGenericRGB(0.7f, 0.7f, 0.7f, 1.0f);
		_textBackground.cornerRadius = 20.0f;
		_textBackground.bounds = CGRectMake(0.0f, 0.0f, 700.0f, 175.0f);
		
		[_textBackground addSublayer:_text];
		
		_name = [[CATextLayer alloc] init];
		_name.fontSize = 21.0f;
		_name.foregroundColor = CGColorCreateGenericRGB(0.9f, 0.9f, 0.9f, 1.0f);
		_name.bounds = CGRectMake(0.0f, 0.0f, 270.0f, 21.0f);
		_name.position = CGPointMake( 150.0f, 20.0f);
		
		_nameBackground = [[CALayer alloc] init];
		_nameBackground.backgroundColor = CGColorCreateGenericRGB(0.0f, 0.0f, 0.6f, 0.7f);
		_nameBackground.borderColor = CGColorCreateGenericRGB(0.7f, 0.7f, 0.7f, 0.7f);
		_nameBackground.borderWidth = 5.0f;
		_nameBackground.cornerRadius = 20.0f;
		_nameBackground.bounds = CGRectMake(0.0f, 0.0f, 250.0f, 40.0f);
		_nameBackground.position = CGPointMake(125.0f, 200.0f);
		
		[_nameBackground addSublayer:_name];
		[_textBackground addSublayer:_nameBackground];
		
		[self addSublayer:_textBackground];
		
	}

	return self;
}

- (void)dealloc
{
	[_text release];
	[_textBackground release];
	[_name release];
	[_nameBackground release];
	
	[_cursor release];

	[super dealloc];
}

- (void)setString:(NSString *)newString
{
	if( [_text.string isEqualToString:newString] )
		return;
	
	if( [newString length] == 0 ) {
		_text.string = nil;
		[self setHidden:YES];
	} else {
		_text.string = newString;
		[self setHidden:NO];
	}
}
- (NSString *)string
{
	return _text.string;
}
- (void)setName:(NSString *)newName
{
	if( [_name.string isEqualToString:newName] )
		return;
	
	_name.string = newName;
	
	if( !_name.string || [_name.string length] == 0 )
		_nameBackground.hidden = YES;
	else
		_nameBackground.hidden = NO;
}
// use this when we have some sort of animated delayed display of text.
// right now we don't
- (BOOL)doneDisplaying
{
	return YES;
}

@end
