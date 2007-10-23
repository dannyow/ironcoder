
#include "model_loader.h"
#include "ctype.h"
#include "unistd.h"
#include "stdlib.h"
#include "stdio.h"
#include "math.h"

#include <OpenGL/glext.h>
#include <OpenGL/CGLCurrent.h>
#include <OpenGL/CGLMacro.h>

int object_countFacePoints(char * string)
{
    int n = 0;
	
	// Confirm and skip beginning 'f'
	if(*string == 'f')
	{
		string++;
	}
	
	while(*string)
	{
		// Skip white space...
		while(*string &&
			  isspace(*string))
		{
			string++;
		}
		
		// Skip this point in the face
		while(*string &&
			  !isspace(*string))
		{
			string++;
		}
		
		if(*string)
		{
			n++;
		}
	}
		
    return n;
}

int object_loadNormal(char * string, WFNormal * normal)
{
    int n = 0;
	
	// Confirm and skip beginning 'v' and 'n'
	if(*string == 'v')
	{
		string++;
		if(*string == 'n')
		{
			string++;
		}
	}
	
	while(*string)
	{
		// Skip white space...
		while(*string &&
			  isspace(*string))
		{
			string++;
		}
		
		// Load the x, y, and z values
		switch(n)
		{
			case 0:		normal->x = strtof(string, 0);		break;
			case 1:		normal->y = strtof(string, 0);		break;
			case 2:		normal->z = strtof(string, 0);		break;
		}
		
		// Skip this point in the face
		while(*string &&
			  !isspace(*string))
		{
			string++;
		}
		
		if(*string)
		{
			n++;
		}
	}
	
    return n;
}

int object_loadVertex(char * string, WFVertex * vertex)
{
    int n = 0;
	
	// Confirm and skip beginning 'v'
	if(*string == 'v')
	{
		string++;
	}
	
	while(*string)
	{
		// Skip white space...
		while(*string &&
			  isspace(*string))
		{
			string++;
		}
		
		// Load the x, y, and z values
		switch(n)
		{
			case 0:		vertex->x = strtof(string, 0);		break;
			case 1:		vertex->y = strtof(string, 0);		break;
			case 2:		vertex->z = strtof(string, 0);		break;
		}
		
		// Skip this point in the face
		while(*string &&
			  !isspace(*string))
		{
			string++;
		}
		
		if(*string)
		{
			n++;
		}
	}
	
    return n;
}

int object_loadFace(char * string, WFFace * face)
{
    //fprintf(stderr, "%s\n", string);
	int num_points = object_countFacePoints(string);
		
	// Confirm and skip beginning 'f'
	if(*string == 'f')
	{
		string++;
	}
	
	
	while(*string)
	{
		// Skip white space...
		while(*string &&
			  isspace(*string))
		{
			string++;
		}
		
		if(*string == 0)
		{
			break;
		}
		
		// If we have no counted the args yet, count them now
		// Remember there can be:
		// v/vt/vn
		// v//vn
		// v/vt
				
		face->vertex = strtol(string, &string, 0)-1;
		if(string[0] == '/' &&
		   string[1] == '/')
		{
			string += 2;
			face->normal = strtol(string, &string, 0)-1;
		}
		else
		{
			string++;
			face->texture = strtol(string, &string, 0)-1;
			if(string[0] == '/')
			{
				string++;
				face->normal = strtol(string, &string, 0)-1;
			}
		}
				
		face++;
	}
			
	if(num_points == 4)
	{
		// Handle converting a quad to a triangle...
		// A  D
		// +--+
		// |\ |
		// | \|
		// +--+
		// B  C
		//
		// The quad is A, B, C, D
		// The first triangle is A, B, C
		// The second triangle is C, D, A
		// So, we want A, B, C, D, A, C
		// face currently points to the fifth position
		
		face[0] = face[-4];
		face[1] = face[-2];
		
		num_points = 6;
	}
			
    return num_points;
}

#pragma mark -

