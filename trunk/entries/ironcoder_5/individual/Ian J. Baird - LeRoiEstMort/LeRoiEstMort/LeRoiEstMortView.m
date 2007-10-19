//
//  LeRoiEstMortView.m
//  LeRoiEstMort
//
//  Created by Ian J. Baird on 3/30/07.
//  Copyright (c) 2007, Ian J. Baird. All rights reserved.
//
//  Pieces of code borrowed from:
//     http://developer.apple.com/qa/qa2001/qa1325.html
//     http://nehe.gamedev.net/data/lessons/lesson.asp?lesson=06
//

#import "LeRoiEstMortView.h"

#include <libkern/OSAtomic.h>

#define TEXTURE_WIDTH  430.0
#define TEXTURE_HEIGHT 355.0

static int32_t LREMinstanceCount = 0;

@implementation LeRoiEstMortView

//=========================================================== 
//  containedWebView 
//=========================================================== 
- (WebView *)containedWebView
{
    return containedWebView; 
}

- (void)setContainedWebView:(WebView *)aContainedWebView
{
    if (containedWebView != aContainedWebView)
    {
        [containedWebView release];
        containedWebView = [aContainedWebView retain];
    }
}

//=========================================================== 
//  containedGLView 
//=========================================================== 
- (FunkalisticOpenGLView *)containedGLView
{
    return containedGLView; 
}

- (void)setContainedGLView:(FunkalisticOpenGLView *)aContainedGLView
{
    if (containedGLView != aContainedGLView)
    {
        [containedGLView release];
        containedGLView = [aContainedGLView retain];
    }
}

//=========================================================== 
//  hiddenWindow 
//=========================================================== 
- (NSWindow *)hiddenWindow
{
    return hiddenWindow; 
}

- (void)setHiddenWindow:(NSWindow *)anHiddenWindow
{
    if (hiddenWindow != anHiddenWindow)
    {
        [hiddenWindow release];
        hiddenWindow = [anHiddenWindow retain];
    }
}

//=========================================================== 
//  currentTextureBitmap 
//=========================================================== 
- (NSBitmapImageRep *)currentTextureBitmap
{
    return currentTextureBitmap; 
}

- (void)setCurrentTextureBitmap:(NSBitmapImageRep *)aCurrentTextureBitmap
{
    if (currentTextureBitmap != aCurrentTextureBitmap)
    {
        [currentTextureBitmap release];
        currentTextureBitmap = [aCurrentTextureBitmap retain];
    }
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void)dealloc
{
    if (shouldRender)
    {
        [[self containedWebView] removeFromSuperview];
        [[self containedGLView] removeFromSuperview];
        [self setContainedWebView:nil];
        [self setContainedGLView:nil];
        [self setCurrentTextureBitmap:nil];
        [self setHiddenWindow:nil];
    }
    
    OSAtomicDecrement32(&LREMinstanceCount);
    [super dealloc];
}


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        
        shouldRender = isPreview || (OSAtomicIncrement32(&LREMinstanceCount) == 1) ? YES : NO;
                
        [self setAnimationTimeInterval:1/18.0];
        
        if (shouldRender)
        {
            WebView *aWebView = [[WebView alloc] initWithFrame:NSMakeRect(0,0,TEXTURE_WIDTH,TEXTURE_HEIGHT)
                                                     frameName:@"someName"
                                                     groupName:@"someGroup" ];
            [self setContainedWebView:aWebView];
            [aWebView release];
            
            NSOpenGLPixelFormatAttribute attributes[] = { 
                NSOpenGLPFAAccelerated,
                NSOpenGLPFADepthSize, 16,
                NSOpenGLPFAMinimumPolicy,
                NSOpenGLPFAClosestPolicy,
                0 };  
            NSOpenGLPixelFormat *format;
            
            format = [[[NSOpenGLPixelFormat alloc] 
                     initWithAttributes:attributes] autorelease];
            
            FunkalisticOpenGLView *aGLView = [[FunkalisticOpenGLView alloc] initWithFrame:NSZeroRect
                                                                              pixelFormat:format]; 
            [self setContainedGLView:aGLView];
            [aGLView release];
            
            NSWindow *aHiddenWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect( -10000.0, -10000.0
                                                                                        ,TEXTURE_WIDTH,TEXTURE_HEIGHT ) // some arbitrary offscreen coordinate
                                                                  styleMask:NSBorderlessWindowMask // doesn't matter what these are really
                                                                    backing:NSBackingStoreRetained
                                                                      defer:NO]; // if you pass YES for this it won't do any drawing until the window is onscreen, not good for this situation!
            [self setHiddenWindow:aHiddenWindow];
            [aHiddenWindow release];
            
            [[self hiddenWindow] setContentView:[self containedWebView]];
            [self addSubview:[self containedGLView]];
            [self setupGLView];
        }
        
        
    }
    return self;
}

