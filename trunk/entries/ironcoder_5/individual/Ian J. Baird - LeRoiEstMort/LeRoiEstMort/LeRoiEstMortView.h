//
//  LeRoiEstMortView.h
//  LeRoiEstMort
//
//  Created by Ian J. Baird on 3/30/07.
//  Copyright (c) 2007, Ian J. Baird. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

#import "FunkalisticOpenGLView.h"

@interface LeRoiEstMortView : ScreenSaverView 
{
    WebView *containedWebView;
    FunkalisticOpenGLView *containedGLView;
    float xrot;
    float yrot;
    float zrot;
    GLuint webViewTexName;
    NSWindow *hiddenWindow;
    NSBitmapImageRep *currentTextureBitmap;
    BOOL shouldRender;
}

- (WebView *)containedWebView;
- (void)setContainedWebView:(WebView *)aContainedWebView;
- (FunkalisticOpenGLView *)containedGLView;
- (void)setContainedGLView:(FunkalisticOpenGLView *)aContainedGLView;
- (NSWindow *)hiddenWindow;
- (void)setHiddenWindow:(NSWindow *)anHiddenWindow;
- (NSBitmapImageRep *)currentTextureBitmap;
- (void)setCurrentTextureBitmap:(NSBitmapImageRep *)aCurrentTextureBitmap;


-(void)setupGLView;
-(void)textureFromView:(NSView*)theView textureName:(GLuint*)texName;
-(void)nextMovie;


@end
