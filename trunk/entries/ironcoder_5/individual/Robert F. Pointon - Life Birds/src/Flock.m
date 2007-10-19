#import "Flock.h"

#include <OpenGL/gl.h>

static const vec3_t bMin = {-400,-400,-400};
static const vec3_t bMax = { 400, 400, 400};
static const float t = 0.7; //time step
static const float sqNeighDist = 1000.0;
static const float sqAvoidDist = 49.0; //must be < sqNeighDist
static const float maxVel = 6.0;
static const float maxAcc = 0.1;
static const float focus = 0.01;
static const float avoid = 1.0;
static const float follow = 0.125;
static const float bound = 0.4;
static const int perchTime = 120;
static const int flockMax = 5;
static const float lift = 0.1;
static const float gravity = -0.05;

static float randf(float minv, float maxv) {
    return (rand()%1000) * (maxv-minv)/1000.0 + minv;
}

static void vrand(vec3_t *r, vec3_t a, vec3_t b) {
	vinit(r, randf(a.x, b.x), randf(a.y, b.y), randf(a.z, b.z));
}

//fills the array with boids within the givin region
static void findBoids(oct_t *p, vec3_t bmin, vec3_t bmax, boid_t *result[], int *cnt) {
	if(!p) return;
	if(p->list) {
		// Add list to array
        boid_t *b;
        for(b = p->list; b; b = b->next)
            result[(*cnt)++] = b;
    } else {
		int i;
		int flags = 0xFF; //mask out octs outside of region
		if(p->pos.x < bmin.x) flags &= 0xF0; else if(p->pos.x > bmax.x) flags &= 0x0F; //4567 vs 0123
		if(p->pos.y < bmin.y) flags &= 0xCC; else if(p->pos.y > bmax.y) flags &= 0x33; //2367 vs 0145
		if(p->pos.z < bmin.z) flags &= 0xAA; else if(p->pos.z > bmax.z) flags &= 0x55; //1357 vs 0246	
		for(i = 0; flags; i++) {
			if(flags&0x01) findBoids(p->sub[i], bmin, bmax, result, cnt);
			flags >>= 1;
		}
	}
}


//limit number of boids per oct
#define OCT_COUNT 6 

static void addOct(oct_t **p, boid_t *b, vec3_t bmin, vec3_t bmax, oct_t**allocater);

static void addOct2(oct_t *p, boid_t *b, vec3_t bmin, vec3_t bmax, oct_t**allocater) {
	int d;
	if(b->pos.x < p->pos.x) {
		if(b->pos.y < p->pos.y) {
			if(b->pos.z < p->pos.z) {
				bmax = p->pos;
				d = 0;
			} else {
				bmax.x = p->pos.x;
				bmax.y = p->pos.y;
				bmin.z = p->pos.z;
				d = 1;
			}
		} else {
			if(b->pos.z < p->pos.z) {
				bmax.x = p->pos.x;
				bmin.y = p->pos.y;
				bmax.z = p->pos.z;
				d = 2;
			} else {
				bmax.x = p->pos.x;
				bmin.y = p->pos.y;
				bmin.z = p->pos.z;
				d = 3;
			}
		}
	} else {
		if(b->pos.y < p->pos.y) {
			if(b->pos.z < p->pos.z) {
				bmin.x = p->pos.x;
				bmax.y = p->pos.y;
				bmax.z = p->pos.z;
				d = 4;
			} else {
				bmin.x = p->pos.x;
				bmax.y = p->pos.y;
				bmin.z = p->pos.z;
				d = 5;
			}
		} else {
			if(b->pos.z < p->pos.z) {
				bmin.x = p->pos.x;
				bmin.y = p->pos.y;
				bmax.z = p->pos.z;
				d = 6;
			} else {
				bmin = p->pos;
				d = 7;
			}
		}
	}
	addOct(p->sub + d, b, bmin, bmax, allocater);	
}

static void addOct(oct_t **p, boid_t *b, vec3_t bmin, vec3_t bmax, oct_t**allocater) {
	if(!*p) {
		//create a new oct with a single node
		vinc(&bmin, bmax);
		vscale(&bmin, 0.5);
        
        *p = (*allocater)++; //ugh...    
        (*p)->pos = bmin;
		(*p)->list = b;
        int i;
        for(i = 0; i < 8; i++) (*p)->sub[i] = NULL;
		return;
	}
	if((*p)->list) {
		int cnt = 0;
		boid_t *l;
		for(l = (*p)->list; l; l = l->next) cnt++;
		if(cnt < OCT_COUNT) {
			//add into the list
			b->next = (*p)->list;
			(*p)->list = b;
			return;
		}
		//split the list up and push elements down
		l = (*p)->list;
		while(l) {
			boid_t *c = l;
			l = c->next;
			c->next = NULL;
			addOct2(*p, c, bmin, bmax, allocater);
		} 
		(*p)->list = NULL;
	}
	addOct2(*p, b, bmin, bmax, allocater);
}




