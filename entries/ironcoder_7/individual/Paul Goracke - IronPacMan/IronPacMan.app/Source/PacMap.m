//
//  PacMap.m
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

#import "PacMap.h"

#import "PacMan.h"
#import "GhostLayer.h"

#define DOTS_ROWS 29
#define DOTS_COLS 26

NSInteger map[DOTS_ROWS][DOTS_COLS] = {
	{  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 },
	{  1, 88, 88, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88, 88, 88,  1 },
	{ 11, 88, 88, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88, 88, 88, 11 },
	{  1, 88, 88, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88, 88, 88,  1 },
	{  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 },
	{  1, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88,  1 },
	{  1, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88,  1 },
	{  1,  1,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1,  1,  1 },
	{ 88, 88, 88, 88, 88,  1, 88, 88, 88, 88, 88,  0, 88, 88,  0, 88, 88, 88, 88, 88,  1, 88, 88, 88, 88, 88 },
	{  0,  0,  0,  0, 88,  1, 88, 88, 88, 88, 88,  0, 88, 88,  0, 88, 88, 88, 88, 88,  1, 88,  0,  0,  0,  0 },
	{  0,  0,  0,  0, 88,  1, 88, 88,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 88, 88,  1, 88,  0,  0,  0,  0 },
	{  0,  0,  0,  0, 88,  1, 88, 88,  0, 88, 88, 88, 88, 88, 88, 88, 88,  0, 88, 88,  1, 88,  0,  0,  0,  0 },
	{ 88, 88, 88, 88, 88,  1, 88, 88,  0, 88,  0,  0,  0,  0,  0,  0, 88,  0, 88, 88,  1, 88, 88, 88, 88, 88 },
	{  0,  0,  0,  0, 88,  1,  0,  0,  0, 88,  0,  0,  0,  0,  0,  0, 88,  0,  0,  0,  1, 88,  0,  0,  0,  0 },
	{ 88, 88, 88, 88, 88,  1, 88, 88,  0, 88,  0,  0,  0,  0,  0,  0, 88,  0, 88, 88,  1, 88, 88, 88, 88, 88 },
	{  0,  0,  0,  0, 88,  1, 88, 88,  0, 88, 88, 88, 88, 88, 88, 88, 88,  0, 88, 88,  1, 88,  0,  0,  0,  0 },
	{  0,  0,  0,  0, 88,  1, 88, 88,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 88, 88,  1, 88,  0,  0,  0,  0 },
	{  0,  0,  0,  0, 88,  1, 88, 88,  0, 88, 88, 88, 88, 88, 88, 88, 88,  0, 88, 88,  1, 88,  0,  0,  0,  0 },
	{ 88, 88, 88, 88, 88,  1, 88, 88,  0, 88, 88, 88, 88, 88, 88, 88, 88,  0, 88, 88,  1, 88, 88, 88, 88, 88 },
	{  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 },
	{  1, 88, 88, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88, 88, 88,  1 },
	{  1, 88, 88, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88,  1, 88, 88, 88, 88,  1 },
	{ 11,  1,  1, 88, 88,  1,  1,  1,  1,  1,  1,  1,  0,  0,  1,  1,  1,  1,  1,  1,  1, 88, 88,  1,  1, 11 },
	{ 88, 88,  1, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88,  1, 88, 88 },
	{ 88, 88,  1, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88,  1, 88, 88 },
	{  1,  1,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1, 88, 88,  1,  1,  1,  1,  1,  1 },
	{  1, 88, 88, 88, 88, 88, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88, 88, 88, 88, 88, 88,  1 },
	{  1, 88, 88, 88, 88, 88, 88, 88, 88, 88, 88,  1, 88, 88,  1, 88, 88, 88, 88, 88, 88, 88, 88, 88, 88,  1 },
	{  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1,  1 }
};

@interface PacMap (PrivateAPI)
- (void) drawDotsInContext:(CGContextRef)ctx;
- (void) drawPillsInContext:(CGContextRef)ctx;
- (void) drawWallsInContext:(CGContextRef)ctx;
@end

