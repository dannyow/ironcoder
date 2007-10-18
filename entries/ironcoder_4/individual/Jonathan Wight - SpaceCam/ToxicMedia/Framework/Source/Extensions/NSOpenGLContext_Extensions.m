//
//  NSOpenGLContext_Extensions.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/29/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import "NSOpenGLContext_Extensions.h"

@implementation NSOpenGLContext (NSOpenGLContext_Extensions)

- (QTVisualContextRef)quickTimeVisualContext
{
QTVisualContextRef theVisualContext = NULL;

CGLContextObj theGLContext = [self CGLContextObj];
OSStatus theStatus = QTOpenGLTextureContextCreate(kCFAllocatorDefault, theGLContext, [[NSOpenGLView defaultPixelFormat] CGLPixelFormatObj], NULL, &theVisualContext);
if (theStatus != noErr) [NSException raise:NSGenericException format:@"QTOpenGLTextureContextCreate -- Failed with %d", theStatus];
[(id)theVisualContext autorelease];
return(theVisualContext);
}

@end