-(void)setupGLView
{    
    [[[self containedGLView] openGLContext] makeCurrentContext];
    glShadeModel( GL_SMOOTH );
    glClearColor( 0.0f, 0.0f, 0.0f, 0.0f );
    glClearDepth( 1.0f ); 
    glEnable( GL_DEPTH_TEST );
    glDisable( GL_TEXTURE_2D );
    glEnable( GL_TEXTURE_RECTANGLE_EXT );
    glEnable( GL_APPLE_client_storage );
    glDepthFunc( GL_LEQUAL );
    glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
    
    srandomdev();
}

- (void)setFrameSize:(NSSize)newSize
{
    
    [super setFrameSize:newSize];
    
    if (shouldRender)
    {
        [[self containedGLView] setFrameSize:newSize]; 
        
        [[[self containedGLView] openGLContext] makeCurrentContext];
        
        // Reshape
        glViewport( 0, 0, (GLsizei)newSize.width, (GLsizei)newSize.height );
        glMatrixMode( GL_PROJECTION );
        glLoadIdentity();
        gluPerspective( 45.0f, (GLfloat)newSize.width / (GLfloat)newSize.height, 
                        0.1f, 100.0f );
        glMatrixMode( GL_MODELVIEW );
        glLoadIdentity();		
        
        [[[self containedGLView] openGLContext] update];
    }
}

// Generate texture 'texName' from 'theView' in current OpenGL context
-(void)textureFromView:(NSView*)theView textureName:(GLuint*)texName
{
    // Bitmap generation from source view
    NSBitmapImageRep * bitmap = [NSBitmapImageRep alloc];
    int samplesPerPixel = 0;
    
    [theView lockFocus];
    [bitmap initWithFocusedViewRect:[theView bounds]];
    [theView unlockFocus];
    
    [[[self containedGLView] openGLContext] makeCurrentContext];
    
    // Set proper unpacking row length for bitmap
    glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
    
    // Set byte aligned unpacking (needed for 3 byte per pixel bitmaps)
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    
    if (*texName == 0)
    {
        glGenTextures (1, texName);
        glBindTexture (GL_TEXTURE_RECTANGLE_EXT, *texName);
        // Set client storage of textures
        glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
        
        // Non-mipmap filtering (redundant for texture_rectangle)
        glTexParameteri(GL_TEXTURE_RECTANGLE_EXT, 
                        GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
        samplesPerPixel = [bitmap samplesPerPixel];
        
        // Non-planar, RGB 24 bit bitmap, or RGBA 32 bit bitmap
        if(![bitmap isPlanar] && 
           (samplesPerPixel == 3 || samplesPerPixel == 4)) { 
            glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 
                         0, 
                         samplesPerPixel == 4 ? GL_RGBA8 : GL_RGB8,
                         [bitmap pixelsWide], 
                         [bitmap pixelsHigh], 
                         0, 
                         samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
                         GL_UNSIGNED_BYTE, 
                         [bitmap bitmapData]);
        } else {
            /*
             Error condition...
             The above code handles 2 cases (24 bit RGB and 32 bit RGBA),
             it is possible to support other bitmap formats if desired.
             
             So we'll log out some useful information.
             */
            NSLog (@"-textureFromView: Unsupported bitmap data format: isPlanar:%d, samplesPerPixel:%d, bitsPerPixel:%d, bytesPerRow:%d, bytesPerPlane:%d",
                   [bitmap isPlanar], 
                   [bitmap samplesPerPixel], 
                   [bitmap bitsPerPixel], 
                   [bitmap bytesPerRow], 
                   [bitmap bytesPerPlane]);
        }
        
        // Set client storage of textures
        glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_FALSE);
    }
    else
    {
        // Replace the texture
        glTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT, 
                        0,
                        0,0,[bitmap pixelsWide],[bitmap pixelsHigh],
                        samplesPerPixel == 4 ? GL_RGBA : GL_RGB,
                        GL_UNSIGNED_BYTE,
                        [bitmap bitmapData]);

    }
    
    // Hold on to the texture
    [self setCurrentTextureBitmap:bitmap];
    
    // Clean up
    [bitmap release];
}