@implementation PacMap

- (NSInteger) numRows {
	return DOTS_ROWS;
}

- (NSInteger) numColumns {
	return DOTS_COLS;
}

- (NSInteger) valueAtRow:(NSInteger)row andColumn:(NSInteger)column {
	if ( row < 0 || row >= DOTS_ROWS || column < 0 || column >= DOTS_COLS ) {
		return 999;
	}
	
	return map[DOTS_ROWS - 1 - row][column];
}

- (NSString *) itemAtRow:(NSInteger)row andColumn:(NSInteger)column {
	if ( row < 0 || row >= DOTS_ROWS || column < 0 || column >= DOTS_COLS ) {
		return nil;
	}
	NSInteger val = [self valueAtRow:row andColumn:column];

	return [_gridKey valueForKey:[[NSNumber numberWithInt:val] stringValue]];
}

- (NSDictionary *) pathOptionsAtRow:(NSInteger)row andColumn:(NSInteger)column {
	NSInteger north = 0, south = 0, east = 0, west = 0;
	
	if ( row < DOTS_ROWS ) {
		NSInteger newRow = row;
		BOOL term = NO;
		while ( ! term ) {
			switch ( [self valueAtRow:++newRow andColumn:column] ) {
				case 0:
				case 1:
				case 11:
					++north;
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	if ( row > 0 ) {
		NSInteger newRow = row;
		BOOL term = NO;
		while ( ! term ) {
			switch ( [self valueAtRow:--newRow andColumn:column] ) {
				case 0:
				case 1:
				case 11:
					++south;
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	
	if ( column < DOTS_ROWS ) {
		NSInteger newColumn = column;
		BOOL term = NO;
		while ( ! term ) {
			switch ( [self valueAtRow:row andColumn:++newColumn] ) {
				case 0:
				case 1:
				case 11:
					++east;
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	
	if ( column > 0 ) {
		NSInteger newColumn = column;
		BOOL term = NO;
		while ( ! term ) {
			switch ( [self valueAtRow:row andColumn:--newColumn] ) {
				case 0:
				case 1:
				case 11:
					++west;
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	
	
	NSDictionary * directions = [NSDictionary dictionaryWithObjectsAndKeys:
										  [NSNumber numberWithInt:north], @"north",
										  [NSNumber numberWithInt:south], @"south",
										  [NSNumber numberWithInt:east], @"east",
										  [NSNumber numberWithInt:west], @"west",
										  nil ];
	return directions;
}

- (NSDictionary *) shortPathOptionsAtRow:(NSInteger)row 
										 andColumn:(NSInteger)column 
								 exceptDirection:(NSString *)direction 
{
	NSInteger north = 0, south = 0, east = 0, west = 0;
	if ( row < DOTS_ROWS ) {
		NSInteger newRow = row;
		BOOL term = NO;
		while ( ! term ) {
			NSInteger value = [self valueAtRow:++newRow andColumn:column];
			switch ( value ) {
				case 0:
				case 1:
				case 11:
					++north;
					switch( [self valueAtRow:newRow andColumn:column + 1] ) {
						case 0:
						case 1:
						case 11:
							term = YES;
							break;
						default:
							switch( [self valueAtRow:newRow andColumn:column - 1] ) {
								case 0:
								case 1:
								case 11:
									term=YES;
									break;
								default:
									break;
							}
					}
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	if ( row > 0 ) {
		NSInteger newRow = row;
		BOOL term = NO;
		while ( ! term ) {
			switch ( [self valueAtRow:--newRow andColumn:column] ) {
				case 0:
				case 1:
				case 11:
					++south;
					switch( [self valueAtRow:newRow andColumn:column + 1] ) {
						case 0:
						case 1:
						case 11:
							term = YES;
							break;
						default:
							switch( [self valueAtRow:newRow andColumn:column - 1] ) {
								case 0:
								case 1:
								case 11:
									term=YES;
									break;
								default:
									break;
							}
					}
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	
	if ( column < DOTS_ROWS ) {
		NSInteger newColumn = column;
		BOOL term = NO;
		while ( ! term ) {
			switch ( [self valueAtRow:row andColumn:++newColumn] ) {
				case 0:
				case 1:
				case 11:
					++east;
					switch( [self valueAtRow:row + 1 andColumn:newColumn] ) {
						case 0:
						case 1:
						case 11:
							term = YES;
							break;
						default:
							switch( [self valueAtRow:row - 1 andColumn:newColumn] ) {
								case 0:
								case 1:
								case 11:
									term=YES;
									break;
								default:
									break;
							}
					}
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	
	if ( column > 0 ) {
		NSInteger newColumn = column;
		BOOL term = NO;
		while ( ! term ) {
			switch ( [self valueAtRow:row andColumn:--newColumn] ) {
				case 0:
				case 1:
				case 11:
					++west;
					switch( [self valueAtRow:row + 1 andColumn:newColumn] ) {
						case 0:
						case 1:
						case 11:
							term = YES;
							break;
						default:
							switch( [self valueAtRow:row - 1 andColumn:newColumn] ) {
								case 0:
								case 1:
								case 11:
									term=YES;
									break;
								default:
									break;
							}
					}
					break;
				default:
					term = YES;
					break;
			}
		}
	}
	
	NSMutableDictionary * directions = [NSMutableDictionary dictionary];
	if ( north > 0 && ! [direction isEqualToString:@"south"] ) {
		[directions setValue:[NSNumber numberWithInt:north] forKey:@"north"];
	}
	if ( south > 0 && ! [direction isEqualToString:@"north"]  ) {
		[directions setValue:[NSNumber numberWithInt:south] forKey:@"south"];
	}
	if ( east > 0 && ! [direction isEqualToString:@"west"]  ) {
		[directions setValue:[NSNumber numberWithInt:east] forKey:@"east"];
	}
	if ( west > 0 && ! [direction isEqualToString:@"east"]  ) {
		[directions setValue:[NSNumber numberWithInt:west] forKey:@"west"];
	}
	
	return [[directions copy] autorelease];
}

- (NSInteger) pathInDirection:(NSString *)direction atRow:(NSInteger)row andColumn:(NSInteger)column {
	return [[[self pathOptionsAtRow:row andColumn:column] valueForKey:direction] integerValue];
}

- (NSInteger) shortPathInDirection:(NSString *)direction atRow:(NSInteger)row andColumn:(NSInteger)column {
	return [[[self shortPathOptionsAtRow:row andColumn:column exceptDirection:@""] valueForKey:direction] integerValue];
}

- (id) initWithGridWidth:(CGFloat)width {
	if ( self = [super init] ) {
		_wallColor = CGColorCreateGenericRGB( 0.0, 0.20, 0.875, 1.0 );
		_bgColor = CGColorCreateGenericRGB( 0.0, 0.0, 0.0, 1.0 );

		_gridWidth = width;
		
		_gridKey = [NSDictionary dictionaryWithObjectsAndKeys:
						@"dot", [[NSNumber numberWithInt:1] stringValue], 
						@"pill", [[NSNumber numberWithInt:11] stringValue],
						@"empty", [[NSNumber numberWithInt:0] stringValue], 
						@"wall", [[NSNumber numberWithInt:88] stringValue], 
						nil];
		
		self.name = @"map";
		self.bounds = CGRectMake( 0.0, 0.0, 29.0 * _gridWidth, 32.0 * _gridWidth );
		self.anchorPoint = CGPointMake( 0.5, 0.5 );

		self.layoutManager = [CAConstraintLayoutManager layoutManager];
	}
	
	return self;
}

- (CGFloat) gridWidth {
	return _gridWidth;
}

- (void) dealloc {
	if ( _wallColor != nil ) {
		CGColorRelease (_wallColor);
	}
		
	if ( _bgColor != nil ) {
		CGColorRelease (_bgColor);
	}
		
	[super dealloc];
}

@end