@implementation Flock

- (id)init {
    if((self=[super init])) {
        //build and cache a quick and dirty quad mesh
        unsigned int x,y;
        for(y = 0; y < MAXLIFE; y++) {
            for(x = 0; x < MAXLIFE; x++) {
                unsigned int i = x + y*MAXLIFE;
                vertices[i][0] = bMin.x + x*(bMax.x-bMin.x)/MAXLIFE;
                vertices[i][1] = bMin.y;
                vertices[i][2] = bMin.z + y*(bMax.z-bMin.z)/MAXLIFE;
            }
        }
        for(y = 0; y < MAXLIFE-1; y++) {
            for(x = 0; x < MAXLIFE-1; x++) {
                unsigned int i = 4*(x + y*(MAXLIFE-1));
                unsigned int j = x + y*MAXLIFE;
                indices[i] = j;
                indices[i+1] = j+1;
                indices[i+2] = j+1+MAXLIFE;
                indices[i+3] = j+MAXLIFE;
            }
        }
        [self setSize:0];
        [self enableLife:NO];
    }
    return self;
}

- (void)setSize:(int)size {
    int i;
    if(size > MAXBOID) size = MAXBOID;
    boidCount = size ;
    for(i = 0; i < boidCount; i++) {
        boid_t *b = boids+i;
        b->perching = 0;
        b->flap = randf(0, 999);
        vrand(&b->pos, bMin, bMax);
        
        float pitch = randf(-M_PI/2.0, -M_PI*2.0);
        float yaw = randf(0, 2*M_PI);
        vinit(&b->vel, sin(pitch)*sin(yaw), sin(pitch)*cos(yaw),  cos(pitch));
        b->s = randf(0, maxVel);
    }
}

- (void)enableLife:(BOOL)alife {
    life = alife;
    if(!life) return;
    unsigned int x,y;
    for(y = 0; y < MAXLIFE; y++) {
        for(x = 0; x < MAXLIFE; x++) {
            unsigned int i = x + y*MAXLIFE;
            if(randf(0.0, 1.0) < 0.7) {
                colors[i][0] = 0.1f;
                colors[i][1] = 0.3f;
                colors[i][2] = 0.1f;
            } else {
                colors[i][0] = randf(0.15, 1.0);
                colors[i][1] = randf(0.0, 1.0);
                colors[i][2] = randf(0.0, 1.0);
            }
        }
    }
}

- (void)dealloc {
    //NSLog(@"dealloc %@", self);
    [super dealloc];
}

