#ifndef _VEC_H_
#define _VEC_H_

struct vec3_t;
typedef struct vec3_t vec3_t;
struct vec3_t {
    float x,y,z;
};

static inline void vinit(vec3_t *r, float x, float y, float z) {
	r->x = x;
	r->y = y;
	r->z = z;
}
static inline void vscale(vec3_t *r, float m) {
	r->x *= m;
	r->y *= m;
	r->z *= m;
}
static inline void vinc(vec3_t *r, vec3_t a) {
	r->x += a.x;
	r->y += a.y;
	r->z += a.z;
}
static inline void vdec(vec3_t *r, vec3_t a) {
	r->x -= a.x;
	r->y -= a.y;
	r->z -= a.z;
}
static inline float vdot(vec3_t a, vec3_t b) {
	return a.x*b.x + a.y*b.y + a.z*b.z;
}
static inline void vcross(vec3_t *r, vec3_t a, vec3_t b) {
	r->x = a.y*b.z - a.z*b.y;
	r->y = a.z*b.x - a.x*b.z;
	r->z = a.x*b.y - a.y*b.x;
}

#endif /*_VEC_H_*/
