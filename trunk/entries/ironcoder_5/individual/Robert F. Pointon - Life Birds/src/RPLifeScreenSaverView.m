#import "RPLifeScreenSaverView.h"
#import "RPOpenGLView.h"
#import "Flock.h"

#define kBackgroundKey @"BackgroundKey"
#define kShadowKey     @"ShadowKey"
#define kLifeKey       @"LifeKey"
#define kFlockSizeKey  @"FlockSizeKey"  


#define SHADOWMAPSIZE 512
    
//yuck - but I'm not including entire math matrix libraries just for this...
static void mmult(GLfloat *res, GLfloat *lhs, GLfloat *rhs) {
    res[0] = lhs[0]*rhs[0]+lhs[4]*rhs[1]+lhs[8]*rhs[2]+lhs[12]*rhs[3];
    res[1] = lhs[1]*rhs[0]+lhs[5]*rhs[1]+lhs[9]*rhs[2]+lhs[13]*rhs[3];
    res[2] = lhs[2]*rhs[0]+lhs[6]*rhs[1]+lhs[10]*rhs[2]+lhs[14]*rhs[3];
    res[3] = lhs[3]*rhs[0]+lhs[7]*rhs[1]+lhs[11]*rhs[2]+lhs[15]*rhs[3];
    res[4] = lhs[0]*rhs[4]+lhs[4]*rhs[5]+lhs[8]*rhs[6]+lhs[12]*rhs[7];
    res[5] = lhs[1]*rhs[4]+lhs[5]*rhs[5]+lhs[9]*rhs[6]+lhs[13]*rhs[7];
    res[6] = lhs[2]*rhs[4]+lhs[6]*rhs[5]+lhs[10]*rhs[6]+lhs[14]*rhs[7];
    res[7] = lhs[3]*rhs[4]+lhs[7]*rhs[5]+lhs[11]*rhs[6]+lhs[15]*rhs[7];
    res[8] = lhs[0]*rhs[8]+lhs[4]*rhs[9]+lhs[8]*rhs[10]+lhs[12]*rhs[11];
    res[9] = lhs[1]*rhs[8]+lhs[5]*rhs[9]+lhs[9]*rhs[10]+lhs[13]*rhs[11];
    res[10] = lhs[2]*rhs[8]+lhs[6]*rhs[9]+lhs[10]*rhs[10]+lhs[14]*rhs[11];
    res[11] = lhs[3]*rhs[8]+lhs[7]*rhs[9]+lhs[11]*rhs[10]+lhs[15]*rhs[11];
    res[12] = lhs[0]*rhs[12]+lhs[4]*rhs[13]+lhs[8]*rhs[14]+lhs[12]*rhs[15];
    res[13] = lhs[1]*rhs[12]+lhs[5]*rhs[13]+lhs[9]*rhs[14]+lhs[13]*rhs[15];
    res[14] = lhs[2]*rhs[12]+lhs[6]*rhs[13]+lhs[10]*rhs[14]+lhs[14]*rhs[15];
    res[15] = lhs[3]*rhs[12]+lhs[7]*rhs[13]+lhs[11]*rhs[14]+lhs[15]*rhs[15];
}


@implementation RPLifeScreenSaverView

// http://www.mactech.com/articles/mactech/Vol.21/21.07/SaveOurScreens102/index.html 
- (ScreenSaverDefaults*) defaults {
    return [ScreenSaverDefaults defaultsForModuleWithName:@"RPLife"];
}

