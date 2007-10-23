//
//  PrimitiveDrawing.h
//  OpenGLTests
//
//  Created by Jonathan Saggau on 10/30/06.
//  Copyright 2006 Jonathan Saggau. All rights reserved.
//

#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import "StringTexture.h"
#include "model_loader.h"

@class NSString;

void textureQuad(const GLfloat lowerLeft[3], const GLfloat upperRight[3],
                 const GLint textureNumber, const GLfloat coverHeight, const GLfloat coverWidth,
                 const GLint textureType);

void dotQuad(const GLfloat point[3], float scale, 
             const GLfloat color[3], float alpha,
             const GLuint texture);

void plainQuad(const GLfloat lowerLeft[3], const GLfloat upperRight[3],
               const GLfloat color[4]);

void threePointLighting();

void gradientQuad(const GLfloat lowerLeft[2], const GLfloat upperRight[2],    \
                  const GLfloat lowerColor[4], const GLfloat upperColor[4]);

void setModelSpecularColor(const GLfloat specularColor[3], const GLfloat shininess);

void unsetModelSpecularColor();

void drawModel(WFObject * model, const GLfloat point[3], const float scale, 
               const GLfloat color[3], float alpha);

void drawStringTexture(StringTexture *stringText, GLfloat lowerLeft[3], GLfloat width);
