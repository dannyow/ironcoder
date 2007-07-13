//
//  CustomWindow.h
//  WindowMoveTest
//
//  Created by Tom Harrington on 3/5/06;12:17 PM.
//  Copyright 2006 Atomic Bird LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CustomView.h"

@interface CustomWindow : NSPanel {
	IBOutlet CustomView *myImageView;
}
- (void)rotateImage;

@end
