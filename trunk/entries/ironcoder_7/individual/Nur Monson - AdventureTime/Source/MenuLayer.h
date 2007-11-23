//
//  MenuLayer.h
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QTKit/QTKit.h>
#import "ChoiceLayer.h"

@interface MenuLayer : CALayer {
	NSArray *_choices;
	NSArray *_choiceStrings;
	QTMovie *_selectSound;
	
	int _selection;
}

- (void)setChoices:(NSArray *)newChoices;
- (NSArray *)choices;
- (unsigned int)selection;
- (void)selectNext;
- (void)selectPrevious;
@end