void obj_generateNormals(WFObject * object)
/* Note: this is not as optimized as it could be.  We do not check
 * to see if we have duplicate normals (ie, normals with the same
 * value but for different vertices).  The architecture is there
 * (this is why we have indices into the normals array), but the
 * implementation of this is left to the user.
 */
{
	WFVertex * vertices = object->vertices;
	WFFace * face = object->faces;
	WFNormal * normals;
	
	unsigned long n_faces = 0, n_normals = 0;
	GLfloat * v1, * v2, * v3;
	GLfloat a[3], b[3], c[3];
	
	GLfloat length;
	
	// Do we have normals already?
	if(object->normals)
	{
		free(object->normals);
	}
	
	// Allocate space for new normals
	object->n_normals = object->n_vertices;
	object->normals = (WFNormal *)calloc(1, sizeof(WFNormal) * object->n_normals);
	normals = object->normals;
	
	// Run through all of the faces...
	n_faces = object->n_faces;
	while(n_faces -= 3)
	{
		// Calculate the normals for all of these vertices
		v1 = (GLfloat *)(vertices + face[0].vertex);
		v2 = (GLfloat *)(vertices + face[1].vertex);
		v3 = (GLfloat *)(vertices + face[2].vertex);
		
		// [v1 - v2] x [v2 - v3]
		a[0] = v1[0] - v2[0];
		a[1] = v1[1] - v2[1];
		a[2] = v1[2] - v2[2];
		
		b[0] = v2[0] - v3[0];
		b[1] = v2[1] - v3[1];
		b[2] = v2[2] - v3[2];
		
		// Cross product
		c[0] = a[1] * b[2] - a[2] * b[1];
		c[1] = a[2] * b[0] - a[0] * b[2];
		c[2] = a[0] * b[1] - a[1] * b[0];
		
		
		// Sum our normal to each vertex normal
		face[0].normal = face[0].vertex;
		v1 = (GLfloat *)(normals + face[0].normal);
		v1[0] += c[0];
		v1[1] += c[1];
		v1[2] += c[2];
		
		face[1].normal = face[1].vertex;
		v2 = (GLfloat *)(normals + face[1].normal);
		v2[0] += c[0];
		v2[1] += c[1];
		v2[2] += c[2];
		
		face[2].normal = face[2].vertex;
		v3 = (GLfloat *)(normals + face[2].normal);
		v3[0] += c[0];
		v3[1] += c[1];
		v3[2] += c[2];
		
		face += 3;
	}
	
	// Once we've summed all normals, the final step is to
	// run back through and normalize them.
	n_normals = object->n_normals;
	normals = object->normals;
	while(n_normals--)
	{
		
		length = normals->x * normals->x + normals->y * normals->y;
		length += normals->z * normals->z;
		length = sqrtf(length);
		
		// Normalize the normal...
		if (length != 0.0)
		{
			length = 1.0 / length;
			normals->x *= length;
			normals->y *= length;
			normals->z *= length;
		}
		
		normals++;
	}
}

void obj_print(WFObject * object)
{
    fprintf(stderr, "%p memLocal\n", object);
	fprintf(stderr, "%d vertices\n", object->n_vertices);
	fprintf(stderr, "%d texture coords\n", object->n_texture_coords);
	fprintf(stderr, "%d normals\n", object->n_normals);
	fprintf(stderr, "%d faces\n", object->n_faces);
	fprintf(stderr, "%d groups\n", object->n_groups);
}

void obj_release(WFObject * object)
{
	if(object)
	{
		if(object->vertices)
		{
			free(object->vertices);
		}
		if(object->texture_coords)
		{
			free(object->texture_coords);
		}
		if(object->normals)
		{
			free(object->normals);
		}
		if(object->faces)
		{
			free(object->faces);
		}
		if(object->groups)
		{
			free(object->groups);
		}
		if(object->indices)
		{
			free(object->indices);
		}
		
		free(object);
	}
}

