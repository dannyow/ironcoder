//
//  LifeCityOpenGLView.h
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import "GLDebug.h"
#import "Rectangle.h"
#import "Photo.h"
#import "Person.h"
#import <ScreenSaver/ScreenSaver.h>
#import "Building.h"
#import <GLUT/GLUT.h>
#import "PhotoEnumerator.h"
#import "ApplicationIconEnumerator.h"

@interface LifeCityOpenGLView : NSOpenGLView {
	Photo * photo;
	Person * person;
	
	NSMutableArray * people;
	Building * bldg;
	
	Person * billboardPerson;
	PhotoEnumerator * photoEnum;
	ApplicationIconEnumerator * appIcons;
}
- (void)initOpenGL;
@end
