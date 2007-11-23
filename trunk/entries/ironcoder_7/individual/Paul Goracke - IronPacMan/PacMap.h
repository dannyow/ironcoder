//
//  PacMap.h
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

#import <Cocoa/Cocoa.h>
#import "AnimLayer.h"


@interface PacMap : AnimLayer {
	CGColorRef	_wallColor;
	CGColorRef	_bgColor;
	CGFloat _gridWidth;
	
	CALayer * dots;
	CALayer * pills;
	CALayer * walls;
	CALayer * pacMan;
	CALayer * ghostLayer;
	
	NSDictionary * _gridKey;
}

- (id) initWithGridWidth:(CGFloat)width;

- (CGFloat) gridWidth;
- (NSInteger) numRows;
- (NSInteger) numColumns;

// note that (0,0) begins at bottom left
- (NSInteger) valueAtRow:(NSInteger)row andColumn:(NSInteger)column; 
- (NSString *) itemAtRow:(NSInteger)row andColumn:(NSInteger)column; 

- (NSDictionary *) pathOptionsAtRow:(NSInteger)row andColumn:(NSInteger)column;
- (NSDictionary *) shortPathOptionsAtRow:(NSInteger)row 
										 andColumn:(NSInteger)column 
								 exceptDirection:(NSString *)direction;
- (NSInteger) pathInDirection:(NSString *)direction atRow:(NSInteger)row andColumn:(NSInteger)column;
- (NSInteger) shortPathInDirection:(NSString *)direction atRow:(NSInteger)row andColumn:(NSInteger)column;

@end
