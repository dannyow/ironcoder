//
//  CrepuscularLife_Generator.m
//  Crepuscular Life
//
//  Created by Josh Freeman on 3/31/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CrepuscularLife_Generator.h"

#import "CrepuscularLife_UserPrefs.h"

@implementation CREPLIFE_View (LifeGenerator)

- (bool) initializeFirstGeneration;
{
	if (currentGen && nextGen && newCellsVertexArray && stableCellsVertexArray)
	{
		memset((void *) currentGen, 0, numRows * numCols);
		return YES;
	}
	else
		return NO;
}

- (void) nextGeneration
{
	unsigned char *curCell, *curUpCell, *curDownCell, *nextGenCell, *tempGen;
	GLshort row, col;
	int numNeighbors, numGlidersToGenerate;
	GLshort *currentNewCellVertex, *currentStableCellVertex;

	if (gliderFrequencyType == gliderFrequencyTypeGlidersPerGeneration)
		numGlidersToGenerate = glidersPerGeneration;
	else if (!(numGenerations % generationsPerGlider))
		numGlidersToGenerate = 1;
	else
		numGlidersToGenerate = 0;
	
	while (numGlidersToGenerate--)
	{
		curCell = &currentGen[((random() % (numRows-10)) + 5) * numCols 
								+ ((random() % (numCols-10)) + 5)];
		curCell[0] = 1;
		curCell[1] = 1;
		curCell[2] = 1;
		
		switch (random() % 4)
		{
			case 0:
				curCell[numCols] = 1;
				curCell[2*numCols+1] = 1;
			break;
			
			case 1:
				curCell[numCols+2] = 1;
				curCell[2*numCols+1] = 1;
			break;
			
			case 2:
				curCell[-numCols] = 1;
				curCell[-2*numCols+1] = 1;
			break;
			
			case 3:
				curCell[-numCols+2] = 1;
				curCell[-2*numCols+1] = 1;
			break;
		}
	}

	numGenerations++;
	
	currentNewCellVertex = &newCellsVertexArray[0];
	numNewCells = 0;
	
	currentStableCellVertex = &stableCellsVertexArray[0];
	numStableCells = 0;
	
	curUpCell = &currentGen[lastRow * numCols];
	curCell = currentGen;
	curDownCell = &currentGen[numCols];
	
	nextGenCell = nextGen;
	
	// first row, first col

	numNeighbors = curUpCell[lastCol] + curUpCell[0] + curUpCell[1]
					+ curCell[lastCol] + curCell[1]
					+ curDownCell[lastCol] + curDownCell[0] + curDownCell[1];
	
	if (*(curCell++))
	{
		if ((numNeighbors == 2) || (numNeighbors == 3))
		{
			*(nextGenCell++) = 1;
			
			*(currentStableCellVertex++) = 0;
			*(currentStableCellVertex++) = 0;
			numStableCells++;
		}
		else
		{
			*(nextGenCell++) = 0;
		}
	}
	else
	{
		if (numNeighbors == 3)
		{
			*(nextGenCell++) = 1;
			
			*(currentNewCellVertex++) = 0;
			*(currentNewCellVertex++) = 0;
			numNewCells++;
		}
		else
		{
			*(nextGenCell++) = 0;
		}
	}
	
	curUpCell++; curDownCell++;
		
	// rest of first row before last col	
		
	for (col=1; col<lastCol; col++)
	{
		numNeighbors = curUpCell[-1] + curUpCell[0] + curUpCell[1]
						+ curCell[-1] + curCell[1]
						+ curDownCell[-1] + curDownCell[0] + curDownCell[1];
						
		if (*(curCell++))
		{
			if ((numNeighbors == 2) || (numNeighbors == 3))
			{
				*(nextGenCell++) = 1;
				
				*(currentStableCellVertex++) = col;
				*(currentStableCellVertex++) = 0;
				numStableCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		else
		{
			if (numNeighbors == 3)
			{
				*(nextGenCell++) = 1;

				*(currentNewCellVertex++) = col;
				*(currentNewCellVertex++) = 0;
				numNewCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		
		curUpCell++; curDownCell++;
	}
	
	// first row, last col
	numNeighbors = curUpCell[-1] + curUpCell[0] + curUpCell[-lastCol]
					+ curCell[-1] + curCell[-lastCol]
					+ curDownCell[-1] + curDownCell[0] + curDownCell[-lastCol];
					
	if (*(curCell++))
	{
		if ((numNeighbors == 2) || (numNeighbors == 3))
		{
			*(nextGenCell++) = 1;

			*(currentStableCellVertex++) = lastCol;
			*(currentStableCellVertex++) = 0;
			numStableCells++;
		}
		else
		{
			*(nextGenCell++) = 0;
		}
	}
	else
	{
		if (numNeighbors == 3)
		{
			*(nextGenCell++) = 1;

			*(currentNewCellVertex++) = lastCol;
			*(currentNewCellVertex++) = 0;
			numNewCells++;
		}
		else
		{
			*(nextGenCell++) = 0;
		}
	}
	
	curDownCell++;
	curUpCell = &curCell[-numCols];
	
	// middle rows
	for (row=1; row<lastRow; row++)
	{
		// middle rows, first col
	
		numNeighbors = curUpCell[lastCol] + curUpCell[0] + curUpCell[1]
						+ curCell[lastCol] + curCell[1]
						+ curDownCell[lastCol] + curDownCell[0] + curDownCell[1];
						
		if (*(curCell++))
		{
			if ((numNeighbors == 2) || (numNeighbors == 3))
			{
				*(nextGenCell++) = 1;

				*(currentStableCellVertex++) = 0;
				*(currentStableCellVertex++) = row;
				numStableCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		else
		{
			if (numNeighbors == 3)
			{
				*(nextGenCell++) = 1;

				*(currentNewCellVertex++) = 0;
				*(currentNewCellVertex++) = row;
				numNewCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		
		curUpCell++; curDownCell++;
			
		// middle rows, middle cols
			
		for (col=1; col<lastCol; col++)
		{
			numNeighbors = curUpCell[-1] + curUpCell[0] + curUpCell[1]
							+ curCell[-1] + curCell[1]
							+ curDownCell[-1] + curDownCell[0] + curDownCell[1];
							
			if (*(curCell++))
			{
				if ((numNeighbors == 2) || (numNeighbors == 3))
				{
					*(nextGenCell++) = 1;

					*(currentStableCellVertex++) = col;
					*(currentStableCellVertex++) = row;
					numStableCells++;
				}
				else
				{
					*(nextGenCell++) = 0;
				}
			}
			else
			{
				if (numNeighbors == 3)
				{
					*(nextGenCell++) = 1;

					*(currentNewCellVertex++) = col;
					*(currentNewCellVertex++) = row;
					numNewCells++;
				}
				else
				{
					*(nextGenCell++) = 0;
				}
			}
			
			curUpCell++; curDownCell++;
		}
		
		// middle rows, last col
		numNeighbors = curUpCell[-1] + curUpCell[0] + curUpCell[-lastCol]
						+ curCell[-1] + curCell[-lastCol]
						+ curDownCell[-1] + curDownCell[0] + curDownCell[-lastCol];
						
		if (*(curCell++))
		{
			if ((numNeighbors == 2) || (numNeighbors == 3))
			{
				*(nextGenCell++) = 1;

				*(currentStableCellVertex++) = lastCol;
				*(currentStableCellVertex++) = row;
				numStableCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		else
		{
			if (numNeighbors == 3)
			{
				*(nextGenCell++) = 1;

				*(currentNewCellVertex++) = lastCol;
				*(currentNewCellVertex++) = row;
				numNewCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		
		curUpCell++; curDownCell++;
	}
	
	curDownCell = &currentGen[0];
	
	{
		// last row, first col
	
		numNeighbors = curUpCell[lastCol] + curUpCell[0] + curUpCell[1]
						+ curCell[lastCol] + curCell[1]
						+ curDownCell[lastCol] + curDownCell[0] + curDownCell[1];
						
		if (*(curCell++))
		{
			if ((numNeighbors == 2) || (numNeighbors == 3))
			{
				*(nextGenCell++) = 1;

				*(currentStableCellVertex++) = 0;
				*(currentStableCellVertex++) = lastRow;
				numStableCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		else
		{
			if (numNeighbors == 3)
			{
				*(nextGenCell++) = 1;

				*(currentNewCellVertex++) = 0;
				*(currentNewCellVertex++) = lastRow;
				numNewCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		
		curUpCell++; curDownCell++;
			
		// last row, middle cols
			
		for (col=1; col<lastCol; col++)
		{
			numNeighbors = curUpCell[-1] + curUpCell[0] + curUpCell[1]
							+ curCell[-1] + curCell[1]
							+ curDownCell[-1] + curDownCell[0] + curDownCell[1];
							
		if (*(curCell++))
		{
			if ((numNeighbors == 2) || (numNeighbors == 3))
			{
				*(nextGenCell++) = 1;

				*(currentStableCellVertex++) = col;
				*(currentStableCellVertex++) = lastRow;
				numStableCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		else
		{
			if (numNeighbors == 3)
			{
				*(nextGenCell++) = 1;

				*(currentNewCellVertex++) = col;
				*(currentNewCellVertex++) = lastRow;
				numNewCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
			
			curUpCell++; curDownCell++;
		}
		
		// last row, last col
		numNeighbors = curUpCell[-1] + curUpCell[0] + curUpCell[-lastCol]
						+ curCell[-1] + curCell[-lastCol]
						+ curDownCell[-1] + curDownCell[0] + curDownCell[-lastCol];
						
		if (*(curCell++))
		{
			if ((numNeighbors == 2) || (numNeighbors == 3))
			{
				*(nextGenCell++) = 1;

				*(currentStableCellVertex++) = lastCol;
				*(currentStableCellVertex++) = lastRow;
				numStableCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
		else
		{
			if (numNeighbors == 3)
			{
				*(nextGenCell++) = 1;

				*(currentNewCellVertex++) = lastCol;
				*(currentNewCellVertex++) = lastRow;
				numNewCells++;
			}
			else
			{
				*(nextGenCell++) = 0;
			}
		}
	}

	tempGen = nextGen; nextGen = currentGen; currentGen = tempGen;
}

@end
