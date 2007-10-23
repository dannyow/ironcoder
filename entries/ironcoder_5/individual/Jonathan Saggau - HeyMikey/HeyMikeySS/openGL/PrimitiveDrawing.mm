//
//  PrimitiveDrawing.m
//  OpenGLTests
//
//  Created by Jonathan Saggau on 10/30/06.
//  Copyright 2006 Jonathan Saggau. All rights reserved.
//

#include "PrimitiveDrawing.h"
#include <stdio.h>
#include <math.h>
#include "vvector.h"
#include "normals.h"

#import <Cocoa/Cocoa.h>
#import <GLUT/glut.h>

void textureQuad(const GLfloat lowerLeft[3], const GLfloat upperRight[3],
                 const GLint textureNumber, const GLfloat coverHeight, const GLfloat coverWidth,
                 const GLint textureType)
{
    GLfloat lowerRight[] = {upperRight[0], lowerLeft[1], upperRight[2]};
    GLfloat upperLeft[] = {lowerLeft[0], upperRight[1], lowerLeft[2]};
    
    glEnable(textureType);
    glBindTexture(textureType, textureNumber);
    glBegin(GL_QUADS); 
    {   
        glTexCoord2f (0.0f, 0.0f);
        glVertex3fv(lowerLeft);
        glTexCoord2f (coverWidth, 0.0f); 
        glVertex3fv(lowerRight);
        glTexCoord2f (coverWidth, coverHeight);
        glVertex3fv(upperRight);
        glTexCoord2f (0.0f, coverHeight);
        glVertex3fv(upperLeft);
        
    } glEnd();
    glDisable(textureType);
}

void plainQuad(const GLfloat lowerLeft[3], const GLfloat upperRight[3],
               const GLfloat color[4])
{
    float norm[3];
    glColor4fv(color);
    glBegin(GL_QUADS); 
    {   
        GLfloat point1[] = {lowerLeft[0], lowerLeft[1], lowerLeft[2]};
        GLfloat point2[] = {upperRight[0], lowerLeft[1], upperRight[2]}; //lowerRight
        GLfloat point3[] = {upperRight[0], upperRight[1], upperRight[2]};
        GLfloat point4[] = {lowerLeft[0], upperRight[1], lowerLeft[2]}; //upperLeft
        
        getFaceNormal(norm, point1, point2, point3);
        glNormal3fv(norm);
        glTexCoord2f(0.0, 0.0);
        glVertex3fv(point1);
        
        getFaceNormal(norm, point2, point3, point4);
        glNormal3fv(norm);
        glTexCoord2f(1.0, 0.0);
        glVertex3fv(point2);
        
        getFaceNormal(norm, point3, point4, point1);
        glNormal3fv(norm);
        glTexCoord2f(1.0, 1.0);
        glVertex3fv(point3);
        
        getFaceNormal(norm, point4, point1, point2);
        glNormal3fv(norm);
        glTexCoord2f(0.0, 1.0);
        glVertex3fv(point4);
    } glEnd();
}

void gradientQuad(const GLfloat lowerLeft[2], const GLfloat upperRight[2],    \
                  const GLfloat lowerColor[4], const GLfloat upperColor[4])
{
    glBegin(GL_QUADS);
    {
        GLfloat point1[] = {lowerLeft[0], lowerLeft[1], lowerLeft[2]};
        GLfloat point2[] = {upperRight[0], lowerLeft[1], upperRight[2]}; //lowerRight
        GLfloat point3[] = {upperRight[0], upperRight[1], upperRight[2]};
        GLfloat point4[] = {lowerLeft[0], upperRight[1], lowerLeft[2]}; //upperLeft
        
        glColor4fv(lowerColor);
        glVertex3fv(point1);
        glVertex3fv(point2);
        
        glColor4fv(upperColor);
        glVertex3fv(point3);
        glVertex3fv(point4);
    } glEnd();
}

