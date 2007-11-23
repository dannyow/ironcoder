//
//  LetterLayer.h
//  Arrival
//
//  Created by Ole Zorn on 14.11.07.
//  Copyright 2007 omz:software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface LetterLayer : CALayer {

	CALayer *backLayer1;
	CALayer *backLayer2;
	CALayer *frontLayer1;
	CALayer *frontLayer2;
	NSArray *alphabet;
	int alphabetIndex;
	NSString *targetLetter;
	BOOL isAnimating;
}

- (void)animateOneStep;
- (void)setTargetLetter:(NSString *)aLetter;
- (void)setInstantLetter:(NSString *)aLetter;


@end
