//
//  TTApplicationController.h
//  SpaceTime
//
//  Created by 23 on 10/27/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TTSpaceTimeView;

@interface TTApplicationController : NSWindowController
{
	IBOutlet	TTSpaceTimeView*		_view;
	IBOutlet	NSPanel*				_controlPanel;
	
				unsigned int			_maximumStarCount;
				unsigned int			_minimumStarCount;
				unsigned int			_starCount;
}

- (IBAction) redistributeStars:(id)sender;
- (IBAction) resetConstellation:(id)sender;
- (IBAction) saveImage:(id)sender;

- (void) setStarCount:(unsigned int)count;

@end
