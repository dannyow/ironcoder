//
//  DVContentView.h
//  DrunkVision
//
//  Created by Colin Barrett on 3/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DVContentView : NSView {
	NSString *windowTitle;
	NSString *appName;
	
	NSString *_cachedTrimmedWindowTitle;
}

- (void)setWindowTitle:(NSString *)title;
- (void)setAppName:(NSString *)name;
- (NSSize)requestedSize;
@end
