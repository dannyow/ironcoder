//
//  PacView.m
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

#import "PacView.h"

#import "AnimLayer.h"
#import "PacMap.h"
#import "PacMan.h"
#import "GhostLayer.h"

@interface PacView (PrivateAPI)
- (void) drawDotsInContext:(CGContextRef)ctx;
- (void) drawPillsInContext:(CGContextRef)ctx;
- (void) drawWallsInContext:(CGContextRef)ctx;
@end

@implementation PacView

- (id) initWithFrame:(NSRect)frame {
	if ( self = [super initWithFrame:frame] ) {
		[self setValue:[NSNumber numberWithBool:NO] forKey:@"running"];
		
		[NSCursor setHiddenUntilMouseMoves:YES];
		
		// get key events
		[[self window] makeFirstResponder:self];

		// Initialization code here.
		CALayer * rootLayer = [[CALayer layer] autorelease];
		[self setLayer:rootLayer];
		[self setWantsLayer:YES];

		rootLayer.backgroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0);
		rootLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
		
		pacMap = [[PacMap alloc] initWithGridWidth:20.0];
		pacMap.anchorPoint = CGPointMake( 0.5, 0.5 );
		pacMap.name = @"map";
		[pacMap centerConstrainToLayerNamed:@"superlayer"];
		[rootLayer addSublayer:pacMap];
		
		
		walls = [[AnimLayer layer] retain];
		walls.name = @"walls";
		walls.delegate = self;
		walls.anchorPoint = CGPointMake( 0.5, 0.5 );
		walls.bounds = pacMap.bounds;
		[walls centerConstrainToLayerNamed:@"map"];
		[rootLayer addSublayer:walls];

		dots = [[AnimLayer layer] retain];
		dots.name = @"dots";
		dots.delegate = self;
		dots.anchorPoint = CGPointMake( 0.5, 0.5 );
		dots.bounds = CGRectMake( 0.0, 0.0, [pacMap numColumns] * [pacMap gridWidth], [pacMap numRows] * [pacMap gridWidth] );
		[dots centerConstrainToLayerNamed:@"map"];
		[rootLayer addSublayer:dots];
		
		pills = [[AnimLayer layer] retain];
		pills.name = @"pills";
		pills.delegate = self;
		pills.anchorPoint = CGPointMake( 0.5, 0.5 );
		[pills centerConstrainToLayerNamed:@"dots"];
		[pills boundsConstrainToLayerNamed:@"dots"];
		
		// pulse bloom filter animation shamelessly cribbed from Apple documentation
		// Core Animation Menu Application example
		CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
		[filter setDefaults];
		[filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
		[filter setName:@"pulseFilter"];
		[pills setFilters:[NSArray arrayWithObject:filter]];
		
		CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
		pulseAnimation.keyPath = @"filters.pulseFilter.inputIntensity";
		pulseAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
		pulseAnimation.toValue = [NSNumber numberWithFloat: 1.5];
		pulseAnimation.duration = 1.0;
		pulseAnimation.repeatCount = MAXFLOAT;
		pulseAnimation.autoreverses = YES;
		pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:
													kCAMediaTimingFunctionEaseInEaseOut];
		[pills addAnimation:pulseAnimation forKey:@"pulseAnimation"];
		[rootLayer addSublayer:pills];
		
		pacMan = [[PacMan alloc] initWithWidth:[pacMap gridWidth] * 1.2 andMap:pacMap andSpeed:13.0];
		pacMan.anchorPoint = CGPointMake( 0.5, 0.5 );
		pacMan.position = CGPointMake( 13 * [pacMap gridWidth], 6.5 * [pacMap gridWidth] ); //14.5 * _gridWidth, 8 * _gridWidth );
		[dots addSublayer:pacMan];

		ghostLayer = [[GhostLayer alloc] initWithGhostWidth:[pacMap gridWidth] * 1.2 andMap:pacMap];
		ghostLayer.anchorPoint = CGPointMake( 0.5, 0.5 );
		[ghostLayer centerConstrainToLayerNamed:@"dots"];
		[ghostLayer boundsConstrainToLayerNamed:@"dots"];
		[rootLayer addSublayer:ghostLayer];

		[rootLayer layoutIfNeeded];
    }
	
    return self;
}

