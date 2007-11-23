//
//  PacMan.m
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

#import "PacMan.h"

#import "PacMap.h"

@implementation PacMan

- (id) initWithWidth:(CGFloat)width 
				  andMap:(PacMap *)map 
				andSpeed:(CGFloat)speed 
{
	if ( self = [super initWithWidth:width andMap:map andSpeed:speed] ) {
		_fgColor = CGColorCreateGenericRGB( 1.0, 1.0, 0.0, 1.0 );
		
		self.name = @"pacman";
		[self setValue:[NSNumber numberWithBool:YES] forKey:@"startingOffCenter"];
		
		top = [[AnimLayer layer] retain];
		top.name = @"top";
		top.delegate = self;
		top.anchorPoint = CGPointMake( 0.5, 0.5 );
		top.bounds = self.bounds;
		top.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));
		[self addSublayer:top];

		bottom = [[AnimLayer layer] retain];
		bottom.name = @"bottom";
		bottom.delegate = self;
		bottom.anchorPoint = CGPointMake( 0.5, 0.5 );
		bottom.bounds = self.bounds;
		bottom.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds));
		[self addSublayer:bottom];
		
		CGFloat max_mouth = M_PI / 4.0;
		CGFloat min_mouth = M_PI / 50.0;
		[self setValue:[NSNumber numberWithFloat:min_mouth] forKey:@"mouth"];
		
		CABasicAnimation * chompAnimation = [CABasicAnimation animation];
		chompAnimation.keyPath = @"transform.rotation";
		chompAnimation.fromValue = [NSNumber numberWithFloat: max_mouth];
		chompAnimation.toValue = [NSNumber numberWithFloat: min_mouth];
		chompAnimation.duration = 4.0 * [self speed] / [map gridWidth];
		chompAnimation.repeatCount = MAXFLOAT;
		chompAnimation.autoreverses = YES;

		CABasicAnimation * bottomAnimation = [[chompAnimation copyWithZone:NULL] autorelease];
		bottomAnimation.fromValue = [NSNumber numberWithFloat: -max_mouth];
		bottomAnimation.toValue = [NSNumber numberWithFloat: -min_mouth];
		
		[top addAnimation:chompAnimation forKey:@"chompAnimation"];
		[bottom addAnimation:bottomAnimation forKey:@"chompAnimation"];
	}

	return self;
}

- (void) dealloc {
	if ( _fgColor != nil ) {
		CGColorRelease (_fgColor);
	}
	[top release];
	[bottom release];
	[super dealloc];
}

- (void)drawLayer:(CALayer *)theLayer
        inContext:(CGContextRef)ctx
{
	CGFloat mouth_radians = [[self valueForKey:@"mouth"] floatValue];
	
	if ( theLayer == top ) {
		CGContextTranslateCTM( ctx, CGRectGetMidX(theLayer.bounds), CGRectGetMidY(theLayer.bounds) );
		CGContextRotateCTM( ctx, mouth_radians );
		CGContextSetFillColorWithColor(ctx, _fgColor);
		CGContextBeginPath( ctx );
		CGContextMoveToPoint( ctx, 0, 0 );
		CGContextAddArc( ctx, 0, 0, CGRectGetMidX(theLayer.bounds), 0, M_PI * 1.1, 0 );
		CGContextClosePath( ctx );
		CGContextFillPath( ctx );
	}
	else if ( theLayer == bottom ) {
		CGContextTranslateCTM( ctx, CGRectGetMidX(theLayer.bounds), CGRectGetMidY(theLayer.bounds) );
		CGContextRotateCTM( ctx, -mouth_radians );
		CGContextSetFillColorWithColor(ctx, _fgColor);
		CGContextBeginPath( ctx );
		CGContextMoveToPoint( ctx, 0, 0 );
		CGContextAddArc( ctx, 0, 0, CGRectGetMidX(theLayer.bounds), 0, -M_PI * 1.1, 1 );
		CGContextClosePath( ctx );
		CGContextFillPath( ctx );
	}
}

- (void) goDirection:(NSString *)direction {
	CGPoint destination = CGPointMake( self.position.x, self.position.y );
	
	if ( [direction isEqualToString:[self valueForKey:@"currentDirection"]] ) {
		return;
	}
	
	// stop the active animation
	// TODO: stop where actual current position is, instead of jumping to animation end
	[self removeAnimationForKey:@"movement"];
	
	NSInteger col = [[NSNumber numberWithFloat: self.position.x / [_map gridWidth]] integerValue];
	NSInteger row = [[NSNumber numberWithFloat: self.position.y / [_map gridWidth]] integerValue];
	
	NSInteger grids = [_map pathInDirection:direction atRow:row andColumn:col];
	
	NSInteger gridWidth = [_map gridWidth];
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint( path, NULL, self.position.x, self.position.y );
	
	NSInteger gridStep = 0;
	if ( [direction isEqualToString:@"north"] ) {
		for ( gridStep; gridStep < grids; gridStep++ ) {
			destination.y += gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else if ( [direction isEqualToString:@"south"] ) {
		for ( gridStep; gridStep < grids; gridStep++ ) {
			destination.y -= gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else if ( [direction isEqualToString:@"west"] ) {
		if ( [[self valueForKey:@"startingOffCenter"] boolValue] ) {
			// hack for starting position being "between a grid"
			destination.x -= gridWidth / 2.0;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
			[self setValue:[NSNumber numberWithBool:NO] forKey:@"startingOffCenter"];
			gridStep++;
		}
		for ( gridStep; gridStep < grids; gridStep++ ) {
			destination.x -= gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else if ( [direction isEqualToString:@"east"] ) {
		if ( [[self valueForKey:@"startingOffCenter"] boolValue] ) {
			// hack for starting position being "between a grid"
			destination.x += gridWidth / 2.0;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
			[self setValue:[NSNumber numberWithBool:NO] forKey:@"startingOffCenter"];
		}
		
		for ( gridStep; gridStep < grids; gridStep++ ) {
			destination.x += gridWidth;
			CGPathAddLineToPoint( path, NULL, destination.x, destination.y );
		}
	}
	else {
		return;
	}
	
	[self setValue:direction forKey:@"currentDirection"];
	
	CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.path = path;
	animation.duration = grids * gridWidth / [self speed];
	animation.rotationMode = kCAAnimationRotateAuto;
	animation.fillMode = kCAFillModeForwards;
	animation.removedOnCompletion = NO;
	animation.delegate = self;
	animation.calculationMode = kCAAnimationLinear;
	[self addAnimation:animation forKey:@"movement"];
	self.position = destination;
	
	CGPathRelease(path);
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
}

- (void) headNorth {
	[self goDirection:@"north"];
}

- (void) headSouth {
	[self goDirection:@"south"];
}

- (void) headEast {
	[self goDirection:@"east"];
}

- (void) headWest {
	[self goDirection:@"west"];
}

@end