WFObject * obj_load(const char * path)
{
	WFObject * object = (WFObject *)malloc(sizeof(WFObject));
	FILE * file = fopen(path, "r");
	char line[256] = {0};
	
	unsigned int face_count;
	WFVertex * cur_vertex = 0;
	WFUVCoord * cur_texture_coords = 0;
	WFNormal * cur_normal = 0;
	WFFace * cur_face = 0;
	WFGroup * cur_group = 0;
	GLuint * cur_index = 0;
	
	WFNormal * local_normals;
	WFUVCoord * local_tex_coords;
	
	if(!file)
	{
		fprintf(stderr, "Unable to open object file %s\n", path);
		return NULL;
	}
	
	if(!object)
	{
		fprintf(stderr, "Unable to allocate memory when loading object file %s\n", path);
		return NULL;
	}
	
	// First task is to count the file contents... some exporters will
	// include this information in a comment at the head of the file, but
	// this is not part of the standard.
	
	object->n_vertices = 0;
	object->n_texture_coords = 0;
	object->n_normals = 0;
	object->n_faces = 0;
	object->n_groups = 0;
	object->display_list_valid = 0;
	object->var_array = 0;
	object->vertex_buffer = 0;
	
	while(fgets(line, sizeof(line), file))
	{
		if(line[0] == 'v')
		{
			if(line[1] == ' ')
			{
				// Vertices are always in (x, y, z) tuples
				object->n_vertices++;
			}
			if(line[1] == 't')
			{
				// Texture coords are always in (u, v, w) pairs
				// (w is optional)
				object->n_texture_coords++;
			}
			if(line[1] == 'n')
			{
				// Vertices are always in (x, y, z) tuples
				object->n_normals++;
			}
		}
		else if(line[0] == 'g')
		{
			// The group tag is followed by a list of group names the
			// following faces belong to.  We're going to support the
			// simple case of each face belonging to a single group.
			object->n_groups++;
		}
		else if(line[0] == 'f')
		{
			// Counting faces is trickier.
			// 
			// For each point on a face, it can contain:
			// (vertex)/(texture)/(normal)
			// (vertex)//(normal)
			// (vertex)/(texture)
			
			// Each point is separated by white space.
			// There can be any number of points per face.  We will
			// only support 3 or 4 points per face, and we will collapse
			// quads into triangles in preparation of optimizations we'll
			// perform in the next exercise.
			int n = object_countFacePoints(line);
			
			if(n == 4)
			{
				// We want to convert quads to triangles, so instead of
				// four points for this face, we need six points for two
				// triangles
				object->n_faces += 6;
			}
			else
			{
				object->n_faces += 3;
			}
		}
	}
		
	// Now that we have the correct numbers, let's 
	// allocate space to load everything.
	rewind(file);
	
	// Perform some checks:
	// While it is perfectly legal for a Wavefront Object file to contain
	// differing sizes for normals and textures compared to vertices, it will
	// be beneficial for OpenGL if we make sure that the arrays are of the
	// same length.  Basically, we want the ith element of the vertex array
	// to be associated with the ith element of the normal array to be
	// associated with the ith element of the texture coords array.
	if(object->n_texture_coords)
	{
		object->n_texture_coords = object->n_vertices;
	}
	if(object->n_normals)
	{
		object->n_normals = object->n_vertices;
	}
		
	object->vertices = (WFVertex *)calloc(1, sizeof(WFVertex) * object->n_vertices);
	object->faces = (WFFace *)calloc(1, sizeof(WFFace) * object->n_faces);
	object->indices = (GLuint *)calloc(1, sizeof(GLuint) * object->n_faces);
	object->groups = (WFGroup *)calloc(1, sizeof(WFGroup) * object->n_groups);
	
	object->texture_coords = (WFUVCoord *)calloc(1, sizeof(WFUVCoord) * object->n_texture_coords);
	local_tex_coords = (WFUVCoord *)calloc(1, sizeof(WFUVCoord) * object->n_texture_coords);
	
	object->normals = (WFNormal *)calloc(1, sizeof(WFNormal) * object->n_normals);
	local_normals = (WFNormal *)calloc(1, sizeof(WFNormal) * object->n_normals);
	
	
	face_count = 0;
	cur_vertex = object->vertices;
	cur_texture_coords = local_tex_coords;
	cur_normal = local_normals;
	cur_face = object->faces;
	cur_group = object->groups;
	
	while(fgets(line, sizeof(line), file))
	{
		if(line[0] == 'v')
		{
			if(line[1] == ' ')
			{
				object_loadVertex(line, cur_vertex++);
			}
			if(line[1] == 't')
			{
				
			}
			if(line[1] == 'n')
			{
				object_loadNormal(line, cur_normal++);
			}
		}
		else if(line[0] == 'g')
		{
			
		}
		else if(line[0] == 'f')
		{
			cur_face += object_loadFace(line, cur_face);
		}
	}
	
	// Now we need to run through the defined faces and fill out the actual
	// normal and texture coordinate arrays...
	// Run through all of the triangles and render them...
	cur_face = object->faces;
	face_count = object->n_faces;
	cur_index = object->indices;
	
	while(face_count--)
	{
		*cur_index = cur_face->vertex;
		if(object->n_normals)
		{
			object->normals[*cur_index] = local_normals[cur_face->normal];
			cur_face->normal = *cur_index;
		}
		if(object->n_texture_coords)
		{
			object->texture_coords[*cur_index] = local_tex_coords[cur_face->texture];
			cur_face->texture = *cur_index;
		}
		
		cur_face++;
		cur_index++;
	}

	
	free(local_normals);
	free(local_tex_coords);
	
	return object;
}


