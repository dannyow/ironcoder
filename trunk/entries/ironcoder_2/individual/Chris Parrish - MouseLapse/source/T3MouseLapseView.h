//
//  T3MouseLapseView.h
//  MouseLapse
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class T3RadialShader;

//----- T3MouseMarker
// simple struct to describe each marker

typedef struct
{

	NSPoint		location;
	float		radius;
	float		alpha;
	
} T3MouseMarker;

//------
	
@interface T3MouseLapseView : NSView
{
	T3RadialShader*			fRadialShader;

	NSRect					fScreenRect;
	
	NSPoint					fCurrentMouse;
		// current mouse location in unit coordiantes [ 0.0 : 1.0 ]
	BOOL					fMouseHasMoved;
	
	float					fCurrentRadius;
		// current radius of sphere to draw
	
	int						fNumberOfMarkers;
	T3MouseMarker*			fMarkers;
		// location and attributes of each marker to draw
			
	float					fFillRed;
	float					fFillBlue;
	float					fFillGreen;
}

- (void) updateWithMousePosition:(NSPoint) position;
- (void) setNumberOfMarkers:(int) count;

@end
