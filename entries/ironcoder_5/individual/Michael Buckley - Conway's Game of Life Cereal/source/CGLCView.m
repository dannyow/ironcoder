//
//  CGLCView.m
//  Conway's Game of Life Cereal
//
//  Created by Buckley on 3/30/07.
//  Copyright 2007 Michael Buckley. All rights reserved.
//

#import "CGLCView.h"

@implementation CGLCView

- (void)awakeFromNib
{
	drawGrid = YES;
	
	[self readPreferences];
	[speedField setStringValue:[NSString stringWithFormat:@"%d", speed]];
	[slider setIntValue:speed];
	[self newSinglePlayerGame:self];
}

# pragma mark Game Setup

- (void)newSinglePlayerGame:(id)sender
{
	if(pieces != NULL){
		[self deallocBoard];
	}
	p1Count = 0;
	[p1CountField setStringValue:[NSString stringWithFormat:@"%d", p1Count]];
	generation = 0;
	[generationField setStringValue:[NSString stringWithFormat:@"%d", generation]];
	[self createBoardWithWidth:50 height:30];
	wrap = [[defaults objectForKey:@"wrap"] boolValue];
	if([self isAnimating]){
		[self startGame:self];
	}
	
	[self setNeedsDisplay: YES];
}

- (void)createBoardWithWidth:(int)width height:(int)height
{
	boardWidth = width;
	boardHeight = height;
	pieces = (char**) malloc(sizeof(char*) * boardHeight);
    pieces[0] = (char*) malloc(sizeof(char) * (boardWidth * boardHeight));
	neighbors[0] = (char**) malloc(sizeof(char*) * boardHeight);
	neighbors[0][0] = (char*) malloc(sizeof(char) * (boardWidth * boardHeight));
	neighbors[1] = (char**) malloc(sizeof(char*) * boardHeight);
	neighbors[1][0] = (char*) malloc(sizeof(char) * (boardWidth * boardHeight));
	int i;
    for(i = 1; i < boardHeight; ++i){
        pieces[i] = pieces[0] + (i * boardWidth);
		neighbors[0][i] = neighbors[0][0] + (i * boardWidth);
		neighbors[1][i] = neighbors[1][0] + (i * boardWidth);
    }
	[self clearBoard];
}

- (void)clearBoard
{
	int i, j;
	for(i = 0; i < boardHeight; ++i){
		for(j = 0; j < boardWidth; ++j){
			pieces[i][j] = EMPTY_PIECE;
			neighbors[0][i][j] = 0;
			neighbors[1][i][j] = 0;
		}
	}
}

- (void)deallocBoard
{
	free(neighbors[1][0]);
	free(neighbors[1]);
	free(neighbors[0][0]);
	free(neighbors[0]);
	free(pieces[0]);
	free(pieces);
}

#pragma mark Preferences Methods

