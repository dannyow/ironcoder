//
//  CrepuscularLife_View.h
//  Crepuscular Life
//
//  Created by Josh Freeman on 3/31/07.
//  Copyright (c) 2007, Twilight Edge Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>

@class CREPLIFE_GLView, CREPLIFE_OptionsController;

@interface CREPLIFE_View : ScreenSaverView 
{
	CREPLIFE_GLView *glView;
	bool animating;
	
	int numRows;
	int numCols;
	
	int lastRow;
	int lastCol;
	
	int gradientHeight;
	
	int glidersPerGeneration;
	int generationsPerGlider;
	int gliderFrequencyType;

	int generationSpeed;
	
	unsigned char *currentGen;
	unsigned char *nextGen;
	
	GLshort *newCellsVertexArray;
	GLsizei numNewCells;
	
	GLshort *stableCellsVertexArray;
	GLsizei numStableCells;

	unsigned long numGenerations;
	
	ScreenSaverDefaults *userPrefs;
	CREPLIFE_OptionsController *optionsController;
}

@end