- (void) dealloc {
	[pacMan release];
	[ghostLayer release];
	[pacMap release];
	[super dealloc];
}

- (IBAction) run:(id)sender {
	// TODO: actually transition from a stopped to a running state
	[self setValue:[NSNumber numberWithBool:YES] forKey:@"running"];
}

- (BOOL) acceptsFirstResponder {
	return YES;
}

- (void) moveUp:(id)sender {
	[pacMan headNorth];
}

- (void) moveDown:(id)sender {
	[pacMan headSouth];
}

- (void) moveLeft:(id)sender {
	[pacMan headWest];
}

- (void) moveRight:(id)sender {
	[pacMan headEast];
}

- (void) drawLayer:(CALayer *)theLayer
			inContext:(CGContextRef)ctx
{
	if ( theLayer == dots ) {
		[self drawDotsInContext:ctx];
	}
	else if ( theLayer == pills ) {
		[self drawPillsInContext:ctx];
	}
	else if ( theLayer == walls ) {
		[self drawWallsInContext:ctx];
	}
}

- (void) drawDotsInContext:(CGContextRef)ctx {
	NSInteger row, col;
	CGFloat center = [pacMap gridWidth] / 2.0;
	CGFloat radius = 0.1 * [pacMap gridWidth];
	
	// TODO: scale context instead of all the gridWidth multiplications?
	
	CGContextTranslateCTM( ctx, center, center );
	CGContextSetRGBFillColor( ctx, 1.0, 1.0, 1.0, 1.0 );
	CGContextSetRGBStrokeColor( ctx, 1.0, 1.0, 1.0, 1.0 );
	for ( row = 0; row < [pacMap numRows]; ++row ) {
		for ( col = 0; col < [pacMap numColumns]; ++col ) {
			if ( [[pacMap itemAtRow:row andColumn:col] isEqualToString:@"dot"] ) {
				CGContextBeginPath( ctx );
				CGContextAddArc( ctx, col * [pacMap gridWidth], row * [pacMap gridWidth], radius, 0.0, 2 * M_PI, 1 );
				CGContextFillPath( ctx );
			}
		}
	}

}

- (void) drawPillsInContext:(CGContextRef)ctx {
	NSInteger row, col;
	CGFloat center = [pacMap gridWidth] / 2.0;
	CGFloat radius = 0.35 * [pacMap gridWidth];
	
	// TODO: scale context instead of all the gridWidth multiplications?
	
	CGContextTranslateCTM( ctx, center, center );
	CGContextSetRGBFillColor( ctx, 1.0, 1.0, 1.0, 1.0 );
	for ( row = 0; row < [pacMap numRows]; ++row ) {
		for ( col = 0; col < [pacMap numColumns]; ++col ) {
			if ( [[pacMap itemAtRow:row andColumn:col] isEqualToString:@"pill"] ) {
				CGContextBeginPath( ctx );
				CGContextAddArc( ctx, col * [pacMap gridWidth], row * [pacMap gridWidth], radius, 0.0, 2 * M_PI, 1 );
				CGContextFillPath( ctx );
			}
		}
	}
}