- (void)readPreferences
{
	defaults = [NSUserDefaults standardUserDefaults];
	
	speed = [[defaults objectForKey:@"speed"] intValue];
	if(speed == nil || speed < 0 || speed > 60){
		speed = 20;
		[defaults setValue:[NSNumber numberWithInt:speed] forKey:@"speed"];
	}
	[self setAnimationTimeInterval:(1.0 / speed)];
	
	wrap = [[defaults objectForKey:@"wrap"] boolValue];
	if(wrap){
		[wrapPreference setState:NSOnState];
	}
	
	NSString* flavor = [defaults objectForKey:@"flavor"];
	if(flavor == nil){
		flavor = @"regular";
		[defaults setObject:flavor forKey:@"flavor"];
	}
	piece = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:flavor ofType:@"png"]];
	[piece retain];
	
	if([flavor isEqualTo:@"cinnamon"]){
		[flavorPreference selectItemAtIndex:1];
	}else if([flavor isEqualTo:@"graham"]){
		[flavorPreference selectItemAtIndex:2];
	}else{
		[flavorPreference selectItemAtIndex:0];
	}
	
	NSNumber* test = [defaults objectForKey:@"born1"];
	if(test == nil){
		bornRule[0] = NO;
		[defaults setObject:[NSNumber numberWithBool:bornRule[0]] forKey:@"born1"];
	}else{
		bornRule[0] = [test boolValue];
		if(bornRule[0]){
			[born1 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"born2"];
	if(test == nil){
		bornRule[1] = NO;
		[defaults setObject:[NSNumber numberWithBool:bornRule[1]] forKey:@"born2"];
	}else{
		bornRule[1] = [test boolValue];
		if(bornRule[1]){
			[born2 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"born3"];
	if(test == nil){
		bornRule[2] = YES;
		[born3 setState:NSOnState];
		[defaults setObject:[NSNumber numberWithBool:bornRule[2]] forKey:@"born3"];
	}else{
		bornRule[2] = [test boolValue];
		if(bornRule[2]){
			[born3 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"born4"];
	if(test == nil){
		bornRule[3] = NO;
		[defaults setObject:[NSNumber numberWithBool:bornRule[3]] forKey:@"born4"];
	}else{
		bornRule[3] = [test boolValue];
		if(bornRule[3]){
			[born4 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"born5"];
	if(test == nil){
		bornRule[4] = NO;
		[defaults setObject:[NSNumber numberWithBool:bornRule[4]] forKey:@"born5"];
	}else{
		bornRule[4] = [test boolValue];
		if(bornRule[4]){
			[born5 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"born6"];
	if(test == nil){
		bornRule[5] = NO;
		[defaults setObject:[NSNumber numberWithBool:bornRule[5]] forKey:@"born6"];
	}else{
		bornRule[5] = [test boolValue];
		if(bornRule[5]){
			[born6 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"born7"];
	if(test == nil){
		bornRule[6] = NO;
		[defaults setObject:[NSNumber numberWithBool:bornRule[6]] forKey:@"born7"];
	}else{
		bornRule[6] = [test boolValue];
		if(bornRule[6]){
			[born7 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"born8"];
	if(test == nil){
		bornRule[7] = NO;
		[defaults setObject:[NSNumber numberWithBool:bornRule[7]] forKey:@"born8"];
	}else{
		bornRule[7] = [test boolValue];
		if(bornRule[7]){
			[born8 setState:NSOnState];
		}
	}
	
	test = [defaults objectForKey:@"continue1"];
	if(test == nil){
		continueRule[0] = NO;
		[defaults setObject:[NSNumber numberWithBool:continueRule[0]] forKey:@"continue1"];
	}else{
		continueRule[0] = [test boolValue];
		if(continueRule[0]){
			[continue1 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"continue2"];
	if(test == nil){
		continueRule[1] = YES;
		[continue2 setState:NSOnState];
		[defaults setObject:[NSNumber numberWithBool:continueRule[1]] forKey:@"continue2"];
	}else{
		continueRule[1] = [test boolValue];
		if(continueRule[1]){
			[continue2 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"continue3"];
	if(test == nil){
		continueRule[2] = YES;
		[continue3 setState:NSOnState];
		[defaults setObject:[NSNumber numberWithBool:continueRule[2]] forKey:@"continue3"];
	}else{
		continueRule[2] = [test boolValue];
		if(continueRule[2]){
			[continue3 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"continue4"];
	if(test == nil){
		continueRule[3] = NO;
		[defaults setObject:[NSNumber numberWithBool:continueRule[3]] forKey:@"continue4"];
	}else{
		continueRule[3] = [test boolValue];
		if(continueRule[3]){
			[continue4 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"continue5"];
	if(test == nil){
		continueRule[4] = NO;
		[defaults setObject:[NSNumber numberWithBool:continueRule[4]] forKey:@"continue5"];
	}else{
		continueRule[4] = [test boolValue];
		if(continueRule[4]){
			[continue5 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"continue6"];
	if(test == nil){
		continueRule[5] = NO;
		[defaults setObject:[NSNumber numberWithBool:continueRule[5]] forKey:@"continue6"];
	}else{
		continueRule[5] = [test boolValue];
		if(continueRule[5]){
			[continue6 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"continue7"];
	if(test == nil){
		continueRule[6] = NO;
		[defaults setObject:[NSNumber numberWithBool:continueRule[6]] forKey:@"continue7"];
	}else{
		continueRule[6] = [test boolValue];
		if(continueRule[6]){
			[continue7 setState:NSOnState];
		}
	}
	test = [defaults objectForKey:@"continue8"];
	if(test == nil){
		continueRule[7] = NO;
		[defaults setObject:[NSNumber numberWithBool:continueRule[7]] forKey:@"continue8"];
	}else{
		continueRule[7] = [test boolValue];
		if(continueRule[7]){
			[continue8 setState:NSOnState];
		}
	}
}

- (IBAction)setWrap:(id)sender
{
	wrap = !wrap;
	[defaults setObject:[NSNumber numberWithBool:wrap] forKey:@"wrap"];
}
- (IBAction)setFlavor:(id)sender
{
	int i = [sender indexOfSelectedItem];
	NSString* flavor;
	if(i == 0) flavor = @"regular";
	if(i == 1) flavor = @"cinnamon";
	if(i == 2) flavor = @"graham";
	
	[piece release];
	piece = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:flavor ofType:@"png"]];
	[piece retain];
	
	[defaults setObject:flavor forKey:@"flavor"];
	[self setNeedsDisplay:YES];
	
}

- (IBAction)setBornRule:(id)sender
{
	NSScanner* scanner = [NSScanner scannerWithString:[sender title]];
	[scanner setScanLocation:0];
	int result;
	[scanner scanInt:&result];
	--result;
	bornRule[result] = !bornRule[result];
	[defaults setObject:[NSNumber numberWithBool:bornRule[result]] forKey:[@"born" stringByAppendingString:[sender title]]];
}

- (IBAction)setContinueRule:(id)sender
{
	NSScanner* scanner = [NSScanner scannerWithString:[sender title]];
	[scanner setScanLocation:0];
	int result;
	[scanner scanInt:&result];
	--result;
	continueRule[result] = !continueRule[result];
	[defaults setObject:[NSNumber numberWithBool:continueRule[result]] forKey:[@"continue" stringByAppendingString:[sender title]]];
}

#pragma mark Game Logic

- (void)animateOneFrame
{
	p1Count = 0;
	int oldNeighbor = currentNeighbor;
	++currentNeighbor;
	currentNeighbor %= 2;
	int i, j;
	for(i = 0; i < boardHeight; ++i){
		for(j = 0; j < boardWidth; ++j){
			if(pieces[i][j] != EMPTY_PIECE){
				[self addPieceAtX:j y:i];
			}
			if((neighbors[oldNeighbor][i][j] > 0) && (bornRule[neighbors[oldNeighbor][i][j] -1] == YES)){
				if(pieces[i][j] == EMPTY_PIECE){
					[self addPieceAtX:j y:i];
				}else if(continueRule[neighbors[oldNeighbor][i][j] -1] == NO){
					[self removePieceAtX:j y:i];
				}
			}else if((neighbors[oldNeighbor][i][j] > 0) && (continueRule[neighbors[oldNeighbor][i][j] -1] == NO)){
				if(pieces[i][j] != EMPTY_PIECE){
					[self removePieceAtX:j y:i];
				}
			}else if(neighbors[oldNeighbor][i][j] <= 0){
				if(pieces[i][j] != EMPTY_PIECE){
					[self removePieceAtX:j y:i];
				}
			}
			if(pieces[i][j] != EMPTY_PIECE){
				++p1Count;
			}
			neighbors[oldNeighbor][i][j] = 0;
		}
	}
	
	[p1CountField setStringValue:[NSString stringWithFormat:@"%d", p1Count]];
	++generation;
	[generationField setStringValue:[NSString stringWithFormat:@"%d", generation]];
	[self setNeedsDisplay:YES];
}

- (void)addPieceAtX:(int)x y:(int)y
{
	if(x < 0){
		if(wrap){
			x += boardWidth;
		}else{
			return;
		}
	}
	if(x >= boardWidth){
		if(wrap){
			x %= boardWidth;
		}else{
			return;
		}
	}
	if(y < 0){
		if(wrap){
			y += boardHeight;
		}else{
			return;
		}
	}
	if(y >= boardHeight){
		if(wrap){
			y %= boardHeight;
		}else{
			return;
		}
	}
	
	pieces[y][x] = REGULAR_PIECE;
	int i, j;
	for(i = x - 1; i < x + 2; ++i){
		for(j = y - 1; j < y + 2; ++j){
			if(!(i == x && j == y)){
				[self addNeighborAtX:i y:j];
			}
		}
	}
}

- (void)removePieceAtX:(int)x y:(int)y
{
	if(x < 0){
		if(wrap){
			x += boardWidth;
		}else{
			return;
		}
	}
	if(x >= boardWidth){
		if(wrap){
			x %= boardWidth;
		}else{
			return;
		}
	}
	if(y < 0){
		if(wrap){
			y += boardHeight;
		}else{
			return;
		}
	}
	if(y >= boardHeight){
		if(wrap){
			y %= boardHeight;
		}else{
			return;
		}
	}
	
	pieces[y][x] = EMPTY_PIECE;
	int i, j;
	for(i = x - 1; i < x + 2; ++i){
		for(j = y - 1; j < y + 2; ++j){
			if(!(i == x && j == y)){
				[self removeNeighborAtX:i y:j];
			}
		}
	}
}

- (void)addNeighborAtX:(int)x y:(int)y
{
	if(x < 0){
		if(wrap){
			x += boardWidth;
		}else{
			return;
		}
	}
	if(x >= boardWidth){
		if(wrap){
			x %= boardWidth;
		}else{
			return;
		}
	}
	if(y < 0){
		if(wrap){
			y += boardHeight;
		}else{
			return;
		}
	}
	if(y >= boardHeight){
		if(wrap){
			y %= boardHeight;
		}else{
			return;
		}
	}
	
	++neighbors[currentNeighbor][y][x];
}

- (void)removeNeighborAtX:(int)x y:(int)y
{
	if(x < 0){
		if(wrap){
			x += boardWidth;
		}else{
			return;
		}
	}
	if(x >= boardWidth){
		if(wrap){
			x %= boardWidth;
		}else{
			return;
		}
	}
	if(y < 0){
		if(wrap){
			y += boardHeight;
		}else{
			return;
		}
	}
	if(y >= boardHeight){
		if(wrap){
			y %= boardHeight;
		}else{
			return;
		}
	}
	
	if(neighbors[currentNeighbor][y][x] != 0){
		--neighbors[currentNeighbor][y][x];
	}
}


#pragma mark NSView Methods

- (void)drawRect:(NSRect)rect
{
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	int i, j;
	for(i = 0; i < 800; i+= 16){
		for(j = 0; j < 480; j += 16){
			if(pieces[j / 16][i / 16] != EMPTY_PIECE){
				[piece drawAtPoint:NSMakePoint(i, j) fromRect:NSMakeRect(0, 0, 16, 16) operation:NSCompositeSourceOver fraction:1.0];
			}
			if(drawGrid){
				[[NSColor blackColor] set];
				NSRect r = NSMakeRect(i, j, 16, 16);
				NSFrameRectWithWidth(r, 0.5);
			}
		}
	}
}

- (BOOL)isOpaque
{
	return YES;
}

- (BOOL)wantsDefaultClipping
{
    return NO;
}

- (void)mouseDown:(NSEvent*) event
{
	if([self isAnimating]){
		return;
	}
	
	NSPoint eventLocation = [event locationInWindow];
	eventLocation = [self convertPoint:eventLocation fromView:nil];
	int x = eventLocation.x / 16;
	int y = eventLocation.y / 16;
	eventLocation.x = x * 16;
	eventLocation.y = y * 16 + 8;
	
	if(mouseMode == MOUSE_NONE){
		if(pieces [y][x] == EMPTY_PIECE){
			mouseMode = MOUSE_DRAW;
		}else{
			mouseMode = MOUSE_ERASE;
		}
	}
	
	if(mouseMode == MOUSE_ERASE){
		if(pieces [y][x] != EMPTY_PIECE){
			[self removePieceAtX:x y:y];
			--p1Count;
		}
	}else if(mouseMode == MOUSE_DRAW){
		if(pieces [y][x] == EMPTY_PIECE){
			[self addPieceAtX:x y:y];
			++p1Count;
		}
	}
	
	[p1CountField setStringValue:[NSString stringWithFormat:@"%d", p1Count]];
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent*) event
{
	mouseMode = 0;
}

- (void)mouseDragged:(NSEvent*) event
{
	[self mouseDown:event];
}

#pragma mark File Opening Methods

- (void)openPattern:(id)sender
{
	if([self isAnimating]){
		NSAlert* alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not open pattern."];
		[alert setInformativeText:@"You can not open patters while they are running."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:window modalDelegate:self
						 didEndSelector:nil
							contextInfo:nil];
	}
	
	NSOpenPanel* openPanel = [[NSOpenPanel openPanel] retain];
	[openPanel setExtensionHidden:YES];
	[openPanel setRequiredFileType:@"pattern"];
	[openPanel beginSheetForDirectory:nil
								 file:@"Untitled"
					   modalForWindow:window modalDelegate:self
					   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
						  contextInfo:nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSOKButton){
		FILE* f = fopen([[sheet filename] UTF8String], "r");
		if(f == NULL){
			NSAlert* alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Could not open pattern."];
			[alert setInformativeText:@"Could not open the file for reading."];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert beginSheetModalForWindow:window modalDelegate:self
							 didEndSelector:nil
								contextInfo:nil];
		}
		
		[self clearBoard];
		p1Count = 0;
		[p1CountField setStringValue:[NSString stringWithFormat:@"%d", p1Count]];
		generation = 0;
		[generationField setStringValue:[NSString stringWithFormat:@"%d", generation]];
		
		int i, j;
		for(i = 0; i < boardHeight; ++i){
			for(j = 0; j < boardWidth; ++j){
				char c = fgetc(f);
				if(c){
					[self addPieceAtX:j y:i];
				}
			}
		}
		fclose(f);
		[self setNeedsDisplay:YES];
	}
}

#pragma mark File Saving Methods

- (void)savePattern:(id)sender
{
	if([self isAnimating]){
		NSAlert* alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Could not save pattern."];
		[alert setInformativeText:@"You can not save patters while they are running."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:window modalDelegate:self
						 didEndSelector:nil
							contextInfo:nil];
	}
	
	NSSavePanel* savePanel = [[NSSavePanel savePanel] retain];
	[savePanel setExtensionHidden:YES];
	[savePanel setRequiredFileType:@"pattern"];
	[savePanel beginSheetForDirectory:nil
								 file:@"Untitled"
					   modalForWindow:window modalDelegate:self
					   didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
						  contextInfo:nil];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if(returnCode == NSOKButton){
		FILE* f = fopen([[sheet filename] UTF8String], "w");
		if(f == NULL){
			NSAlert* alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Could not save pattern."];
			[alert setInformativeText:@"Could not open the file for writing."];
			[alert setAlertStyle:NSWarningAlertStyle];
			[alert beginSheetModalForWindow:window modalDelegate:self
							 didEndSelector:nil
								contextInfo:nil];
		}
		
		int i, j;
		for(i = 0; i < boardHeight; ++i){
			for(j = 0; j < boardWidth; ++j){
				fputc(pieces[i][j], f);
			}
		}
		fclose(f);
	}
}

#pragma mark Misc. IBActions

- (IBAction)startGame:(id)sender
{	
	if([self isAnimating]){
		[self stopAnimation];
		drawGrid = YES;
		[startButton setTitle:@"Start"];
		
		[preferencesMessage setHidden:YES];
		[wrapPreference setEnabled:YES];
		[flavorPreference setEnabled:YES];
		
		[born1 setEnabled:YES];
		[born2 setEnabled:YES];
		[born3 setEnabled:YES];
		[born4 setEnabled:YES];
		[born5 setEnabled:YES];
		[born6 setEnabled:YES];
		[born7 setEnabled:YES];
		[born8 setEnabled:YES];
		
		[continue1 setEnabled:YES];
		[continue2 setEnabled:YES];
		[continue3 setEnabled:YES];
		[continue4 setEnabled:YES];
		[continue5 setEnabled:YES];
		[continue6 setEnabled:YES];
		[continue7 setEnabled:YES];
		[continue8 setEnabled:YES];
		
		[self setNeedsDisplay:YES];
	}else{
		[self startAnimation];
		drawGrid = NO;
		
		[preferencesMessage setHidden:NO];
		[wrapPreference setEnabled:NO];
		[flavorPreference setEnabled:NO];
		
		[born1 setEnabled:NO];
		[born2 setEnabled:NO];
		[born3 setEnabled:NO];
		[born4 setEnabled:NO];
		[born5 setEnabled:NO];
		[born6 setEnabled:NO];
		[born7 setEnabled:NO];
		[born8 setEnabled:NO];
		
		[continue1 setEnabled:NO];
		[continue2 setEnabled:NO];
		[continue3 setEnabled:NO];
		[continue4 setEnabled:NO];
		[continue5 setEnabled:NO];
		[continue6 setEnabled:NO];
		[continue7 setEnabled:NO];
		[continue8 setEnabled:NO];
		
		[startButton setTitle:@"Stop"];
	}
}

- (void)updateSlider:(id)sender
{
	speed = [sender floatValue];
	[self setAnimationTimeInterval:(1.0 / speed)];
	[speedField setStringValue:[NSString stringWithFormat:@"%d", speed]];
	[defaults setValue:[NSNumber numberWithInt:speed] forKey:@"speed"];
}

#pragma mark NSApplication Delegates

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
	return YES;
}

#pragma mark NSWindow Delegates

- (BOOL)windowShouldClose:(id)sender
{
	NSAlert* alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"OK"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Are you sure you want to quit?."];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	if([alert runModal] == NSAlertSecondButtonReturn)
	{
		return NO;
	}else{
		return YES;
	}
}

@end
