//
//  MyDeskView.h


#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreImage.h>


@class MyFile, MyController; 

@interface MyDeskView : NSView {
	
	MyController *controller;
	
	NSArray *currentFiles; //All the file information for the directory 
	MyFile *clickedFile; //The last clicked file
	NSSize deltaOriginFromClick;  //to offset the origin from the click of the mouse so dragging looks good
	
	CIFilter *transitionFilter;  //Filter to aniamte transitions
	int timerFiredCount;  //timer count

	BOOL mouseBeingDragged, quitting;
	
	//Header objects and location of those objects
	NSImage *pumpkinArrow;
	NSMutableDictionary *titleAtributtes, *directoryAtributtes;
	NSBezierPath *lineUnderTitle;
	NSRect titleRect, directoryRect, pumpkinArrowRect;
}


@end
