//
//  CToxicOpenGLView.h
//  CustomOpenGLView
//
//  Created by Jonathan Wight on 7/30/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CToxicOpenGLViewHelper;

@interface CToxicOpenGLView : NSView {
    CToxicOpenGLViewHelper *helper;
}

- (CToxicOpenGLViewHelper *)helper;

@end