- (void)useDefaults {
    //together with alpha pixelformat this allows a transparent nsopenglview
    //note: when transparent it makes fullscreen opengl very slow...
    [[glView openGLContext] makeCurrentContext];
    NSOpenGLContext	*glcontext = [glView openGLContext];
    long val = [[self defaults] boolForKey:kBackgroundKey];
    [glcontext setValues:&val forParameter:NSOpenGLCPSurfaceOpacity];
    glClearColor(0.0f, 0.0f, 0.0f, val?1.0f:0.0f);
    
    [flock setSize:[[self defaults] integerForKey:kFlockSizeKey]];
    [flock enableLife:[[self defaults] boolForKey:kLifeKey]];
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview {
    if ((self = [super initWithFrame:frame isPreview:isPreview])) {
		NSOpenGLPixelFormatAttribute attributes[] = { 
            NSOpenGLPFAAlphaSize, 8, 
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADepthSize, 24,
			NSOpenGLPFAMinimumPolicy,
			NSOpenGLPFAClosestPolicy,
            0 };  
		
        NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
		glView = [[RPOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
		if (!glView) {             
			NSLog( @"Couldn't initialize OpenGL view." );
			[self autorelease];
			return nil;
		} 
        
        flock = [[Flock alloc] init];
        
        NSDictionary* initialDefaults = [NSDictionary dictionaryWithObjectsAndKeys: 
            @"YES", kShadowKey, 
            @"YES", kLifeKey,
            @"NO",  kBackgroundKey, 
            @"200", kFlockSizeKey,
            nil];
        [[self defaults] registerDefaults:initialDefaults];
        
		[self addSubview:glView]; 
		[self setUpOpenGL];
		[self setAnimationTimeInterval:1/30.0];
        [self useDefaults];
	}
	return self;
}

- (void)dealloc {
	[glView removeFromSuperview];
	[glView release];
    [flock release];
	[super dealloc];
}

- (void)viewDidMoveToWindow {
    NSWindow *window = [self window];
    if (![self isPreview] && window) {        
        //ensure the window is transparent
        fading = 0.0;
        [window setAlphaValue:fading];//we fade the window in..
        [window setOpaque:NO];
        [window setBackgroundColor:[NSColor clearColor]];
    }
}


//we do our own fading..
+ (BOOL)performGammaFade { return NO; }

- (void)animateOneFrame {
    if(![self isPreview] && fading < 1.0) {
        NSWindow *window = [self window];
        fading = (fading > 0.9)?1.0:(fading+0.05);
        [window setAlphaValue:fading];
    }
	[flock moveBoids];
	[self setNeedsDisplay:YES];
}


- (void)setUpOpenGL {  
 	[[glView openGLContext] makeCurrentContext];
	
    GLfloat cameraPosition[3] = {-3.5f, 3.5f, -2.5f};

    lightPosition[0] =  -3.0f;
    lightPosition[1] =  5.0f;
    lightPosition[2] =  -3.0f;
    lightPosition[3] =  1.0f; //required for lightposition

    glPolygonOffset(4.0f, 4.0f);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearDepth(1.0f);
	glDepthFunc(GL_LEQUAL);
	glEnable(GL_DEPTH_TEST);

    //Load identity modelview
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	//Shading states
	glShadeModel(GL_SMOOTH);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

    //We use glScale when drawing the scene
	glEnable(GL_NORMALIZE);

    //Create the shadow map texture
	glGenTextures(1, &shadowMapTexture);
	glBindTexture(GL_TEXTURE_2D, shadowMapTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, SHADOWMAPSIZE, SHADOWMAPSIZE, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, NULL);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

	//Use the color as the ambient and diffuse material
	glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
	glEnable(GL_COLOR_MATERIAL);

    //White specular material color, shininess 16
    const GLfloat white[] = {1.0f, 1.0f, 1.0f, 1.0f};
	glMaterialfv(GL_FRONT, GL_SPECULAR, white);
	glMaterialf(GL_FRONT, GL_SHININESS, 16.0f);

    //Calculate & save matrices
	glLoadIdentity();
	glPushMatrix();
		
	glLoadIdentity();
	gluLookAt(cameraPosition[0], cameraPosition[1], cameraPosition[2], 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
	glGetFloatv(GL_MODELVIEW_MATRIX, cameraViewMatrix);
    
    glLoadIdentity();
	gluPerspective(45.0f, 1.0f, 2.0f, 8.0f);
	glGetFloatv(GL_MODELVIEW_MATRIX, lightProjectionMatrix);
	
	glLoadIdentity();
	gluLookAt(lightPosition[0], lightPosition[1], lightPosition[2], 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f);
	glGetFloatv(GL_MODELVIEW_MATRIX, lightViewMatrix);    
    
	glPopMatrix();
}

- (void)setFrameSize:(NSSize)newSize {
	[super setFrameSize:newSize];
	[glView setFrameSize:newSize]; 
	
	[[glView openGLContext] makeCurrentContext];
	
    //Update the camera's projection matrix
    glMatrixMode( GL_MODELVIEW );
	glPushMatrix();
	glLoadIdentity();
	gluPerspective(45.0f, (GLfloat)newSize.width / (GLfloat)newSize.height, 1.0f, 100.0f);
	glGetFloatv(GL_MODELVIEW_MATRIX, cameraProjectionMatrix);
	glPopMatrix();
    
	[[glView openGLContext] update];
}


- (void)drawScene {
    glPushMatrix();
    const GLfloat s = 0.004; //can't be bother - a wild guess...
	glScalef(s,s,s);
    [flock drawGround];    
    [flock drawBoids];
    glPopMatrix();
}

- (void)drawRect:(NSRect)rect {    
	[[glView openGLContext] makeCurrentContext];	
	
    NSSize winsize = [glView frame].size;
    
    if([[self defaults] boolForKey:kShadowKey]) {
    
        //pass 1 - light point of view
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(lightProjectionMatrix);
        glMatrixMode(GL_MODELVIEW);
        glLoadMatrixf(lightViewMatrix);
        glViewport(0, 0, SHADOWMAPSIZE, SHADOWMAPSIZE); //Use viewport the same size as the shadow map
        glShadeModel(GL_FLAT); //Disable color writes, and use flat shading for speed
        glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
        glEnable(GL_POLYGON_OFFSET_FILL);
    
        [self drawScene];
        
        glDisable(GL_POLYGON_OFFSET_FILL);
        glBindTexture(GL_TEXTURE_2D, shadowMapTexture); //Read the depth buffer into the shadow map texture
        glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, SHADOWMAPSIZE, SHADOWMAPSIZE);
        glShadeModel(GL_SMOOTH); 
        glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
        
        //pass 2 - camera point of view, ambient lighting
        
        glClear(GL_DEPTH_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(cameraProjectionMatrix);
        glMatrixMode(GL_MODELVIEW);
        glLoadMatrixf(cameraViewMatrix);
        glViewport( 0, 0, (GLsizei)winsize.width, (GLsizei)winsize.height);
        const GLfloat gray[] = {0.2f, 0.2f, 0.2f, 0.0f};
        const GLfloat black[] = {0.0f, 0.0f, 0.0f, 0.0f};
        glLightfv(GL_LIGHT1, GL_POSITION, lightPosition); //Use dim light for shadowed areas
        glLightfv(GL_LIGHT1, GL_AMBIENT, gray);
        glLightfv(GL_LIGHT1, GL_DIFFUSE, gray);
        glLightfv(GL_LIGHT1, GL_SPECULAR, black);
        glEnable(GL_LIGHT1);
        glEnable(GL_LIGHTING);
        
        [self drawScene];
        
        //pass 3 -  camera point of view, lighting
    
        const GLfloat white[] = {1.0f, 1.0f, 1.0f, 1.0f};
        glLightfv(GL_LIGHT1, GL_DIFFUSE, white);
        glLightfv(GL_LIGHT1, GL_SPECULAR, white);
        
        GLfloat biasMatrix[16] = {  
            0.5f, 0.0f, 0.0f, 0.0f,
            0.0f, 0.5f, 0.0f, 0.0f,
            0.0f, 0.0f, 0.5f, 0.0f,
            0.5f, 0.5f, 0.5f, 1.0f};	//bias from [-1, 1] to [0, 1]
        GLfloat texMatrix[16];
        GLfloat tempMatrix[16];
        mmult(tempMatrix, biasMatrix, lightProjectionMatrix);
        mmult(texMatrix, tempMatrix, lightViewMatrix);
        
        //Set up texture coordinate generation
        GLenum gens[] = {GL_S, GL_T, GL_R, GL_Q};
        GLenum texgens[] = {GL_TEXTURE_GEN_S, GL_TEXTURE_GEN_T, GL_TEXTURE_GEN_R, GL_TEXTURE_GEN_Q};
        unsigned int i;
        for(i=0; i<4; i++) {
            GLfloat row[] = {texMatrix[i], texMatrix[i+4], texMatrix[i+8], texMatrix[i+12]};
            glTexGeni(gens[i], GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR); 
            glTexGenfv(gens[i], GL_EYE_PLANE, row);
            glEnable(texgens[i]);
        }
        glBindTexture(GL_TEXTURE_2D, shadowMapTexture); // Bind & enable shadow map texture
        glEnable(GL_TEXTURE_2D);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_ARB, GL_COMPARE_R_TO_TEXTURE); // Enable shadow comparison
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_ARB, GL_LEQUAL); // Shadow comparison should be true (ie not in shadow) if r<=texture
        glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE_ARB, GL_INTENSITY); // Shadow comparison should generate an INTENSITY result
        glAlphaFunc(GL_GEQUAL, 0.99f); // Set alpha test to discard false comparisons
        glEnable(GL_ALPHA_TEST);
        
        [self drawScene];
        
        // disable textures and texgen
        glDisable(GL_TEXTURE_2D); 
        for(i=0; i<4; i++) glDisable(texgens[i]);
        glDisable(GL_LIGHTING); 
        glDisable(GL_ALPHA_TEST);
            
    } else {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glMatrixMode(GL_PROJECTION);
        glLoadMatrixf(cameraProjectionMatrix);
        
        glMatrixMode(GL_MODELVIEW);
        glLoadMatrixf(cameraViewMatrix);
        
        glViewport( 0, 0, (GLsizei)winsize.width, (GLsizei)winsize.height);
        
        [self drawScene];
    }
    
    //[[glView openGLContext] flushBuffer]; //does bad things...
	glFlush();
}
 
 
 
- (BOOL)hasConfigureSheet { return YES; }

- (NSWindow*)configureSheet {
   if(!configureSheet) [NSBundle loadNibNamed:@"Life" owner:self];
   [shadowCheckbox setState:[[self defaults] boolForKey:kShadowKey]];
   [backgroundCheckbox setState:[[self defaults] boolForKey:kBackgroundKey]];
   [lifeCheckbox setState:[[self defaults] boolForKey:kLifeKey]];
   [flocksizeSlider setIntValue:[[self defaults] integerForKey:kFlockSizeKey]];
   return configureSheet;
}

- (IBAction)cancelSheetAction:(id)sender {
    [NSApp endSheet:configureSheet];
}

- (IBAction)okSheetAction:(id)sender {
    [[self defaults] setBool:[backgroundCheckbox state] forKey:kBackgroundKey];
    [[self defaults] setBool:[shadowCheckbox state] forKey:kShadowKey];
    [[self defaults] setBool:[lifeCheckbox state] forKey:kLifeKey];
    [[self defaults] setInteger:[flocksizeSlider intValue] forKey:kFlockSizeKey];
    [[self defaults] synchronize];
    [self useDefaults];
    [NSApp endSheet:configureSheet];
}


//@TODO - use mouse events in preview mode to position view...
- (void)mouseDown:(NSEvent *)event {
    if(![self isPreview]) return;
    NSLog(@"mouse down");
}

- (void)mouseDragged:(NSEvent *)event {
    if(![self isPreview]) return;
    NSLog(@"mouse drag");
}


@end
