//
//  Ghost.m
//  IronPacMan
//
//  Created by Paul Goracke on 11/10/07.
//
//  Copyright (c) 2007 Paul Goracke.
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "Ghost.h"
#import <stdlib.h>

#import "AnimLayer.h"
#import "PacMap.h"

@implementation Ghost

- (id) initWithName:(NSString *)name 
			  andColor:(CGColorRef)color 
			  andWidth:(CGFloat)width 
				 andMap:(PacMap *)map 
			  andSpeed:(CGFloat)speed
{
	if ( self = [super initWithWidth:width andMap:map andSpeed:speed] ) {
		_fgColor = color;
		
		_turn_duration = 0.15;

		self.name = [name copy];
		self.anchorPoint = CGPointMake( 0.5, 0.5 );
		[self setValue:@"" forKey:@"currentDirection"];

		_scale = width / 100.0;

		eyes = [[AnimLayer layer] retain];
		eyes.delegate = self;
		eyes.anchorPoint = CGPointMake( 0.5, 0.5 );
		eyes.position = CGPointMake( 50.0 * _scale, 60.0 * _scale );
		eyes.bounds = CGRectMake( 0.0, 0.0, 50.0 * _scale, 30.0 * _scale );
		[self addSublayer:eyes];
		
		pupils = [[AnimLayer layer] retain];
		pupils.delegate = self;
		pupils.bounds = eyes.bounds;
		pupils.anchorPoint = CGPointMake( 0.5, 0.5 );
		pupils.position = eyes.position;
		[self addSublayer:pupils];
	}
	
	return self;
}

- (void) dealloc {
	if ( _fgColor != nil ) {
		CGColorRelease (_fgColor);
	}
	[pupils release];
	[eyes release];
	[super dealloc];
}

#define EYES_CENTER_X   50.0
#define EYES_CENTER_Y   60.0
#define EYES_ON_CENTERS 24.0

- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)ctx
{

// TODO: rescale because the body no longer does 'inset'
	if ( theLayer == eyes ) {
		CGContextTranslateCTM( ctx, CGRectGetMidX(theLayer.bounds), CGRectGetMidY(theLayer.bounds) );
		CGContextScaleCTM( ctx, _scale, _scale );
		CGContextBeginPath( ctx );
		CGContextSetRGBFillColor( ctx, 1.0, 1.0, 1.0, 1.0 );
		float eyeWidth = 18.0;
		float eyeHeight = 30.0;
		CGContextAddEllipseInRect( ctx, CGRectMake( - (EYES_ON_CENTERS + eyeWidth) / 2.0, -(eyeHeight / 2.0), eyeWidth, eyeHeight ) );
		CGContextAddEllipseInRect( ctx, CGRectMake(   (EYES_ON_CENTERS - eyeWidth) / 2.0, -(eyeHeight / 2.0), eyeWidth, eyeHeight ) );
		CGContextFillPath( ctx );
	}
	else if ( theLayer == pupils ) {
		CGContextTranslateCTM( ctx, CGRectGetMidX(theLayer.bounds), CGRectGetMidY(theLayer.bounds) );
		CGContextScaleCTM( ctx, _scale, _scale );
		CGContextBeginPath( ctx );
		CGContextSetRGBFillColor( ctx, 0.129, 0.129, 0.871, 1.0 );
		float pupilWidth = 10.0;
		CGContextAddArc( ctx, - EYES_ON_CENTERS / 2.0, 0.0, pupilWidth / 2.0, 0.0, 2 * M_PI, 1 );
		CGContextAddArc( ctx,   EYES_ON_CENTERS / 2.0, 0.0, pupilWidth / 2.0, 0.0, 2 * M_PI, 1 );
		CGContextFillPath( ctx );
	}
}

- (void)drawInContext:(CGContextRef)ctx {
	CGRect r = [self bounds];
	float center = r.size.height * 0.5f;
	float radius = center;
	
	// Body
	CGContextSetStrokeColorWithColor(ctx, _fgColor);
	CGContextSetFillColorWithColor(ctx, _fgColor);
	CGContextBeginPath( ctx );
	CGContextMoveToPoint( ctx, 0.0, 0.0 );
	CGContextAddLineToPoint( ctx, 0.0, center );
	CGContextAddArc( ctx, center, center, radius, M_PI, 0, 1 );
	CGContextAddLineToPoint( ctx, r.size.height, 0.0 );
	CGContextFillPath( ctx );
}


