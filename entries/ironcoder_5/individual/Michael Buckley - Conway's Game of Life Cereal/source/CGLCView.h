//
//  CGLCView.h
//  Conway's Game of Life Cereal
//
//  Created by Buckley on 3/30/07.
//  Copyright 2007 Michael Buckley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaverView.h>

#define EMPTY_PIECE 0
#define REGULAR_PIECE 1

#define MOUSE_NONE 0
#define MOUSE_ERASE 1
#define MOUSE_DRAW 2

@interface CGLCView : ScreenSaverView {
	BOOL bornRule[8];
	BOOL continueRule[8];
	
	IBOutlet NSButton* born1;
	IBOutlet NSButton* born2;
	IBOutlet NSButton* born3;
	IBOutlet NSButton* born4;
	IBOutlet NSButton* born5;
	IBOutlet NSButton* born6;
	IBOutlet NSButton* born7;
	IBOutlet NSButton* born8;
	
	IBOutlet NSButton* continue1;
	IBOutlet NSButton* continue2;
	IBOutlet NSButton* continue3;
	IBOutlet NSButton* continue4;
	IBOutlet NSButton* continue5;
	IBOutlet NSButton* continue6;
	IBOutlet NSButton* continue7;
	IBOutlet NSButton* continue8;
	
	NSImage* piece;
	BOOL drawGrid;
	
	char** pieces;
	char** neighbors[2];
	char currentNeighbor;
	int generation;
	
	int boardWidth;
	int boardHeight;
	BOOL wrap;
	
	IBOutlet NSWindow* window;
	IBOutlet NSButton* startButton;
	IBOutlet NSSlider* slider;
	IBOutlet NSTextField* speedField;
	IBOutlet NSTextField* generationField;
	
	NSUserDefaults* defaults;
	int speed;
	
	int p1Count;
	IBOutlet NSTextField* p1CountField;
	
	int mouseMode;
	
	IBOutlet NSTextField* preferencesMessage;
	IBOutlet NSButton* wrapPreference;
	IBOutlet NSPopUpButton* flavorPreference;
}

# pragma mark Game Setup
- (IBAction)newSinglePlayerGame:(id)sender;
- (void)createBoardWithWidth:(int)width height:(int)height;
- (void)clearBoard;
- (void)deallocBoard;

#pragma mark Preferences Methods
- (void)readPreferences;
- (IBAction)setWrap:(id)sender;
- (IBAction)setFlavor:(id)sender;
- (IBAction)setBornRule:(id)sender;
- (IBAction)setContinueRule:(id)sender;

#pragma mark Game Logic
- (void)addPieceAtX:(int)x y:(int)y;
- (void)removePieceAtX:(int)x y:(int)y;
- (void)addNeighborAtX:(int)x y:(int)y;
- (void)removeNeighborAtX:(int)x y:(int)y;

#pragma mark File Opening Methods
- (void)openPattern:(id)sender;
- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

#pragma mark File Saving Methods
- (void)savePattern:(id)sender;
- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

- (IBAction)startGame:(id)sender;
- (IBAction)updateSlider:(id)sender;

#pragma mark Misc. IBActions
- (IBAction)openPattern:(id)sender;
- (IBAction)savePattern:(id)sender;

@end
