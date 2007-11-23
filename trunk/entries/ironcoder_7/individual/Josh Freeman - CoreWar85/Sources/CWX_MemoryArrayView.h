//
//  CWX_MemoryArrayView.h
//  CoreWarX
//
//  Created by Josh Freeman on 11/14/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CWX_Defines.h"
#import "CWX_Simulator.h"

typedef enum
{
	memoryCellStatus_Blank,
	memoryCellStatus_Program0Instruction,
	memoryCellStatus_Program0Data,
	memoryCellStatus_Program1Instruction,
	memoryCellStatus_Program1Data

} CWX_MemoryCellStatus;

@interface CWX_MemoryArrayView : NSView 
{
	NSImageRep *program0ExecutionImageRep;
	NSImageRep *program0DieImageRep;
	NSImageRep *program0InstructionImageRep;
	NSImageRep *program0InstructionHighlightedImageRep;
	NSImageRep *program0DataImageRep;
	NSImageRep *program0DataHighlightedImageRep;
	NSImageRep *program1ExecutionImageRep;
	NSImageRep *program1DieImageRep;
	NSImageRep *program1InstructionImageRep;
	NSImageRep *program1InstructionHighlightedImageRep;
	NSImageRep *program1DataImageRep;
	NSImageRep *program1DataHighlightedImageRep;
	NSImageRep *emptyCellImageRep;
	NSImage *offscreenImage;

	unsigned char cellStatus[SIMULATOR_MEMORY_ARRAY_SIZE];
	NSRect cellBoundsRects[SIMULATOR_MEMORY_ARRAY_SIZE];
	
	short highlightedCells[REDCODE_PROGRAM_MAX_NUM_INSTRUCTIONS * 2];
	short numHighlightedCells;
}

- (void) clearArray;

- (void) resetHighlightsFromPreviousCycle;

- (void) setStatus: (CWX_MemoryCellStatus) status
			forCellAtAddress: (int) address;

- (void) highlightExecutionAddress: (int) address
					forProgramNumber: (int) programNumber
					processDied: (bool) didDie;

@end
