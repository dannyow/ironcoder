//
//  CWX_MemoryArrayView.m
//  CoreWarX
//
//  Created by Josh Freeman on 11/14/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_MemoryArrayView.h"

@interface CWX_MemoryArrayView (PrivateMethods)

- (void) clearOffscreenImage;

@end


#define kImage_RedExecution						@"red_execution.tif"
#define kImage_RedDie							@"red_die.tif"
#define kImage_RedInstruction					@"red_instruction.tif"
#define kImage_RedInstructionHighlighted		@"red_instruction_hi.tif"
#define kImage_RedData							@"red_dat.tif"
#define kImage_RedDataHighlighted				@"red_dat_hi.tif"
#define kImage_BlueExecution					@"blue_execution.tif"
#define kImage_BlueDie							@"blue_die.tif"
#define kImage_BlueInstruction					@"blue_instruction.tif"
#define kImage_BlueInstructionHighlighted		@"blue_instruction_hi.tif"
#define kImage_BlueData							@"blue_dat.tif"
#define kImage_BlueDataHighlighted				@"blue_dat_hi.tif"
#define kImage_EmptyCell						@"emptycell.tif"

@implementation CWX_MemoryArrayView

- (void) awakeFromNib
{
	short row, col;
	NSRect *currentStoredRect, workingRect;

	program0ExecutionImageRep = [[[NSImage imageNamed: kImage_RedExecution] 
										bestRepresentationForDevice: nil] retain];
										
	program0DieImageRep = [[[NSImage imageNamed: kImage_RedDie] 
										bestRepresentationForDevice: nil] retain];
										
	program0InstructionImageRep = [[[NSImage imageNamed: kImage_RedInstruction] 
										bestRepresentationForDevice: nil] retain];
										
	program0InstructionHighlightedImageRep = [[[NSImage imageNamed: 
															kImage_RedInstructionHighlighted] 
										bestRepresentationForDevice: nil] retain];
										
	program0DataImageRep = [[[NSImage imageNamed: kImage_RedData] 
										bestRepresentationForDevice: nil] retain];
										
	program0DataHighlightedImageRep = [[[NSImage imageNamed: kImage_RedDataHighlighted] 
										bestRepresentationForDevice: nil] retain];
										
	program1ExecutionImageRep = [[[NSImage imageNamed: kImage_BlueExecution] 
										bestRepresentationForDevice: nil] retain];
										
	program1DieImageRep = [[[NSImage imageNamed: kImage_BlueDie] 
										bestRepresentationForDevice: nil] retain];
										
	program1InstructionImageRep = [[[NSImage imageNamed: kImage_BlueInstruction] 
										bestRepresentationForDevice: nil] retain];
										
	program1InstructionHighlightedImageRep = [[[NSImage imageNamed: 
															kImage_BlueInstructionHighlighted] 
										bestRepresentationForDevice: nil] retain];
										
	program1DataImageRep = [[[NSImage imageNamed: kImage_BlueData] 
										bestRepresentationForDevice: nil] retain];
										
	program1DataHighlightedImageRep = [[[NSImage imageNamed: kImage_BlueDataHighlighted] 
										bestRepresentationForDevice: nil] retain];
										
	emptyCellImageRep = [[[NSImage imageNamed: kImage_EmptyCell] 
										bestRepresentationForDevice: nil] retain];
										
	offscreenImage = [[NSImage alloc] initWithSize: NSMakeSize(
									MEMORY_ARRAY_VIEW_ROW_WIDTH * MEMORY_ARRAY_VIEW_CELL_SIZE, 
									MEMORY_ARRAY_VIEW_COL_HEIGHT * MEMORY_ARRAY_VIEW_CELL_SIZE)];
	
	currentStoredRect = &cellBoundsRects[0];
	workingRect = NSMakeRect(0, 
							(MEMORY_ARRAY_VIEW_COL_HEIGHT - 1) * MEMORY_ARRAY_VIEW_CELL_SIZE, 
							MEMORY_ARRAY_VIEW_CELL_SIZE, 
							MEMORY_ARRAY_VIEW_CELL_SIZE);
	
	for (row=0; row<MEMORY_ARRAY_VIEW_COL_HEIGHT; row++)
	{
		workingRect.origin.x = 0;
	
		for (col=0; col<MEMORY_ARRAY_VIEW_ROW_WIDTH; col++)
		{
			*currentStoredRect++ = workingRect;
			workingRect.origin.x += MEMORY_ARRAY_VIEW_CELL_SIZE;
		}
		
		workingRect.origin.y -= MEMORY_ARRAY_VIEW_CELL_SIZE;
	}
																									
	[self clearArray];
}