-(void)moveBoid:(boid_t *)c {
	vec3_t v1 = {0.0, 0.0, 0.0}; int n1 = 0;
	vec3_t v2 = {0.0, 0.0, 0.0};
	vec3_t v3 = {0.0, 0.0, 0.0};
	vec3_t v4 = {0.0, 0.0, 0.0};
	vec3_t v5 = {0.0, 0.0, 0.0}; int n5 = 0;
    int i;
    
	boid_t *neighbours[200];
	int cnt = 0;
	float d = sqrtf(sqNeighDist);
	vec3_t nmin, nmax;
	vinit(&nmin, c->pos.x - d, c->pos.y - d, c->pos.z - d);
	vinit(&nmax, c->pos.x + d, c->pos.y + d, c->pos.z + d);
	
	findBoids(octs, nmin, nmax, neighbours, &cnt);
	assert(cnt <= 200); //a little late!
    
	for(i = 0; i < cnt; i++) {
        boid_t *b = neighbours[i];
        if(b == c) continue;
        
        vec3_t diff = b->pos;
        vdec(&diff, c->pos);
        float sqD = vdot(diff, diff);
        if(sqD > sqNeighDist) continue;
                
        //avoid each other
        if(sqD < sqAvoidDist)
            vdec(&v2, diff);
        
        int visible = 1; 
        if(sqD > 0.01) {
            vscale(&diff, 1.0/sqrtf(sqD));
            float dot = vdot(diff, c->vel); //cos of angle between
            if(dot < -0.4 || dot > 0.95) visible = 0; //Cone of vision, note blind spot in front
        }
        
        if(visible) {
            //move towards center of mass
            vinc(&v1, b->pos);
            //match velocity
			vec3_t vel = b->vel;
			vscale(&vel, b->s);
            vinc(&v3, vel);
            n1++;
        } else {
            //move away from center of mass - can hear them chasing?
            vinc(&v5, b->pos);
            n5++;
        }
    }
    
    //towards focus - average by number of neighbours
    if(n1 != 0) {
		vscale(&v1, 1.0/n1);
		vdec(&v1, c->pos);
    }
    
    //scatter large flocks
    if(n1+n5 > flockMax) {
		vscale(&v1, -1.0);
		vinit(&v3, 0.0, 0.0, 0.0);
    } else if(n1 > 0) {    
		vscale(&v3, 1.0/n1);
		vec3_t vel = c->vel;
		vscale(&vel, c->s);
		vdec(&v3, vel);
    }

    //away from focus - average by number of neighbours
    if(n5 != 0) {
		vscale(&v5, 1.0/n5);
		vdec(&v5, c->pos);
		vdec(&v1, v5);
    }
        
    //stay in bounds
    if(c->pos.x < bMin.x) v4.x = 1.0; else if(c->pos.x > bMax.z) v4.x = -1.0;
    if(c->pos.y < bMin.y) v4.y = 1.0; else if(c->pos.y > bMax.y) v4.y = -1.0;
    if(c->pos.z < bMin.z) v4.z = 1.0; else if(c->pos.z > bMax.z) v4.z = -1.0;
    
    //calc acceleration
	vscale(&v1, focus);
	vscale(&v2, avoid);
	vscale(&v3, follow);
	vscale(&v4, bound);
	c->acc = v1;
	vinc(&c->acc, v2);
	vinc(&c->acc, v3);
	vinc(&c->acc, v4);
    
    //lift depends on speed
    c->acc.y += lift*c->s/maxVel + gravity;
    
	vscale(&c->acc, t*t);
    
    //constrain acceleration...
    float a = vdot(c->acc, c->acc);
    if(a > maxAcc*maxAcc) vscale(&c->acc, maxAcc/sqrtf(a));
}

-(void)moveBoids {
    int i;

	//regenerate oct tree of boids
    oct_t * root = NULL;
    oct_t *allocater = octs;
	for(i = 0; i < boidCount; i++) {
		boid_t *b = boids+i; 
		if(b->perching > 0) continue; //skip the perching ones...
        b->next = NULL;
		addOct(&root, b, bMin, bMax, &allocater);
    }
	    
    for(i = 0; i < boidCount; i++) {
		boid_t *b = boids+i; 
		if(b->perching > 0) continue;
        [self moveBoid:b];
    }

	
    for(i = 0; i < boidCount; i++) {
        boid_t *b = boids+i;  
		if(b->perching > 0) {
			b->perching--;
            
            //life coords
            int x = lroundf((b->pos.x-bMin.x)*MAXLIFE/(bMax.x-bMin.x));
            int y = lroundf((b->pos.z-bMin.z)*MAXLIFE/(bMax.z-bMin.z));
            if(x >= 0 && x < MAXLIFE && y >=0 && y < MAXLIFE) {
                unsigned int i = x+y*MAXLIFE;
                colors[i][0] = randf(0.15, 1.0);
                colors[i][1] = randf(0.0, 1.0);
                colors[i][2] = randf(0.0, 1.0);
            }
			continue;
		}
		
		//velocity
		vec3_t vel = b->vel;
		vscale(&vel, b->s);
		vinc(&vel, b->acc);
		
        b->s = sqrtf(vdot(vel, vel));
		if(b->s < 0.001) {
			vel = b->vel;
			b->s = 0.0; //handle zero velocity
		} else {
			vscale(&vel, 1.0/b->s);
			b->vel = vel;
			if(b->s > maxVel) 
				b->s = maxVel; //limit velocity
		}
        b->flap += b->s/maxVel; 
        if(b->flap >= 1000.0) b->flap -= 1000.0;
			
        //position
		vscale(&vel, b->s);
		vscale(&vel, t);
		vinc(&b->pos, vel);
		
		if(b->pos.y < bMin.y && perchTime != 0) {
            b->pos.y = bMin.y;
			b->s = 0.5*maxVel; //takeoff speed
            b->vel.y = -b->vel.y; //direction ready for takeoff;
			b->perching = perchTime+rand()%perchTime;
        }
    }
    
    //do conway style game of life...
    if(!life) return;
    
    //note - the first color channel is used to determine whether a cell is ON/OFF
    BOOL grid[MAXLIFE*MAXLIFE];
    unsigned int x,y;
    for(y = 0; y < MAXLIFE; y++) {
        for(x = 0; x < MAXLIFE; x++) {
            unsigned int i = x + y*MAXLIFE;
            grid[i] = (colors[i][0] > 0.12);
        }
    }
   
    #define MASKLIFE (MAXLIFE*MAXLIFE-1)

    for(y = 0; y < MAXLIFE; y++) {
        for(x = 0; x < MAXLIFE; x++) {
            unsigned int i = x + y*MAXLIFE;
            unsigned int j = i + MAXLIFE*MAXLIFE - (1+MAXLIFE);
            unsigned int n =
                grid[j&MASKLIFE] + grid[(j+1)&MASKLIFE] + grid[(j+2)&MASKLIFE] +
                grid[(j+MAXLIFE)&MASKLIFE] + grid[(j+2+MAXLIFE)&MASKLIFE] +
                grid[(j+MAXLIFE*2)&MASKLIFE] + grid[(j+1+MAXLIFE*2)&MASKLIFE] + grid[(j+2+MAXLIFE*2)&MASKLIFE];
            if(grid[i]) {
                if(n < 2 || n > 3) {
                    colors[i][0] = 0.1;
                    colors[i][1] = 0.3;
                    colors[i][2] = 0.1;
                }
            } else if(n==3) {
                colors[i][0] = randf(0.15, 1.0);
                colors[i][1] = randf(0.0, 1.0);
                colors[i][2] = randf(0.0, 1.0);
            }
        }
    }
}


