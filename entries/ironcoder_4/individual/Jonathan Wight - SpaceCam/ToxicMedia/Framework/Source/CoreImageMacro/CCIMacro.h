//
//  CCIMacro.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/27/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

/**
 * @class CCIMacro
 * @discussion A CCIMacro class is a customisable graph of nodes comprising CoreImage filters. The code is very experimental and is subject to change.
 */
@interface CCIMacro : CIFilter {
	NSMutableDictionary *inputs;
	NSMutableDictionary *outputs;
	NSMutableArray *nodesList;
	NSMutableDictionary *nodes;

	BOOL inputsChanged;
}

- (void)updateOutputs;

@end
