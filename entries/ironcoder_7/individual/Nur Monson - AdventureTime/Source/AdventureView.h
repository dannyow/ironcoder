//
//  AdventureView.h
//  AdventureTime
//
//  Created by Nur Monson on 11/9/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "ATLandscape.h"
#import "MenuLayer.h"
#import "TextBoxLayer.h"
#import "CursorLayer.h"
#import "AdventureEvent.h"

CGImageRef loadImageOfTypeFromMainBundle(NSString *filename, NSString *type);

@interface AdventureView : NSView {
	ATLandscape *_landscape;
	MenuLayer *_menu;
	TextBoxLayer *_textBox;
	CursorLayer *_cursor;
	

	NSTimeInterval _lastKeypressTime;
	id _delegate;
}

- (void)setDelegate:(id)newDelegate;
- (id)delegate;

- (ATLandscape *)landscape;
- (MenuLayer *)menu;
- (TextBoxLayer *)textBox;

- (void)clearTextandHideCursor;
- (void)setMenuChoices:(NSArray *)newChoices;
- (NSArray *)menuChoices;

- (void)setEvent:(AdventureEvent *)newEvent;
@end