#pragma mark -

void obj_draw_immediate_mode(WFObject * object)
{
	CGLContextObj cgl_ctx = CGLGetCurrentContext();
	
	// Run through all of the triangles and render them...
	WFNormal * normals = object->normals;
	WFVertex * vertices = object->vertices;
	WFUVCoord * textures = object->texture_coords;
	WFFace * face = object->faces;
	unsigned long n_faces = object->n_faces;
	
	glBegin(GL_TRIANGLES);
	
	if(normals && vertices && textures)
	{
		while(n_faces--)
		{
			glTexCoord3fv((GLfloat *)(textures + face->texture));
			glNormal3fv((GLfloat *)(normals + face->normal));
			glVertex3fv((GLfloat *)(vertices + face->vertex));
			
			face++;
		}
	}
	else if(normals && vertices)
	{
		while(n_faces--)
		{
			glNormal3fv((GLfloat *)(normals + face->normal));
			glVertex3fv((GLfloat *)(vertices + face->vertex));
			
			face++;
		}
	}
	else if(vertices)
	{
		while(n_faces--)
		{
			glVertex3fv((GLfloat *)(vertices + face->vertex));
			
			face++;
		}
	}
	
	glEnd();
}

void obj_draw_arrays(WFObject * object)
{
	CGLContextObj cgl_ctx = CGLGetCurrentContext();
	
	// Run through all of the triangles and render them...
	WFNormal * normals = object->normals;
	WFVertex * vertices = object->vertices;
	WFUVCoord * tex_coords = object->texture_coords;
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	
	if(normals)
	{
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer(GL_FLOAT, 0, normals);
	}
	if(tex_coords)
	{
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(3, GL_FLOAT, 0, tex_coords);
	}
	
	
	glDrawElements(GL_TRIANGLES, object->n_faces, GL_UNSIGNED_INT, object->indices);
	
	
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
}

