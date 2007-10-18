//
//  NSOpenGLContext_Extensions.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/29/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import <AppKit/AppKit.h>

#import <QuickTime/QuickTime.h>

@interface NSOpenGLContext (NSOpenGLContext_Extensions)

/**
 * @method quickTimeVisualContext
 * @abstract Returns the sender's QTVisualContext (used for CoreVideo).
 */
- (QTVisualContextRef)quickTimeVisualContext;

@end
