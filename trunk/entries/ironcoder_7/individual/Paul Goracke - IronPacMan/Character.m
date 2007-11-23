//
//  Character.m
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

#import "Character.h"

#import "PacMap.h"

@implementation Character

- (id) initWithWidth:(CGFloat)width andMap:(PacMap *)map andSpeed:(CGFloat)speed {
	if ( self = [super init] ) {
		self.bounds = CGRectMake(0.0, 0.0, width, width);
		_map = map;
		_speed = speed;
	}
	
	return self;
}

- (void) dealloc {
	[_map dealloc];
	[super dealloc];
}

- (PacMap *) map {
	return _map;
}

- (CGFloat) speed {
	return _speed;
}

- (void) headNorth {
	
}

- (void) headSouth {
	
}

- (void) headEast {
	
}

- (void) headWest {
	
}

@end
