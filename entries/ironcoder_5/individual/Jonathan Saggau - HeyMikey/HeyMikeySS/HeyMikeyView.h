//
//  HeyMikeyView.h
//  HeyMikey
//
//  Created by Jonathan Saggau on 3/31/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
//#import <OpenGL/gl.h>
#import "GLView.h"
#import "GLVizController.h"

@interface HeyMikeyView : ScreenSaverView 
{
	GLVizController *_vizController;
    GLView *_view;
    BOOL _initedGL;
    
    NSWindow *configureSheet;
    id allScreensCheckbox;
	id allSoundsCheckbox;
	id initialSoundCheckbox;
}

@end
