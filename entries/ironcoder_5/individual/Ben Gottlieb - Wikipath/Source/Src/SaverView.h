//
//  SaverView.h
//  TestScreenSaver
//
//  Created by Ben Gottlieb on 3/31/07.
//  Copyright (c) 2007, Stand Alone, Inc.. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

typedef enum {
	linkDirFrom_Left,
	linkDirFrom_Above,
	linkDirFrom_Right,
	linkDirFrom_Below,
	linkDirFrom_None
} linkDirFrom;


@interface WikiPathScreenSaver_imageCell : NSObject {
	NSRect					bounds;
	NSImage					*image;
	linkDirFrom				fromDir;
}

- (id) initWithImage: (NSImage *) newImage frame: (NSRect) newBounds fromDir: (linkDirFrom) dir;
- (void) drawInParent;
- (void) updateImageFromView: (NSView *) view proportionally: (BOOL) proportional;

@end

@interface WikiPathScreenSaver_SaverView : ScreenSaverView 
{
	IBOutlet NSWindow				*configSheet;
	IBOutlet NSMatrix				*deadEndMatrix;
	IBOutlet NSMatrix				*initialTileMatrix;
	IBOutlet NSPopUpButton			*sizePopup;
	IBOutlet NSTextField			*initialTileField;
	IBOutlet NSSlider				*intervalSlider;
	
	NSMutableArray					*displayedPages;
	NSMutableArray					*imageCells;
	WikiPathScreenSaver_imageCell	**cellArray;
	NSPoint							currentFocusCell;
	float							squareSize, cellsAcross, cellsDown, leftOffset, topOffset;
	BOOL							pathTerminated;
	
	WebView							*webView;
	WikiPathScreenSaver_imageCell	*currentImageCell;
	NSString						*currentURL;
	BOOL							currentLoadStarted;
	NSArray							*currentLinks;
	NSString						*languagePrefix;
	
	NSDate							*nextResetTime;
	
	BOOL							inTestHarness;
	BOOL							inPreview;
}

- (IBAction) cancelClick: (id) sender;
- (IBAction) okClick: (id) sender;
- (IBAction) initialTileChanged: (id) sender;


- (WikiPathScreenSaver_imageCell *) cellAtPoint: (NSPoint) point;
- (void) setCell: (WikiPathScreenSaver_imageCell *) cell atPoint: (NSPoint) point;
- (NSPoint) findNextCellPosition: (NSPoint) starter sourceDir: (linkDirFrom *) dir;
- (WikiPathScreenSaver_imageCell *) generateCellFromSeed: (WikiPathScreenSaver_imageCell *) seed atPoint: (NSPoint) pt fromDir: (linkDirFrom) dir;
- (void) collectCurrentLinks;
- (void) resetAllPaths;
- (BOOL) linkIsFollowable: (NSString *) link;
- (void) setInTestHarness: (BOOL) inHarness;
- (void) terminatePath;
- (NSString *) generateInitialURL;
@end
