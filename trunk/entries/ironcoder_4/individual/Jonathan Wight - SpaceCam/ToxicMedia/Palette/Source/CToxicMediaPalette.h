//
//  CToxicMediaPalette.h
//  ToxicMedia
//
//  Created by Jonathan Wight on 10/20/2005.
//  Copyright Toxic Software 2005 . All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>

#import "CCoreImageView.h"
#import "CFilteringCoreImageView.h"
#import "CSequenceGrabberView.h"
#import "CSequenceGrabber.h"
#import "CCoreVideoMovieView.h"

@interface CToxicMediaPalette : IBPalette {
	IBOutlet NSView *coreImageViewProxy;
	IBOutlet NSView *filteringCoreImageViewProxy;
	IBOutlet NSView *sequenceGrabberViewProxy;
	IBOutlet NSView *sequenceGrabberProxy;
	IBOutlet NSView *coreVideoMovieViewProxy;

	CCoreImageView *coreImageView;
	CFilteringCoreImageView *filteringCoreImageView;
	CSequenceGrabberView *sequenceGrabberView;
	CSequenceGrabber *sequenceGrabber;
	CCoreVideoMovieView *coreVideoMovieView;
}
@end

#pragma mark -

@interface CCoreImageView (CCoreImageView_Inspector)
- (NSString *)inspectorClassName;
@end

#pragma mark -

@interface CFilteringCoreImageView (CCoreImageView_Inspector)
- (NSString *)inspectorClassName;
@end

#pragma mark -

@interface CSequenceGrabberView (CCoreImageView_Inspector)
- (NSString *)inspectorClassName;
@end
