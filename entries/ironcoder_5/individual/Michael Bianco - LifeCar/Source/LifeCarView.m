//
//  LifeCarView.m
//  LifeCar
//
//  Created by Michael Bianco on 3/30/07.
//  Copyright (c) 2007, Prosit Software. All rights reserved.
//

#import "LifeCarView.h"

#define BASE_SPEED 10

float easeBounce(float t, float b, float c, float d) {
		if ((t/=d) < (1/2.75)) {
		return c*(7.5625*t*t) + b;
	} else if (t < (2/2.75)) {
		return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
	} else if (t < (2.5/2.75)) {
		return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
	} else {
		return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
	}

}

float backEase(float t, float b, float c, float d) {
	//if (s == undefined) s = 1.70158;
	float s = 1.70158;
	
	return c*(t/=d)*t*((s+1)*t - s) + b;
}

float easeEq(float t, float b, float c, float d) {
	return easeBounce(t, b, c, d);
}

@implementation LifeCarView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
		_chocolate = [[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"candy" ofType:@"png"]];
		_imageSize = [_chocolate size];
		
		_sFrame = frame;
		_sFrame.size.width -= _imageSize.width - 40;
		_sFrame.size.height -= _imageSize.height - 40;

		_targetPoint = _currentPoint = NSZeroPoint;
		_targetPoint = NSMakePoint(_sFrame.size.width, _sFrame.size.height/2);
		
		_start = _currentPoint;
		_change = _targetPoint;
		_counter = 0;
		
		_quote = [[NSString stringWithFormat:@"%CLife is like a box of chocolates...\n\t\t\tyou never know what you're gonna get.%C", 0x201C, 0x201D] retain];
		
		srandom(time(NULL));
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void) getTargetPoint {
	NSLog(@"New Target");
	
	NSPoint newPoint = NSZeroPoint;
		
	if(_targetPoint.x == 0) {
		newPoint.x = SSRandomFloatBetween(0, _sFrame.size.width);
		
		if(_change.y > 0) newPoint.y = _sFrame.size.height;
		else newPoint.y = 0;
	} else if(_targetPoint.x == _sFrame.size.width) {
		newPoint.x = random() % (int)_sFrame.size.width;
		
		if(_change.y > 0) newPoint.y = _sFrame.size.height;
		else newPoint.y = 0;
	} else if(_targetPoint.y == 0) {
		newPoint.y = random() % (int)_sFrame.size.height;
		
		if(_change.x > 0) newPoint.x = _sFrame.size.width;
		else newPoint.x = 0;
	} else if(_targetPoint.y == _sFrame.size.height) {
		newPoint.y = random() % (int)_sFrame.size.height;
		
		if(_change.x > 0) newPoint.x = _sFrame.size.width;
		else newPoint.x = 0;
	} else {
		NSLog(@"Uncaught!");
	}
	
	NSLog(@"New Target %@, Current %@", NSStringFromPoint(_targetPoint), NSStringFromPoint(_currentPoint));
	
	_counter = 0;
	_start = _currentPoint;
	_change = NSMakePoint(newPoint.x - _targetPoint.x, newPoint.y - _targetPoint.y);
	_targetPoint = newPoint;
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
	
	
	[[NSColor colorWithDeviceRed:245.0F/255.0
						   green:245.0F/255.0
							blue:230.0F/255.0
						   alpha:1] set];
	
	[NSBezierPath fillRect:[self frame]];
	
	/*
	[[NSColor whiteColor] set];
	
	NSBezierPath *targetVector = [NSBezierPath bezierPath];
	[targetVector moveToPoint:_currentPoint];
	[targetVector lineToPoint:_targetPoint];
	
	[targetVector stroke];
	 */
	
	[_chocolate drawAtPoint:_currentPoint
				   fromRect:NSZeroRect
				  operation:NSCompositeCopy fraction:1.0];
	
	[_quote drawAtPoint:NSMakePoint(300,450)
		 withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor brownColor], NSForegroundColorAttributeName, [NSFont systemFontOfSize:40], NSFontAttributeName, nil]];

}

#define ANI_LEN 200

- (void) animateOneFrame {
	//_currentPoint.x += _motionVector.x;
	//_currentPoint.y += _motionVector.y;
	//_currentPoint.x += (_targetPoint.x - _currentPoint.x)/100;
	//_currentPoint.y += (_targetPoint.y - _currentPoint.y)/100;

	_currentPoint.x = easeEq(++_counter, _start.x, _change.x, ANI_LEN);
	_currentPoint.y = easeEq(_counter, _start.y, _change.y, ANI_LEN);

	[self setNeedsDisplay:YES];
	
	//NSLog(@"%@ : %i : %i", NSStringFromPoint(_targetPoint), abs(_targetPoint.x - _currentPoint.x ), abs(_targetPoint.y - _currentPoint.y));
	if(_counter == ANI_LEN - 10) {
		[self getTargetPoint];
	}
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
