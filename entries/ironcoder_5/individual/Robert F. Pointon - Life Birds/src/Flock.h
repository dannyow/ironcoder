//
//  Flock.h
//  CoolScreenSaver
//
//  Created by Robert Pointon on 31/03/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>
#include "vec.h"

//this is cool up to about 5000
#define MAXBOID 1000


#define MAXLIFE 64

struct boid_t;
typedef struct boid_t boid_t;
struct boid_t {
    vec3_t acc;
    vec3_t vel; //normalized
	float s;    //unsigned speed for vel
    vec3_t pos;
    
    int perching; //0 = no
    float flap; //wraps 0...999
    
	boid_t *next; //used while within oct_t
};

#define MAXOCT MAXBOID*8

struct oct_t;
typedef struct oct_t oct_t; /* opaque */
struct oct_t {
	vec3_t pos; //cache - saves recalculation as traverse tree
	oct_t *sub[8];
	boid_t *list; //only used for leaf nodes
};

@interface Flock : NSObject {    
    int boidCount;
    boid_t boids[MAXBOID];
    //Keep a pool of octs... thus root = octs[0]...
    oct_t octs[MAXOCT];
    
    BOOL life;
    GLfloat vertices[MAXLIFE*MAXLIFE][3];
    GLfloat colors[MAXLIFE*MAXLIFE][3];
    GLushort indices[4*(MAXLIFE-1)*(MAXLIFE-1)];
}

- (void)setSize:(int)size;
- (void)enableLife:(BOOL)life;
- (void)drawBoids;
- (void)drawGround;
- (void)moveBoids;

@end