- (void) goDirection:(NSString *)direction {
	CGPoint destination = CGPointMake( self.position.x, self.position.y );
	CGPoint eyeDestination, pupilDestination;

	[self removeAnimationForKey:@"movement"];

	NSInteger col = [[NSNumber numberWithFloat: self.position.x / [_map gridWidth]] integerValue];
	NSInteger row = [[NSNumber numberWithFloat: self.position.y / [_map gridWidth]] integerValue];
	
	NSInteger grids = [_map shortPathInDirection:direction atRow:row andColumn:col];
	
	NSInteger gridWidth = [_map gridWidth];
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint( path, NULL, self.position.x, self.position.y );
	NSInteger gridStep = 0;

	if ( [direction isEqualToString:@"north"] ) {
		eyeDestination = CGPointMake( EYES_CENTER_X, EYES_CENTER_Y + 10.0 );
		pupilDestination = CGPointMake( eyeDestination.x, eyeDestination.y + 10.0 );
		for ( gridStep = 0; gridStep < grids; gridStep++ ) {
			destination.y += gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else if ( [direction isEqualToString:@"south"] ) {
		eyeDestination = CGPointMake( EYES_CENTER_X, EYES_CENTER_Y - 5.0 );
		pupilDestination = CGPointMake( eyeDestination.x, eyeDestination.y - 10.0 );
		
		for ( gridStep = 0; gridStep < grids; gridStep++ ) {
			destination.y -= gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else if ( [direction isEqualToString:@"west"] ) {
		eyeDestination = CGPointMake( EYES_CENTER_X - 15.0, EYES_CENTER_Y );
		pupilDestination = CGPointMake( eyeDestination.x - 4.0, eyeDestination.y );
		
		for ( gridStep = 0; gridStep < grids; gridStep++ ) {
			destination.x -= gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else if ( [direction isEqualToString:@"east"] ) {
		eyeDestination = CGPointMake( EYES_CENTER_X + 15.0, EYES_CENTER_Y );
		pupilDestination = CGPointMake( eyeDestination.x + 4.0, eyeDestination.y );
		
		for ( gridStep = 0; gridStep < grids; gridStep++ ) {
			destination.x += gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else {
		return;
	}
	
	eyeDestination.x *= _scale;
	eyeDestination.y *= _scale;
	pupilDestination.x *= _scale;
	pupilDestination.y *= _scale;
	
	[self setValue:direction forKey:@"currentDirection"];
	
	CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.path = path;
	animation.duration = grids * gridWidth / [self speed];
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.delegate = self;
	animation.calculationMode = kCAAnimationLinear;
	[self addAnimation:animation forKey:@"movement"];
	self.position = destination;
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:_turn_duration]
						  forKey:kCATransactionAnimationDuration];
	eyes.position = eyeDestination;
	pupils.position = pupilDestination;
	[CATransaction commit];
	
	CGPathRelease(path);
}

- (void) setInMaze:(BOOL)inMaze {
	srandomdev();

	NSInteger gridWidth = [_map gridWidth];
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint( path, NULL, self.position.x, self.position.y );
	CGPoint destination = CGPointMake( self.position.x, self.position.y );
	
	NSString * direction = @"west";
	if ( (random() % 2) == 0 ) {
		direction = @"east";
		destination.x += 1.5 * gridWidth;
	}
	else {
		destination.x -= 1.5 * gridWidth;
	}
	
	CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
	[self setValue:direction forKey:@"currentDirection"];
	
	CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	
	animation.path = path;
	animation.duration = 1.5 * gridWidth / _speed;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.delegate = self;
	animation.calculationMode = kCAAnimationPaced;
	
	[self addAnimation:animation forKey:@"movement"];
	self.position = destination;
 
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	// hit an intersection. find possible paths without reversing, and randomly pick one
	NSArray * paths = [[_map shortPathOptionsAtRow:[[NSNumber numberWithFloat: self.position.y / [_map gridWidth]] integerValue]
												andColumn:[[NSNumber numberWithFloat: self.position.x / [_map gridWidth]] integerValue]
															exceptDirection:[self valueForKey:@"currentDirection"]]
							  allKeys];
	
	NSString * newDirection = [paths objectAtIndex:random() % [paths count]];
	[self goDirection:newDirection];
}

@end
