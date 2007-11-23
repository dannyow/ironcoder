//
//  LetterLayer.m
//  Arrival
//
//  Created by Ole Zorn on 14.11.07.
//  Copyright 2007 omz:software. All rights reserved.
//

#import "LetterLayer.h"

#define PI 3.14156

@implementation LetterLayer

- (id)init
{
	[super init];
	
	CGColorRef blackColor = CGColorCreateGenericGray(0, 1);
	CGColorRef grayColor = CGColorCreateGenericGray(0.2, 1);
	CGColorRef whiteColor = CGColorCreateGenericGray(1, 1);
	alphabet = [[NSArray arrayWithObjects:@" ", @"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", @"i", @"j", @"k", @"l", @"m", @"n", @"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @" ", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @" ", @".", @",", @":", @"!", @"?", @"(", @")", @"+", @"-", @"&", @"$", @"@", @"#", @"'", @"/", @"\"", @" ", nil] retain];
	alphabetIndex = 0;
	targetLetter = @" ";
	isAnimating = NO;
	self.bounds = CGRectMake(0,0,50,100);
	self.backgroundColor = blackColor;
	self.opaque = YES;
	backLayer1 = [[CALayer layer] retain];
	backLayer1.anchorPoint = CGPointMake(0.5, 0);
	backLayer1.frame = CGRectMake(5, 50, 40, 45);
	backLayer1.borderColor = grayColor;
	backLayer1.borderWidth = 1.0;
	backLayer1.zPosition = -10;
	backLayer1.delegate = self;
	[backLayer1 setValue:[alphabet objectAtIndex:alphabetIndex+1] forKey:@"letter"];
	[backLayer1 setValue:[NSNumber numberWithInt:0] forKey:@"letterPart"];
	backLayer2 = [[CALayer layer] retain];
	backLayer2.anchorPoint = CGPointMake(0.5, 0);
	backLayer2.frame = CGRectMake(5, 5, 40, 45);
	backLayer2.borderColor = grayColor;
	backLayer2.borderWidth = 1.0;
	backLayer2.zPosition = -10;
	backLayer2.delegate = self;
	[backLayer2 setValue:[alphabet objectAtIndex:alphabetIndex] forKey:@"letter"];
	[backLayer2 setValue:[NSNumber numberWithInt:1] forKey:@"letterPart"];
	frontLayer1 = [[CALayer layer] retain];
	frontLayer1.anchorPoint = CGPointMake(0.5, 0);
	frontLayer1.frame = CGRectMake(5, 50, 40, 45);
	frontLayer1.borderColor = grayColor;
	frontLayer1.borderWidth = 1.0;
	frontLayer1.zPosition = 20;
	frontLayer1.delegate = self;
	[frontLayer1 setValue:[alphabet objectAtIndex:alphabetIndex] forKey:@"letter"];
	[frontLayer1 setValue:[NSNumber numberWithInt:0] forKey:@"letterPart"];
	[frontLayer1 display];
	[frontLayer2 display];
	[backLayer1 display];
	[backLayer2 display];
	frontLayer2 = [[CALayer layer] retain];
	frontLayer2.anchorPoint = CGPointMake(0.5, 1);
	frontLayer2.frame = CGRectMake(5, 5, 40, 45);
	frontLayer2.borderColor = grayColor;
	frontLayer2.borderWidth = 1.0;
	frontLayer2.transform = CATransform3DMakeRotation(PI/2, 1, 0, 0);
	frontLayer2.zPosition = 100;
	[frontLayer2 setValue:[alphabet objectAtIndex:alphabetIndex+1] forKey:@"letter"];
	[frontLayer2 setValue:[NSNumber numberWithInt:1] forKey:@"letterPart"];
	frontLayer1.edgeAntialiasingMask = 0;
	frontLayer2.edgeAntialiasingMask = 0;
	frontLayer2.delegate = self;
	[frontLayer2 display];
	[self addSublayer:backLayer1];
	[self addSublayer:backLayer2];
	[self addSublayer:frontLayer2];
	[self addSublayer:frontLayer1];
	CGColorRelease(grayColor);
	CGColorRelease(whiteColor);
	CGColorRelease(blackColor);
	frontLayer1.opaque = YES;
	frontLayer2.opaque = YES;
	backLayer1.opaque = YES;
	backLayer2.opaque = YES;
	return self;
}

- (void)dealloc
{
	[backLayer1 release];
	[backLayer2 release];
	[frontLayer1 release];
	[frontLayer2 release];
	[alphabet release];
	[targetLetter release];
	
	[super dealloc];
}

- (void)animateOneStep
{
	isAnimating = YES;
	CABasicAnimation *animation1 = [[CABasicAnimation animationWithKeyPath:@"transform"] retain];
	animation1.duration = 0.25;
	animation1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	animation1.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(PI/2, 1, 0, 0)];
	animation1.delegate = self;
	animation1.removedOnCompletion = NO;
	animation1.fillMode = kCAFillModeForwards;
	backLayer1.contents = nil;
	[backLayer1 display];
	[frontLayer1 removeAllAnimations];
	[frontLayer1 addAnimation:animation1 forKey:@"flip1"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
	if (theAnimation == [frontLayer1 animationForKey:@"flip1"]) {
		CABasicAnimation *animation2 = [[CABasicAnimation animationWithKeyPath:@"transform"] retain];
		animation2.duration = 0.15;
		animation2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
		animation2.removedOnCompletion = NO;
		animation2.fillMode = kCAFillModeForwards;
		animation2.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(PI*2, 1, 0, 0)];
		animation2.delegate = self;
		frontLayer2.contents = nil;
		[frontLayer2 display];
		frontLayer1.transform = CATransform3DIdentity;
		[frontLayer2 removeAllAnimations];
		[frontLayer2 addAnimation:animation2 forKey:@"flip2"];
	}
	if (theAnimation == [frontLayer2 animationForKey:@"flip2"]) {
		frontLayer2.transform = CATransform3DMakeRotation(PI/2, 1, 0, 0);
		alphabetIndex++;
		if (alphabetIndex > [alphabet count] -2)
			alphabetIndex = 0;
		if (alphabetIndex != 0)
			[frontLayer1 setValue:[alphabet objectAtIndex:alphabetIndex] forKey:@"letter"];
		else
			[frontLayer1 setValue:[alphabet objectAtIndex:[alphabet count]-1] forKey:@"letter"];
		[frontLayer2 setValue:[alphabet objectAtIndex:alphabetIndex+1] forKey:@"letter"];
		[backLayer1 setValue:[alphabet objectAtIndex:alphabetIndex+1] forKey:@"letter"];
		[backLayer2 setValue:[alphabet objectAtIndex:alphabetIndex] forKey:@"letter"];
		frontLayer1.contents = nil;
		[frontLayer1 display];
		backLayer2.contents = nil;
		[backLayer2 display];
		if (![[alphabet objectAtIndex:alphabetIndex] isEqual:targetLetter]) {
			[self animateOneStep];
		}
		else
			isAnimating = NO;
	}
}

- (void)drawLayer:(CALayer *)theLayer inContext:(CGContextRef)ctx
{
	NSGraphicsContext *oldCtx = [NSGraphicsContext currentContext];
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:ctx flipped:NO]];
	NSString *letter = [[theLayer valueForKey:@"letter"] uppercaseString];
	int letterPart = [[theLayer valueForKey:@"letterPart"] intValue];
	NSFont *font = [NSFont fontWithName:@"Monaco" size:60.0];
	NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil];
	NSSize letterSize = [letter sizeWithAttributes:attr];
	NSColor *grayColor = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
	NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[NSColor blackColor] endingColor:grayColor];
	if (letterPart == 1) {
		[gradient drawInRect:NSMakeRect(0,0,40,45) angle:90];
		[letter drawAtPoint:NSMakePoint(20 - letterSize.width/2, 82 - letterSize.height) withAttributes:attr]; 
	}
	else {
		[gradient drawInRect:NSMakeRect(0,0,40,45) angle:270];
		[letter drawAtPoint:NSMakePoint(20 - letterSize.width/2, 37 - letterSize.height) withAttributes:attr]; 
	}
	[gradient release];
	[NSGraphicsContext setCurrentContext:oldCtx];
}

