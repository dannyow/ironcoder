//
//  CMyController.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/26/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CMyView;
@class CCVStream;
@class CSequenceGrabber;
@class QTMovie;

@interface CMyController : NSObject {
	IBOutlet CMyView *outletMovieView;

	NSMutableArray *macros;
	NSString *selectedMacro;
	
	NSArray *imageSources;
	id selectedImageSource;

	CCVStream *movieStream;
	CSequenceGrabber *sequenceGrabber;
}

- (NSMutableArray *)macros;
- (NSString *)selectedMacro;
- (void)setSelectedMacro:(NSString *)inSelectedMacro;

- (id)selectedImageSource;
- (void)setSelectedImageSource:(id)inImageSource;

- (QTMovie *)movie;

- (IBAction)actionOpenMovie:(id)inSender;
- (IBAction)actionOpenMovieURL:(id)inSender;
- (IBAction)actionOpenMacro:(id)inSender;

#pragma mark -

- (IBAction)actionPlay:(id)inSender;
- (IBAction)actionStop:(id)inSender;
//- (IBAction)actionsetCurrentTime:(id)inSender;
- (IBAction)actionGotoBeginning:(id)inSender;
- (IBAction)actionGotoEnd:(id)inSender;
- (IBAction)actionGotoNextSelectionPoint:(id)inSender;
- (IBAction)actionGotoPreviousSelectionPoint:(id)inSender;
- (IBAction)actionGotoPosterTime:(id)inSender;
- (IBAction)actionStepForward:(id)inSender;
- (IBAction)actionStepBackward:(id)inSender;

@end