- (void)nextMovieEvent:(NSTimer *)aTimer
{
    [self nextMovie];
}

- (void)nextMovie
{
    NSPropertyListFormat format;
    NSString *errorString = nil;
    
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSString *plistPath = [myBundle pathForResource:@"movies"
                                             ofType:@"plist"];
    NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
    
    NSDictionary *plistDict = [NSPropertyListSerialization propertyListFromData:plistData
                                                               mutabilityOption:NSPropertyListImmutable
                                                                         format:&format
                                                               errorDescription:&errorString];
    NSArray *movieArray = [plistDict objectForKey:@"movieArray"];
    
    int currentMovieIndex = random() % [movieArray count];
        
    NSDictionary *movieDict = [movieArray objectAtIndex:currentMovieIndex];
    NSString *movieFN = [movieDict objectForKey:@"movieFN"];
    NSNumber *movieDuration = [movieDict objectForKey:@"movieDuration"];
    
    NSString *htmlPath = [myBundle pathForResource:movieFN
                                            ofType:@"html"];
    
    
    NSURL *htmlURL = [[[NSURL alloc] initFileURLWithPath:htmlPath] autorelease];
    
    [[[self containedWebView] mainFrame] loadRequest:[NSURLRequest requestWithURL:htmlURL]];
    
    [NSTimer scheduledTimerWithTimeInterval:[movieDuration floatValue]
                                     target:self
                                   selector:@selector(nextMovieEvent:)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)startAnimation
{
    [super startAnimation];
    
    if (shouldRender)
    {
        [self nextMovie];
    }
}

- (void)stopAnimation
{
    [super stopAnimation];
    
    [[[self containedWebView] mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    if (shouldRender)
    {
        [[[self containedGLView] openGLContext] makeCurrentContext];
        
        glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT ); 
        glLoadIdentity(); 
        glTranslatef(0.0f,0.0f,-10.0f);						// Move Into The Screen 5 Units
        
        glBindTexture(GL_TEXTURE_RECTANGLE_EXT, webViewTexName);
        
        glTranslatef(-6.0f, 4.0f, 0.0f);
        
        int j;
        for (j = 0; j < 5; ++j)
        {

            glPushMatrix();
            
            int i;
            for (i = 0; i < 7; ++i)
            {
                glPushMatrix();
                
                if (j % 2)
                {
                    if (i % 2)
                    {
                        glRotatef(yrot,0.0f,1.0f,0.0f);			
                    }
                    else
                    {
                        glRotatef(xrot,1.0f,0.0f,0.0f);
                    }
                }
                else
                {
                    if (!(i % 2))
                    {
                        glRotatef(yrot,0.0f,1.0f,0.0f);		
                    }
                    else
                    {
                        glRotatef(xrot,1.0f,0.0f,0.0f);
                    }
                }
                
                glBegin(GL_QUADS);
                    glTexCoord2f(0.0f, TEXTURE_HEIGHT); glVertex3f(-1.0f, -1.0f,  0.0f);	// Bottom Left Of The Texture and Quad
                    glTexCoord2f(TEXTURE_WIDTH, TEXTURE_HEIGHT); glVertex3f( 1.0f, -1.0f,  0.0f);	// Bottom Right Of The Texture and Quad
                    glTexCoord2f(TEXTURE_WIDTH, 0.0f); glVertex3f( 1.0f,  1.0f,  0.0f);	// Top Right Of The Texture and Quad
                    glTexCoord2f(0.0f, 0.0f); glVertex3f(-1.0f,  1.0f,  0.0f);	// Top Left Of The Texture and Quad
                glEnd();
                
                glPopMatrix();
                
                glTranslatef(2.0f, 0.0f, 0.0f);
            }
            
            glPopMatrix();
            
            glTranslatef(0.0f, -2.0f, 0.0f);
        
        }
        glFlush(); 
    }
    else
    {
        [[NSColor blackColor] setFill];
        NSRectFill([self bounds]);
    }
}

- (void)animateOneFrame
{
    if (shouldRender)
    {
        // Adjust our state 
        xrot+=2.0f;								// X Axis Rotation
        yrot+=2.0f;								// Y Axis Rotation
        //zrot+=0.4f;                             // Z Axis Rotation
        
        [self textureFromView:[self containedWebView]
                  textureName:&webViewTexName];

        // Redraw
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