- (void)setInstantLetter:(NSString *)aLetter
{
	[aLetter retain];
	[targetLetter release];
	targetLetter = aLetter;
	if (![alphabet containsObject:targetLetter])
		targetLetter = @"?";
	isAnimating = NO;
	alphabetIndex = [alphabet indexOfObject:aLetter];
	targetLetter = aLetter;
	[frontLayer1 removeAllAnimations];
	[frontLayer2 removeAllAnimations];
	[backLayer1 setValue:[alphabet objectAtIndex:alphabetIndex+1] forKey:@"letter"];
	[backLayer2 setValue:[alphabet objectAtIndex:alphabetIndex] forKey:@"letter"];
	[frontLayer1 setValue:[alphabet objectAtIndex:alphabetIndex] forKey:@"letter"];
	[frontLayer2 setValue:[alphabet objectAtIndex:alphabetIndex+1] forKey:@"letter"];
	frontLayer1.contents = nil;
	frontLayer2.contents = nil;
	backLayer1.contents = nil;
	backLayer2.contents = nil;
	[frontLayer1 display];
	[frontLayer2 display];
	[backLayer1 display];
	[backLayer2 display];
}

- (void)setTargetLetter:(NSString *)aLetter
{
	if ([aLetter isEqual:targetLetter])
		return;
	[aLetter retain];
	[targetLetter release];
	targetLetter = aLetter;
	if (![alphabet containsObject:targetLetter])
		targetLetter = @"?";
	if (!isAnimating)
		[self animateOneStep];
}

@end
