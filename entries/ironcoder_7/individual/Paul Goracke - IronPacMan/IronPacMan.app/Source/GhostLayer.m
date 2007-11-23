//
//  GhostLayer.m
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

#import "GhostLayer.h"
#import "Ghost.h"
#import "PacMap.h"

@implementation GhostLayer

- (id) initWithGhostWidth:(CGFloat)width andMap:(PacMap *)map {
	if ( self = [super init] ) {
		CGFloat _gridWidth = [map gridWidth];
		clyde = [[Ghost alloc] initWithName:@"clyde" 
											andColor:CGColorCreateGenericRGB( 1.0f, 0.722f, 0.278f, 1.0f )
											andWidth:width
											  andMap:map
											andSpeed:10.0];
		clyde.position = CGPointMake( 13.0 * _gridWidth, 18.5 * _gridWidth ); //15.0 * _gridWidth, 16.0 * _gridWidth );
		[self addSublayer:clyde];
		
		inky = [[Ghost alloc] initWithName:@"inky" 
										  andColor:CGColorCreateGenericRGB( 0.0f, 1.0f, 0.871f, 1.0f )
										  andWidth:width
											 andMap:map
										  andSpeed:11.0];
		inky.position = CGPointMake( 13.0 * _gridWidth, 18.5 * _gridWidth ); //11.0 * _gridWidth, 16.0 * _gridWidth );
		[self addSublayer:inky];
		
		pinky = [[Ghost alloc] initWithName:@"pinky" 
											andColor:CGColorCreateGenericRGB( 1.0f, 0.722f, 0.871f, 1.0f )
											andWidth:width
											  andMap:map
											andSpeed:12.0];
		pinky.position = CGPointMake( 13.0 * _gridWidth, 18.5 * _gridWidth ); //13.0 * _gridWidth, 15.0 * _gridWidth );
		[self addSublayer:pinky];
		
		blinky = [[Ghost alloc] initWithName:@"blinky" 
											 andColor:CGColorCreateGenericRGB( 1.0f, 0.0f, 0.0f, 1.0f )
											 andWidth:width
												andMap:map
											 andSpeed:13.0];
		blinky.position = CGPointMake( 13.0 * _gridWidth, 18.5 * _gridWidth );
		[self addSublayer:blinky];
		[blinky setValue:[NSNumber numberWithBool:YES] forKey:@"inMaze"];
		
		// TODO: bounce them around in the cage for a bit before moving these guys into the maze
		[inky setValue:[NSNumber numberWithBool:YES] forKey:@"inMaze"];
		[pinky setValue:[NSNumber numberWithBool:YES] forKey:@"inMaze"];
		[clyde setValue:[NSNumber numberWithBool:YES] forKey:@"inMaze"];
		
		[self layoutIfNeeded];
	}
	
	return self;
}

- (void) dealloc {
	[blinky release];
	[pinky release];
	[inky release];
	[clyde release];
	[super dealloc];
}
@end
