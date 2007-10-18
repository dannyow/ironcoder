//
//  CCoreVideoMovieView.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 10/25/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CFilteringCoreImageView.h"

@class QTMovie;
@class CCVStream;

/**
 * @class CCoreVideoMovieView
 * @discussion This is a simple view for playing movies with optional CoreImage filters.
 */
@interface CCoreVideoMovieView : CFilteringCoreImageView {
	CCVStream *coreVideoStream;
	NSObjectController *controller;
}

- (QTMovie *)movie;
- (void)setMovie:(QTMovie *)inMovie;

- (CCVStream *)coreVideoStream;

- (IBAction)play:(id)inSender;
- (IBAction)pause:(id)inSender;
- (IBAction)gotoBeginning:(id)inSender;
- (IBAction)gotoEnd:(id)inSender;
- (IBAction)gotoNextSelectionPoint:(id)inSender;
- (IBAction)gotoPreviousSelectionPoint:(id)inSender;
- (IBAction)gotoPosterFrame:(id)inSender;
- (IBAction)stepForward:(id)inSender;
- (IBAction)stepBackward:(id)inSender;
/*
- (IBAction)cut:(id)inSender;
- (IBAction)copy:(id)inSender;
- (IBAction)paste:(id)inSender;
- (IBAction)selectAll:(id)inSender;
- (IBAction)selectNone:(id)inSender;
- (IBAction)delete:(id)inSender;
- (IBAction)add:(id)inSender;
- (IBAction)addScaled:(id)inSender;
- (IBAction)replace:(id)inSender;
- (IBAction)trim:(id)inSender;
*/

- (IBAction)chooseMovieFile:(id)inSender;


@end
