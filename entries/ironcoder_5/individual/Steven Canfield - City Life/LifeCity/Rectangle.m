/*
  Rectangle.m
  LifeCity

  Created by Steven Canfield on 30/03/07.
  Copyright 2007 __MyCompanyName__. All rights reserved.
*/

#import "Rectangle.h"


@implementation Rectangle
- (id)initWithRect:(NSRect)r Z:(float)z {
	self = [super init];
	
	_rect = r;
	Z = z;
	
	return self;
}

- (void)setTexture:(Photo *)tex {
	texture = [tex retain];
}
- (void)draw {
	if( texture == NULL ) {
	glBegin(GL_QUADS);
		glColor4f( [_color redComponent] - 0.3, [_color greenComponent]  - 0.3, [_color blueComponent]  - 0.3, [_color alphaComponent] );
		glVertex3f( _rect.origin.x, _rect.origin.y, Z );
		
		glColor4f( [_color redComponent]  - 0.3, [_color greenComponent]  - 0.3, [_color blueComponent]  - 0.3, [_color alphaComponent] );
		glVertex3f( _rect.origin.x + _rect.size.width, _rect.origin.y, Z );
		
		glColor4f( [_color redComponent], [_color greenComponent], [_color blueComponent], [_color alphaComponent] );
		glVertex3f( _rect.origin.x + _rect.size.width, _rect.origin.y + _rect.size.height, Z );
		
		glColor4f( [_color redComponent], [_color greenComponent], [_color blueComponent], [_color alphaComponent] );
		glVertex3f( _rect.origin.x, _rect.origin.y + _rect.size.height, Z );
	glEnd();
	} else {
		glEnable(GL_TEXTURE_RECTANGLE_ARB) ;
		[texture set];
		glBegin(GL_QUADS);
		//	glColor4f( [_color redComponent] - 0.3, [_color greenComponent]  - 0.3, [_color blueComponent]  - 0.3, [_color alphaComponent] );
			glTexCoord2i( 0 , 0);
			glVertex3f( _rect.origin.x, _rect.origin.y, Z );
			
			glTexCoord2i( [texture width] , 0);
		//	glColor4f( [_color redComponent]  - 0.3, [_color greenComponent]  - 0.3, [_color blueComponent]  - 0.3, [_color alphaComponent] );
			glVertex3f( _rect.origin.x + _rect.size.width, _rect.origin.y, Z );
			
			glTexCoord2i( [texture width], [texture height]);
		//	glColor4f( [_color redComponent], [_color greenComponent], [_color blueComponent], [_color alphaComponent] );
			glVertex3f( _rect.origin.x + _rect.size.width, _rect.origin.y + _rect.size.height, Z );
			
			glTexCoord2i( 0 , [texture height]);
		//	glColor4f( [_color redComponent], [_color greenComponent], [_color blueComponent], [_color alphaComponent] );
			glVertex3f( _rect.origin.x, _rect.origin.y + _rect.size.height, Z );
		glEnd();
		glDisable(GL_TEXTURE_RECTANGLE_ARB) ;
	}

	glLineWidth(2.0);
	glBegin(GL_LINE_LOOP);
		glColor4f( [_color redComponent] + 0.2, [_color greenComponent] + 0.2, [_color blueComponent] + 0.2, [_color alphaComponent] + 0.2);
		glVertex3f( _rect.origin.x, _rect.origin.y, Z );
		
		glColor4f( [_color redComponent] + 0.2, [_color greenComponent] + 0.2, [_color blueComponent] + 0.2, [_color alphaComponent] + 0.2);
		glVertex3f( _rect.origin.x + _rect.size.width, _rect.origin.y, Z );
		
		glColor4f( [_color redComponent] + 0.2, [_color greenComponent] + 0.2, [_color blueComponent] + 0.2, [_color alphaComponent] + 0.2);
		glVertex3f( _rect.origin.x + _rect.size.width, _rect.origin.y + _rect.size.height, Z );
		
		glColor4f( [_color redComponent] + 0.2, [_color greenComponent] + 0.2, [_color blueComponent] + 0.2, [_color alphaComponent] + 0.2);
		glVertex3f( _rect.origin.x, _rect.origin.y + _rect.size.height, Z );
	glEnd();

}

- (void)setColor:(NSColor *)color
{
	[_color autorelease];
	_color = [[color copy] retain];
}
- (NSColor *)color { return _color; }

@end