- (void) clearArray
{
	memset(cellStatus, 0, sizeof(cellStatus));
	[self clearOffscreenImage];
	numHighlightedCells = 0;
	
	[self setNeedsDisplay: YES];
}

- (void) clearOffscreenImage
{
	int row, col;
	NSPoint cellViewCoords;
	
	[offscreenImage lockFocus];
	
	cellViewCoords.y = 0;

	for (row=0; row<=MEMORY_ARRAY_VIEW_COL_HEIGHT; row++)
	{
		cellViewCoords.x = 0;
	
		for (col=0; col<=MEMORY_ARRAY_VIEW_ROW_WIDTH; col++)
		{
			[emptyCellImageRep drawAtPoint: cellViewCoords];
			
			cellViewCoords.x += MEMORY_ARRAY_VIEW_CELL_SIZE;
		}
		
		cellViewCoords.y += MEMORY_ARRAY_VIEW_CELL_SIZE;
	}
	
	[offscreenImage unlockFocus];
}

- (void) resetHighlightsFromPreviousCycle
{
	NSRect *cellBoundsPtr;
	NSImageRep *imageRep = nil;
	short i;

	for (i=0; i<numHighlightedCells; i++)
	{
		switch (cellStatus[highlightedCells[i]])
		{
			case memoryCellStatus_Blank:
				imageRep = emptyCellImageRep;
			break;
		
			case memoryCellStatus_Program0Instruction:
				imageRep = program0InstructionImageRep;
			break;
			
			case memoryCellStatus_Program0Data:
				imageRep = program0DataImageRep;
			break;
			
			case memoryCellStatus_Program1Instruction:
				imageRep = program1InstructionImageRep;
			break;
			
			case memoryCellStatus_Program1Data:
				imageRep = program1DataImageRep;
			break;
		}

		cellBoundsPtr = &cellBoundsRects[highlightedCells[i]];
						   
		[offscreenImage lockFocus];
		[imageRep drawInRect: *cellBoundsPtr];	
		[offscreenImage unlockFocus];

		[self setNeedsDisplayInRect: *cellBoundsPtr];
	}

	numHighlightedCells = 0;
}

- (void) setStatus: (CWX_MemoryCellStatus) status
			forCellAtAddress: (int) address
{
	NSRect *cellBoundsPtr;
	NSImageRep *imageRep = nil;
	
	cellStatus[address] = status;
	
	switch (status)
	{
		case memoryCellStatus_Blank:
			imageRep = emptyCellImageRep;
		break;
	
		case memoryCellStatus_Program0Instruction:
			imageRep = program0InstructionHighlightedImageRep;
		break;
		
		case memoryCellStatus_Program0Data:
			imageRep = program0DataHighlightedImageRep;
		break;
		
		case memoryCellStatus_Program1Instruction:
			imageRep = program1InstructionHighlightedImageRep;
		break;
		
		case memoryCellStatus_Program1Data:
			imageRep = program1DataHighlightedImageRep;
		break;
	}

	cellBoundsPtr = &cellBoundsRects[address];
					   
	[offscreenImage lockFocus];
	[imageRep drawInRect: *cellBoundsPtr];	
	[offscreenImage unlockFocus];

	highlightedCells[numHighlightedCells++] = address;

	[self setNeedsDisplayInRect: *cellBoundsPtr];
}

- (void) highlightExecutionAddress: (int) address
					forProgramNumber: (int) programNumber
					processDied: (bool) didDie
{
	NSRect *cellBoundsPtr;
	NSImageRep *imageRep = nil;
	
	if (programNumber == 0)
	{
		if (didDie)
			imageRep = program0DieImageRep;
		else
			imageRep = program0ExecutionImageRep;
	}
	else
	{
		if (didDie)
			imageRep = program1DieImageRep;
		else
			imageRep = program1ExecutionImageRep;
	}

	cellBoundsPtr = &cellBoundsRects[address];
					   
	[offscreenImage lockFocus];
	[imageRep drawInRect: *cellBoundsPtr];	
	[offscreenImage unlockFocus];

	highlightedCells[numHighlightedCells++] = address;

	[self setNeedsDisplayInRect: *cellBoundsPtr];
}

- (void) drawRect: (NSRect) rect
{
	[offscreenImage drawInRect: rect fromRect: rect operation: NSCompositeCopy fraction: 1.0];
}

@end