void threePointLighting()
{
	GLfloat l1_ambient[] = {0.05, 0.05, 0.05, 0.0};
    GLfloat l1_diffuse[] = {0.7, 0.7, 0.7, 1.0};
    GLfloat l1_specular[] = {1.0, 1.0, 1.0, 1.0};
    GLfloat l1_position[] = {-1.0, 1.0, 1.0, 0.0};
	
	GLfloat l2_ambient[] = {0.05, 0.05, 0.05, 0.0};
    GLfloat l2_diffuse[] = {0.7, 0.6, 0.6, 1.0};
    GLfloat l2_specular[] = {0.1, 0.1, 0.1, 1.0};
    GLfloat l2_position[] = {0.2, 0.0, 1.0, 0.0};
	
	GLfloat l3_ambient[] = {0.05, 0.05, 0.05, 0.0};
    GLfloat l3_diffuse[] = {0.7, 0.7, 0.9, 1.0};
    GLfloat l3_specular[] = {0.2, 0.2, 0.2, 1.0};
    GLfloat l3_position[] = {1.0, 0.0, -1.0, 0.0};
	
	
	glEnable(GL_RESCALE_NORMAL);
	
	glEnable(GL_LIGHTING);
	
	// Exhibit 3-point lighting
	// For more info: http://www.3drender.com/light/3point.html
	// Key light... left and up from the model
	glLightfv(GL_LIGHT0, GL_AMBIENT, l1_ambient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, l1_diffuse);
    glLightfv(GL_LIGHT0, GL_SPECULAR, l1_specular);
    glLightfv(GL_LIGHT0, GL_POSITION, l1_position);
	glEnable(GL_LIGHT0);
	
	// Fill light... right and level from the model
	glLightfv(GL_LIGHT1, GL_AMBIENT, l2_ambient);
    glLightfv(GL_LIGHT1, GL_DIFFUSE, l2_diffuse);
    glLightfv(GL_LIGHT1, GL_SPECULAR, l2_specular);
    glLightfv(GL_LIGHT1, GL_POSITION, l2_position);
	glEnable(GL_LIGHT1);
	
	// Back light... behind the target (and above)
	glLightfv(GL_LIGHT2, GL_AMBIENT, l3_ambient);
    glLightfv(GL_LIGHT2, GL_DIFFUSE, l3_diffuse);
    glLightfv(GL_LIGHT2, GL_SPECULAR, l3_specular);
    glLightfv(GL_LIGHT2, GL_POSITION, l3_position);
	glEnable(GL_LIGHT2);
    
    //we'll enable lighting separately
	glDisable(GL_LIGHTING);
}

void drawModel(WFObject * model, const GLfloat point[3], float scale, 
                                const GLfloat color[3], float alpha)
{
    glPushMatrix();
    {
        glTranslatef(point[0], point[1], point[2]);
        glScalef(scale, scale, scale);
        
        //we may eventually want to rotate individual models.
        //This is how we would do it.
        //glRotated(node_rotation[i], 1.0, 0.2, 3.0);
        glColor4f(color[0], color[1], color[2], alpha);
        obj_draw_with_display_list(model);
    }glPopMatrix();
}

void setModelSpecularColor(const GLfloat specularColor[3], const GLfloat shininess)
{
    // Share a specular color...
	glColorMaterial(GL_FRONT, GL_SPECULAR);
	glEnable(GL_COLOR_MATERIAL);
	glColor3fv(specularColor);
	
	glMaterialfv(GL_FRONT, GL_SHININESS, &shininess);
	
	// Modify the node diffuse color
	glColorMaterial(GL_FRONT, GL_DIFFUSE);
	glEnable(GL_COLOR_MATERIAL);
}


void unsetModelSpecularColor()
{
    glDisable(GL_COLOR_MATERIAL);
}

void drawStringTexture(StringTexture *stringText, GLfloat lowerLeft[3], GLfloat width)
{
    GLfloat upperRight[3];
    
    GLuint textureNumber = [stringText texName];
    NSSize textureSize = [stringText texSize];
    float textureAspectRatio = textureSize.height / textureSize.width;
    GLfloat height = width * textureAspectRatio;
    upperRight[0] = lowerLeft[0] + width;
    upperRight[1] = lowerLeft[1] + height;
    upperRight[2] = lowerLeft[2]; //make z the same
    GLfloat lowerRight[] = {upperRight[0], lowerLeft[1], upperRight[2]}; //lowerRight
    GLfloat upperLeft[] = {lowerLeft[0], upperRight[1], lowerLeft[2]}; //upperLeft
    
    glEnable(GL_TEXTURE_RECTANGLE_EXT);
    glBindTexture(GL_TEXTURE_RECTANGLE_EXT, textureNumber);
    glBegin(GL_QUADS); 
    {   
        
        glTexCoord2f (0.0f, 0.0f); // draw lower left in world coordinates
        glVertex3fv(lowerLeft);
        glTexCoord2f (textureSize.width, 0.0f); // draw lower left in world coordinates
        glVertex3fv(lowerRight);
        glTexCoord2f (textureSize.width, textureSize.height); // draw upper right in world coordinates
        glVertex3fv(upperRight);
        glTexCoord2f (0.0f, textureSize.height); // draw upper left in world coordinates
        glVertex3fv(upperLeft);

    } glEnd();
    glDisable(GL_TEXTURE_RECTANGLE_EXT);
}