-(void)drawBoids {
	vec3_t up = {0.0, 1.0, 0.0};
    
    //draw boids
    glBegin(GL_TRIANGLES);        
    int i;
    for(i = 0; i < boidCount; i++) {
        boid_t *b = boids+i;
        
        float c = b->s/maxVel;  //color by speed  
        
        float flap = 12.0*cos(b->flap*0.2);
		vec3_t vel = b->vel;
		vscale(&vel, 24.0);  
        		
		vec3_t off;
        
		vcross(&off, up, vel);
		vscale(&off, 2.0); //double vel again so tail is wide
		
		//head
        glNormal3f(vel.x, vel.y, vel.z);
		glColor3f(c, 0.8, 1.0-c);        
		glVertex3f(b->pos.x + vel.x, b->pos.y + vel.y, b->pos.z + vel.z);
		
		//tail
        glNormal3f(0.0f, 1.0f, 0.0f);
		glColor3f(c, 0.0, 1.0-c);
		glVertex3f(b->pos.x + off.x, flap + b->pos.y + off.y, b->pos.z + off.z);
        glColor3f(0.0, 0.0, 0.0);
        glVertex3f(b->pos.x, b->pos.y, b->pos.z);
        
        //head
        glNormal3f(vel.x, vel.y, vel.z);
        glColor3f(c, 0.8, 1.0-c);        
		glVertex3f(b->pos.x + vel.x, b->pos.y + vel.y, b->pos.z + vel.z);
        
        //tail
        glNormal3f(0.0f, 1.0f, 0.0f);
        glColor3f(c, 0.0, 1.0-c);
		glVertex3f(b->pos.x - off.x, flap + b->pos.y - off.y, b->pos.z - off.z);
        glColor3f(0.0, 0.0, 0.0);
        glVertex3f(b->pos.x, b->pos.y, b->pos.z);
	}
    glEnd();
}



-(void)drawGround {
    glNormal3f(0.0f, 1.0f, 0.0f);
    if(life) {
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        glColorPointer(3,  GL_FLOAT, 3*sizeof(GLfloat), colors);
        glVertexPointer(3, GL_FLOAT, 3*sizeof(GLfloat), vertices);
        glDrawElements(GL_QUADS, 4*(MAXLIFE-1)*(MAXLIFE-1), GL_UNSIGNED_SHORT, indices); 		
        glDisableClientState(GL_VERTEX_ARRAY);	
        glDisableClientState(GL_COLOR_ARRAY);
    } else {
        glColor3f(0.1, 0.3, 0.1);
        glBegin(GL_QUADS);
        glVertex3f(bMin.x, bMin.y, bMin.z);
        glVertex3f(bMax.x, bMin.y, bMin.z);
        glVertex3f(bMax.x, bMin.y, bMax.z);
        glVertex3f(bMin.x, bMin.y, bMax.z);
        glEnd();	
    }
}


@end
