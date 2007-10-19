#import <ScreenSaver/ScreenSaver.h>

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>

@class Flock;

@interface RPLifeScreenSaverView : ScreenSaverView {
    IBOutlet NSWindow* configureSheet;
    IBOutlet NSButton* shadowCheckbox;
    IBOutlet NSButton* backgroundCheckbox;
    IBOutlet NSButton* lifeCheckbox;
    IBOutlet NSSlider* flocksizeSlider;
    
    GLfloat cameraProjectionMatrix[16], cameraViewMatrix[16];
    GLfloat lightProjectionMatrix[16], lightViewMatrix[16];
    GLfloat lightPosition[4];
    GLuint shadowMapTexture;
    float fading;
    Flock *flock;
	NSOpenGLView *glView;
}

- (void)setUpOpenGL;


- (IBAction)cancelSheetAction:(id)sender;
- (IBAction)okSheetAction:(id)sender;
 
@end
