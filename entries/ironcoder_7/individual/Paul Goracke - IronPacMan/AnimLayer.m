//
//  AnimLayer.m
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

#import "AnimLayer.h"


@implementation AnimLayer

+ (id) defaultValueForKey:(NSString *)key
{
	if ( [key isEqualToString:@"needsDisplayOnBoundsChange"] ) {
		return (id) kCFBooleanTrue;
	}
	
	return [super defaultValueForKey:key];
}

- (void) centerConstrainToLayerNamed:(NSString *)name {
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX relativeTo:name attribute:kCAConstraintMidX]];
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:name attribute:kCAConstraintMidY]];
}

- (void) boundsConstrainToLayerNamed:(NSString *)name {
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:name attribute:kCAConstraintMinX]];
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:name attribute:kCAConstraintMaxX]];
	
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:name attribute:kCAConstraintMinY]];
	[self addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:name attribute:kCAConstraintMaxY]];
}


@end
