#ifndef _MODEL_LOADER_H_
#define _MODEL_LOADER_H_

#pragma mark *** Includes ***

#import <OpenGL/gl.h>

#pragma mark *** Definitions ***


typedef struct
{
	char name[32];
	int start;
	int end;
}WFGroup;

typedef struct
{
	GLfloat u, v, w;
}WFUVCoord;

typedef struct
{
	GLfloat x, y, z;
}WFVertex;

typedef struct
{
	GLfloat x, y, z;
}WFNormal;

typedef struct
{
	int vertex;
	int normal;
	int texture;
}WFFace;

typedef struct
{
	WFNormal normal;
	WFUVCoord texture;
	WFVertex vertex;
}WFNormalTextureVertex;

typedef struct
{
	WFVertex * vertices;
	WFUVCoord * texture_coords;
	WFNormal * normals;
	WFFace * faces;
	GLuint * indices;
	WFGroup * groups;
	
	unsigned long n_vertices;
	unsigned long n_texture_coords;
	unsigned long n_normals;
	unsigned long n_faces;
	unsigned long n_groups;
	
	GLuint vertex_buffer;
	GLuint index_buffer;
	GLuint normal_buffer;
	GLuint texture_buffer;
	
	GLuint display_list, display_list_valid;
	
	WFNormalTextureVertex * var_array;
}WFObject;


#pragma mark *** Prototypes ***

extern void obj_generateNormals(WFObject * object);
extern void obj_print(WFObject * object);
extern void obj_release(WFObject * object);
extern WFObject * obj_load(const char * path);

extern void obj_draw_arrays(WFObject * object);
extern void obj_draw_arrays_range(WFObject * object);
extern void obj_draw_vertex_buffers(WFObject * object);
extern void obj_draw_with_display_list(WFObject * object);
extern void obj_draw_immediate_mode(WFObject * object);

#endif