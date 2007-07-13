//
//  TLPrintView.h
//  TimeLapse
//
//  Created by Andy Kim on 7/23/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TLPrintView : NSView
{
	NSArray *mScreenshots;
}

- (id)initWithScreenshots:(NSArray*)screenshots;
- (int)numberOfPages;
@end