- (void) drawWallsInContext:(CGContextRef)ctx {
	CGFloat outRadius = 0.4 * [pacMap gridWidth];
	//	CGFloat inRadius = 3.0;
	CGFloat thinLine = 0.5;
	CGFloat _gridWidth = [pacMap gridWidth];
	
	// TODO: scale context instead of all the gridWidth multiplications?
	
	// Ghost Cage
	CGContextSetAlpha( ctx, 0.7 );
	CGContextSetLineWidth( ctx, 0.2 * [pacMap gridWidth] );
	CGContextSetStrokeColorWithColor( ctx,  CGColorCreateGenericRGB( 1.0, 1.0, 1.0, 1.0 ) );
	CGContextBeginPath( ctx );
	CGContextMoveToPoint( ctx,  13 * _gridWidth, (19 - thinLine / 2.0) * _gridWidth );
	CGContextAddLineToPoint( ctx, 16 * _gridWidth, (19 - thinLine / 2.0) * _gridWidth );
	CGContextStrokePath( ctx );
	
	CGContextSetAlpha( ctx, 1.0 );
	CGContextSetStrokeColorWithColor( ctx, CGColorCreateGenericRGB( 0.0, 0.20, 0.875, 1.0 ) ); //_wallColor );
	CGContextSetLineWidth( ctx, 0.15 * _gridWidth );
	
	CGContextBeginPath( ctx );
	CGContextMoveToPoint(    ctx,  11 * _gridWidth, 15 * _gridWidth );
	CGContextAddLineToPoint( ctx, 18 * _gridWidth, 15 * _gridWidth );
	CGContextAddLineToPoint( ctx, 18 * _gridWidth, 19 * _gridWidth );
	CGContextAddLineToPoint( ctx, 16 * _gridWidth, 19 * _gridWidth );
	CGContextAddLineToPoint( ctx, 16 * _gridWidth, (19 - thinLine) * _gridWidth );
	CGContextAddLineToPoint( ctx, (18 - thinLine) * _gridWidth, (19 - thinLine) * _gridWidth );
	CGContextAddLineToPoint( ctx, (18 - thinLine) * _gridWidth, (15 + thinLine) * _gridWidth );
	CGContextAddLineToPoint( ctx, (11 + thinLine) * _gridWidth, (15 + thinLine) * _gridWidth );
	CGContextAddLineToPoint( ctx, (11 + thinLine) * _gridWidth, (19 - thinLine) * _gridWidth );
	CGContextAddLineToPoint( ctx, 13 * _gridWidth, (19 - thinLine) * _gridWidth );
	CGContextAddLineToPoint( ctx, 13 * _gridWidth, 19 * _gridWidth );
	CGContextAddLineToPoint( ctx, 11 * _gridWidth, 19 * _gridWidth );
	CGContextAddLineToPoint( ctx, 11 * _gridWidth, 15 * _gridWidth );
	CGContextClosePath( ctx );
	CGContextStrokePath( ctx );
	
	// inside walls -- closed shapes
	NSArray * insideWalls = 
	[NSArray arrayWithObjects: 
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(3,3)], 
	  [NSValue valueWithPoint:NSMakePoint(12,3)], 
	  [NSValue valueWithPoint:NSMakePoint(12,4)], 
	  [NSValue valueWithPoint:NSMakePoint(9,4)], 
	  [NSValue valueWithPoint:NSMakePoint(9,7)], 
	  [NSValue valueWithPoint:NSMakePoint(8,7)], 
	  [NSValue valueWithPoint:NSMakePoint(8,4)], 
	  [NSValue valueWithPoint:NSMakePoint(3,4)], 
	  [NSValue valueWithPoint:NSMakePoint(3,3)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(14,3)], 
	  [NSValue valueWithPoint:NSMakePoint(15,3)], 
	  [NSValue valueWithPoint:NSMakePoint(15,6)], 
	  [NSValue valueWithPoint:NSMakePoint(18,6)], 
	  [NSValue valueWithPoint:NSMakePoint(18,7)], 
	  [NSValue valueWithPoint:NSMakePoint(11,7)], 
	  [NSValue valueWithPoint:NSMakePoint(11,6)], 
	  [NSValue valueWithPoint:NSMakePoint(14,6)], 
	  [NSValue valueWithPoint:NSMakePoint(14,3)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(17,3)], 
	  [NSValue valueWithPoint:NSMakePoint(26,3)], 
	  [NSValue valueWithPoint:NSMakePoint(26,4)], 
	  [NSValue valueWithPoint:NSMakePoint(21,4)], 
	  [NSValue valueWithPoint:NSMakePoint(21,7)], 
	  [NSValue valueWithPoint:NSMakePoint(20,7)], 
	  [NSValue valueWithPoint:NSMakePoint(20,4)], 
	  [NSValue valueWithPoint:NSMakePoint(17,4)], 
	  [NSValue valueWithPoint:NSMakePoint(17,3)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(23,6)], 
	  [NSValue valueWithPoint:NSMakePoint(24,6)], 
	  [NSValue valueWithPoint:NSMakePoint(24,9)], 
	  [NSValue valueWithPoint:NSMakePoint(26,9)], 
	  [NSValue valueWithPoint:NSMakePoint(26,10)], 
	  [NSValue valueWithPoint:NSMakePoint(23,10)], 
	  [NSValue valueWithPoint:NSMakePoint(23,6)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(17,9)], 
	  [NSValue valueWithPoint:NSMakePoint(21,9)], 
	  [NSValue valueWithPoint:NSMakePoint(21,10)], 
	  [NSValue valueWithPoint:NSMakePoint(17,10)], 
	  [NSValue valueWithPoint:NSMakePoint(17,9)], 
	  nil],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(8,9)], 
	  [NSValue valueWithPoint:NSMakePoint(12,9)], 
	  [NSValue valueWithPoint:NSMakePoint(12,10)], 
	  [NSValue valueWithPoint:NSMakePoint(8,10)], 
	  [NSValue valueWithPoint:NSMakePoint(8,9)], 
	  nil],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(5,6)], 
	  [NSValue valueWithPoint:NSMakePoint(6,6)], 
	  [NSValue valueWithPoint:NSMakePoint(6,10)], 
	  [NSValue valueWithPoint:NSMakePoint(3,10)], 
	  [NSValue valueWithPoint:NSMakePoint(3,9)], 
	  [NSValue valueWithPoint:NSMakePoint(5,9)], 
	  [NSValue valueWithPoint:NSMakePoint(5,6)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(8,12)], 
	  [NSValue valueWithPoint:NSMakePoint(9,12)], 
	  [NSValue valueWithPoint:NSMakePoint(9,16)], 
	  [NSValue valueWithPoint:NSMakePoint(8,16)], 
	  [NSValue valueWithPoint:NSMakePoint(8,12)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(11,12)], 
	  [NSValue valueWithPoint:NSMakePoint(14,12)], 
	  [NSValue valueWithPoint:NSMakePoint(14,9)], 
	  [NSValue valueWithPoint:NSMakePoint(15,9)], 
	  [NSValue valueWithPoint:NSMakePoint(15,12)],
	  [NSValue valueWithPoint:NSMakePoint(18,12)], 
	  [NSValue valueWithPoint:NSMakePoint(18,13)], 
	  [NSValue valueWithPoint:NSMakePoint(11,13)], 
	  [NSValue valueWithPoint:NSMakePoint(11,12)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(20,12)], 
	  [NSValue valueWithPoint:NSMakePoint(21,12)], 
	  [NSValue valueWithPoint:NSMakePoint(21,16)], 
	  [NSValue valueWithPoint:NSMakePoint(20,16)], 
	  [NSValue valueWithPoint:NSMakePoint(20,12)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(20,18)], 
	  [NSValue valueWithPoint:NSMakePoint(21,18)], 
	  [NSValue valueWithPoint:NSMakePoint(21,25)], 
	  [NSValue valueWithPoint:NSMakePoint(20,25)], 
	  [NSValue valueWithPoint:NSMakePoint(20,22)],
	  [NSValue valueWithPoint:NSMakePoint(17,22)], 
	  [NSValue valueWithPoint:NSMakePoint(17,21)], 
	  [NSValue valueWithPoint:NSMakePoint(20,21)], 
	  [NSValue valueWithPoint:NSMakePoint(20,18)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(14,21)], 
	  [NSValue valueWithPoint:NSMakePoint(15,21)], 
	  [NSValue valueWithPoint:NSMakePoint(15,24)], 
	  [NSValue valueWithPoint:NSMakePoint(18,24)], 
	  [NSValue valueWithPoint:NSMakePoint(18,25)],
	  [NSValue valueWithPoint:NSMakePoint(11,25)], 
	  [NSValue valueWithPoint:NSMakePoint(11,24)], 
	  [NSValue valueWithPoint:NSMakePoint(14,24)], 
	  [NSValue valueWithPoint:NSMakePoint(14,21)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(8,18)], 
	  [NSValue valueWithPoint:NSMakePoint(9,18)], 
	  [NSValue valueWithPoint:NSMakePoint(9,21)], 
	  [NSValue valueWithPoint:NSMakePoint(12,21)], 
	  [NSValue valueWithPoint:NSMakePoint(12,22)],
	  [NSValue valueWithPoint:NSMakePoint(9,22)], 
	  [NSValue valueWithPoint:NSMakePoint(9,25)], 
	  [NSValue valueWithPoint:NSMakePoint(8,25)], 
	  [NSValue valueWithPoint:NSMakePoint(8,18)], 
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(3,24)], 
	  [NSValue valueWithPoint:NSMakePoint(6,24)], 
	  [NSValue valueWithPoint:NSMakePoint(6,25)], 
	  [NSValue valueWithPoint:NSMakePoint(3,25)], 
	  [NSValue valueWithPoint:NSMakePoint(3,24)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(3,27)], 
	  [NSValue valueWithPoint:NSMakePoint(6,27)], 
	  [NSValue valueWithPoint:NSMakePoint(6,29)], 
	  [NSValue valueWithPoint:NSMakePoint(3,29)], 
	  [NSValue valueWithPoint:NSMakePoint(3,27)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(8,27)], 
	  [NSValue valueWithPoint:NSMakePoint(12,27)], 
	  [NSValue valueWithPoint:NSMakePoint(12,29)], 
	  [NSValue valueWithPoint:NSMakePoint(8,29)], 
	  [NSValue valueWithPoint:NSMakePoint(8,27)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(17,27)], 
	  [NSValue valueWithPoint:NSMakePoint(21,27)], 
	  [NSValue valueWithPoint:NSMakePoint(21,29)], 
	  [NSValue valueWithPoint:NSMakePoint(17,29)], 
	  [NSValue valueWithPoint:NSMakePoint(17,27)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(23,27)], 
	  [NSValue valueWithPoint:NSMakePoint(26,27)], 
	  [NSValue valueWithPoint:NSMakePoint(26,29)], 
	  [NSValue valueWithPoint:NSMakePoint(23,29)], 
	  [NSValue valueWithPoint:NSMakePoint(23,27)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(23,24)], 
	  [NSValue valueWithPoint:NSMakePoint(26,24)], 
	  [NSValue valueWithPoint:NSMakePoint(26,25)], 
	  [NSValue valueWithPoint:NSMakePoint(23,25)], 
	  [NSValue valueWithPoint:NSMakePoint(23,24)],
	  nil ],
	 nil];
	
	for ( NSArray * object in insideWalls ) {
		CGContextBeginPath( ctx );
		CGPoint prevPoint = NSPointToCGPoint( (NSPoint)[[object objectAtIndex:0] pointValue] );
		prevPoint.y += 0.5;
		CGContextMoveToPoint( ctx, prevPoint.x * _gridWidth, prevPoint.y * _gridWidth );
		
		for ( NSValue * val in object ) {
			NSPoint point = [val pointValue];
			CGPoint newPoint = NSPointToCGPoint(point);
			CGContextAddArcToPoint( ctx, 
										  prevPoint.x * _gridWidth, prevPoint.y * _gridWidth, 
										  newPoint.x * _gridWidth,  newPoint.y * _gridWidth, 
										  outRadius );
			prevPoint.x = point.x;
			prevPoint.y = point.y;
		}
		CGContextClosePath( ctx );
		CGContextStrokePath( ctx );
	}
	
	// outside lines -- unclosed shapes
	NSArray * outsideLines = 
	[NSArray arrayWithObjects:
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine,16)], 
	  [NSValue valueWithPoint:NSMakePoint(6,16)], 
	  [NSValue valueWithPoint:NSMakePoint(6,12)], 
	  [NSValue valueWithPoint:NSMakePoint(1,12)], 
	  [NSValue valueWithPoint:NSMakePoint(1,7)],
	  [NSValue valueWithPoint:NSMakePoint(3,7)], 
	  [NSValue valueWithPoint:NSMakePoint(3,6)], 
	  [NSValue valueWithPoint:NSMakePoint(1,6)], 
	  [NSValue valueWithPoint:NSMakePoint(1,1)], 
	  [NSValue valueWithPoint:NSMakePoint(28,1)], 
	  [NSValue valueWithPoint:NSMakePoint(28,6)],
	  [NSValue valueWithPoint:NSMakePoint(26,6)],
	  [NSValue valueWithPoint:NSMakePoint(26,7)], 
	  [NSValue valueWithPoint:NSMakePoint(28,7)], 
	  [NSValue valueWithPoint:NSMakePoint(28,12)], 
	  [NSValue valueWithPoint:NSMakePoint(23,12)], 
	  [NSValue valueWithPoint:NSMakePoint(23,16)],
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,16)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine,16 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(6 - thinLine,16 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(6 - thinLine,12 + thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine,12 + thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine,1 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,1 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,12 + thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(23 + thinLine,12 + thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(23 + thinLine,16 - thinLine)],
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,16 - thinLine)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine,18)], 
	  [NSValue valueWithPoint:NSMakePoint(6,18)], 
	  [NSValue valueWithPoint:NSMakePoint(6,22)], 
	  [NSValue valueWithPoint:NSMakePoint(1,22)], 
	  [NSValue valueWithPoint:NSMakePoint(1,31)],
	  [NSValue valueWithPoint:NSMakePoint(14,31)], 
	  [NSValue valueWithPoint:NSMakePoint(14,27)], 
	  [NSValue valueWithPoint:NSMakePoint(15,27)], 
	  [NSValue valueWithPoint:NSMakePoint(15,31)], 
	  [NSValue valueWithPoint:NSMakePoint(28,31)], 
	  [NSValue valueWithPoint:NSMakePoint(28,22)], 
	  [NSValue valueWithPoint:NSMakePoint(23,22)], 
	  [NSValue valueWithPoint:NSMakePoint(23,18)],
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,18)],
	  nil ],
	 [NSArray arrayWithObjects:
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine, 18 + thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(6 - thinLine, 18 + thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(6 - thinLine, 22 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine, 22 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(1 - thinLine, 31 + thinLine)],
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,31 + thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,22 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(23 + thinLine,22 - thinLine)], 
	  [NSValue valueWithPoint:NSMakePoint(23 + thinLine,18 + thinLine)],
	  [NSValue valueWithPoint:NSMakePoint(28 + thinLine,18 + thinLine)],
	  nil ],
	 nil];
	
	for ( NSArray * object in outsideLines ) {
		CGContextBeginPath( ctx );
		CGPoint prevPoint = NSPointToCGPoint( (NSPoint)[[object objectAtIndex:0] pointValue] );
		CGContextMoveToPoint( ctx, prevPoint.x * _gridWidth, prevPoint.y * _gridWidth );
		
		for ( NSValue * val in object ) {
			NSPoint point = [val pointValue];
			CGPoint newPoint = NSPointToCGPoint(point);
			CGContextAddArcToPoint( ctx, 
										  prevPoint.x * _gridWidth, prevPoint.y * _gridWidth, 
										  newPoint.x * _gridWidth,  newPoint.y * _gridWidth, 
										  outRadius );
			prevPoint.x = point.x;
			prevPoint.y = point.y;
		}
		CGContextAddLineToPoint( ctx, prevPoint.x * _gridWidth, prevPoint.y * _gridWidth );
		CGContextStrokePath( ctx );
	}
}


@end