void obj_draw_arrays_range(WFObject * object)
{
	CGLContextObj cgl_ctx = CGLGetCurrentContext();

	if(!object->var_array)
	{
		WFFace * cur_face;
		unsigned long face_count;
		WFNormalTextureVertex * cur_point;
		
		// For Vertex Array Range, we need to submit vertices using
		// glDrawArrays().  For this, we need to compile our separate
		// arrays into one, interleaved array which does not depend
		// on indices.
		object->var_array = (WFNormalTextureVertex*)malloc(sizeof(WFNormalTextureVertex) * object->n_faces);
		
		// Run through the faces and populate the var
		cur_face = object->faces;
		face_count = object->n_faces;
		cur_point = object->var_array;
		
		while(face_count--)
		{
			cur_point->vertex = object->vertices[cur_face->vertex];
			cur_point->normal = object->normals[cur_face->normal];
			cur_point->texture = object->texture_coords[cur_face->texture];
			
			cur_face++;
			cur_point++;
		}
		
		// Once we have our monolithic array, we can tell OpenGL to
		// cache it in video memory...
		
		glEnableClientState(GL_VERTEX_ARRAY_RANGE_APPLE);
		
		glVertexArrayParameteriAPPLE(GL_VERTEX_ARRAY_STORAGE_HINT_APPLE,
									 GL_STORAGE_CACHED_APPLE);
		
		glVertexArrayRangeAPPLE(sizeof(WFNormalTextureVertex) * object->n_faces, object->var_array);
		
	}
	
		
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, sizeof(WFNormalTextureVertex), &object->var_array[0].vertex);
	glEnableClientState(GL_NORMAL_ARRAY);
	glNormalPointer(GL_FLOAT, sizeof(WFNormalTextureVertex), &object->var_array[0].normal);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(3, GL_FLOAT, sizeof(WFNormalTextureVertex), &object->var_array[0].texture);
	
	glDrawArrays(GL_TRIANGLES, 0, object->n_faces);
	
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
}

void obj_draw_vertex_buffers(WFObject * object)
{
	CGLContextObj cgl_ctx = CGLGetCurrentContext();
	#define BUFFER_OFFSET(i) ((char*)NULL + (i))
		
	if(!object->vertex_buffer)
	{
		glEnableClientState(GL_VERTEX_ARRAY);
		
		glGenBuffers(1, &object->vertex_buffer);
		glBindBuffer(GL_ARRAY_BUFFER, object->vertex_buffer);
		glBufferData(GL_ARRAY_BUFFER, object->n_vertices * sizeof(WFVertex), object->vertices, GL_STATIC_DRAW);
		
		
		glGenBuffers(1, &object->index_buffer);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, object->index_buffer);
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, object->n_faces * sizeof(GLuint), object->indices, GL_STATIC_DRAW);
		
		
		if(object->n_normals)
		{
			glGenBuffers(1, &object->normal_buffer);
			glBindBuffer(GL_ARRAY_BUFFER, object->normal_buffer);
			glBufferData(GL_ARRAY_BUFFER, object->n_normals * sizeof(WFNormal), object->normals, GL_STATIC_DRAW);
		}
		
		if(object->n_texture_coords)
		{
			glGenBuffers(1, &object->texture_buffer);
			glBindBuffer(GL_ARRAY_BUFFER, object->texture_buffer);
			glBufferData(GL_ARRAY_BUFFER, object->n_texture_coords * sizeof(WFUVCoord), object->texture_coords, GL_STATIC_DRAW);
		}
	}
	
	
	glBindBuffer(GL_ARRAY_BUFFER, object->vertex_buffer);
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3, GL_FLOAT, 0, BUFFER_OFFSET(0));
	
	if(object->n_normals)
	{
		glBindBuffer(GL_ARRAY_BUFFER, object->normal_buffer);
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer(GL_FLOAT, 0, BUFFER_OFFSET(0));
	}
	
	if(object->n_texture_coords)
	{
		glBindBuffer(GL_ARRAY_BUFFER, object->texture_buffer);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(3, GL_FLOAT, 0, BUFFER_OFFSET(0));
	}
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, object->index_buffer);
	glDrawElements(GL_TRIANGLES, object->n_faces, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
	
	
	glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
}

void obj_draw_with_display_list(WFObject * object)
{
//    fprintf(stderr, "obj_draw_with_display_list memory = %p\n", object);
	CGLContextObj cgl_ctx = CGLGetCurrentContext();

	if(object->display_list_valid)
	{
		glCallList(object->display_list);
	}
	else
	{
		object->display_list = glGenLists(1);
		
		glNewList(object->display_list, GL_COMPILE_AND_EXECUTE);
		
		obj_draw_immediate_mode(object);
		
		glEndList();
		
		object->display_list_valid = 1;
	}
}