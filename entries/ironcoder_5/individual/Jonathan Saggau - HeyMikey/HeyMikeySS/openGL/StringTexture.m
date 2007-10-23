/*
    StringTexture.m
    Modified from a Cocoa OpenGL Example shipped with Tiger's xcode
    (GLImageWall)
  */

#import "StringTexture.h"
#define LogMethod() NSLog(@"-[%@ %s]", self, _cmd)

@implementation StringTexture

- (void) deleteTexture
{
	if (texName) {
		//ensure that the context used to generated these is used to destroy them
		glDeleteTextures(1,&texName);
		texName = 0; // ensure it is zeroed for failure cases
	}
}

// designated initializer
- (id) initWithAttributedString:(NSAttributedString *)attributedString withTextColor:(NSColor *)text withBoxColor:(NSColor *)box withBorderColor:(NSColor *)border
{
	[super init];
	texName = 0;
	texSize.width = 0.0;
	texSize.height = 0.0;
	[attributedString retain];
	string = attributedString;
	[text retain];
	[box retain];
	[border retain];
	textColor = text;
	boxColor = box;
	borderColor = border;
	staticFrame = NO;
	marginSize.width = 4.0; // standard margins
	marginSize.height = 2.0;
	// all other variables 0 or NULL
	return self;
}

- (id) initWithString:(NSString *)aString withAttributes:(NSDictionary *)attribs withTextColor:(NSColor *)text withBoxColor:(NSColor *)box withBorderColor:(NSColor *)border
{
	return [self initWithAttributedString:[[[NSAttributedString alloc] initWithString:aString attributes:attribs] autorelease] withTextColor:text withBoxColor:box withBorderColor:border];
}

// basic methods that pick up defaults
- (id) initWithAttributedString:(NSAttributedString *)attributedString;
{
	return [self initWithAttributedString:attributedString withTextColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0] withBoxColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.0] withBorderColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.0]];
}

- (id) initWithString:(NSString *)aString withAttributes:(NSDictionary *)attribs
{
	return [self initWithAttributedString:[[[NSAttributedString alloc] initWithString:aString attributes:attribs] autorelease] withTextColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0] withBoxColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.0] withBorderColor:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:0.0]];
}

- (void) dealloc
{
	[self deleteTexture];
	[textColor release];
	[boxColor release];
	[borderColor release];
	[string release];
	[super dealloc];
}

- (GLuint) texName
{
	return texName;
}

- (NSSize) texSize
{
	return texSize;
}

- (NSColor *) textColor
{
	return textColor;
}

- (NSColor *) boxColor
{
	return boxColor;
}

- (NSColor *) borderColor
{
	return borderColor;
}

- (NSSize) framesize
{
    if( 0 == [string length] )
    {
        _framesize = NSMakeSize(0,0);
    }
    else
    {
        if ((NO == staticFrame) && ((0.0 == _framesize.width) || (0.0 == _framesize.height))) { 
            // find frame size if we have not already found it
            _framesize = [string size]; // current string size
            _framesize.width += marginSize.width * 2.0; // add padding
            _framesize.height += marginSize.height * 2.0;
        }
    }
	return _framesize;
}

- (NSSize) marginSize
{
	return marginSize;
}

- (BOOL) staticFrame
{
	return staticFrame;
}

- (void) genTexture; // generates the texture without drawing texture to current context
{
    
    [self deleteTexture];
    NSSize framesize = [self framesize];
    if (0 == framesize.width || framesize.height == 0)
        return; // delete texture and bail if we have no dimensions.
    
    //http://developer.apple.com/documentation/GraphicsImaging/Conceptual/OpenGL-MacProgGuide/opengl_texturedata/chapter_10_section_5.html
	NSImage * image;
	NSBitmapImageRep * bitmap;
	
	if ((NO == staticFrame) && (0.0 == framesize.width) && (0.0 == framesize.height)) { // find frame size if we have not already found it
        //NSLog(@"NOt Static Frame");
		framesize = [string size]; // current string size
		framesize.width += marginSize.width * 2.0; // add padding
		framesize.height += marginSize.height * 2.0;
	}
    else
	image = [[NSImage alloc] initWithSize:framesize];
	[image lockFocus];
	if ([boxColor alphaComponent]) { // this should be == 0.0 but need to make sure
		[boxColor set]; 
		NSRectFill (NSMakeRect (0.0, 0.0, framesize.width, framesize.height));
	}
	if ([borderColor alphaComponent]) {
		[borderColor set]; 
		NSFrameRect (NSMakeRect (0.0, 0.0, framesize.width, framesize.height));
	}
	[textColor set]; 
	[string drawAtPoint:NSMakePoint (marginSize.width, marginSize.height)]; // draw at offset position
	bitmap = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect (0.0, 0.0, framesize.width, framesize.height)];
	[image unlockFocus];
	texSize.width = [bitmap size].width;
	texSize.height = [bitmap size].height;
    
    //enable non power of 2 texture
    glEnable(GL_TEXTURE_RECTANGLE_EXT);
    glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap pixelsWide]);
    glPixelStorei (GL_UNPACK_ALIGNMENT, 1);
    glGenTextures (1, &texName);
    glBindTexture (GL_TEXTURE_RECTANGLE_EXT, texName);
    if(![bitmap isPlanar]) {
        glTexImage2D (GL_TEXTURE_RECTANGLE_EXT, 0, GL_RGBA, texSize.width, texSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [bitmap bitmapData]);        
    } else { 
        fprintf(stderr, "No dice makin' the string texture\n");
        exit(EXIT_FAILURE);
    }
    glDisable(GL_TEXTURE_RECTANGLE_EXT);
	[bitmap release];
	[image release];
}

- (void) drawWithBounds:(NSRect)bounds
{
	if (!texName)
		[self genTexture];
	if (texName) {
		glEnable(GL_TEXTURE_RECTANGLE_EXT);
		glBindTexture (GL_TEXTURE_RECTANGLE_EXT, texName);
		glBegin (GL_QUADS);
			glTexCoord3f (0.0, 0.0, 0.0); // draw upper left in world coordinates
			glVertex2f (bounds.origin.x, bounds.origin.y);
	
			glTexCoord3f (0.0, texSize.height, 0.0); // draw lower left in world coordinates
			glVertex2f (bounds.origin.x, bounds.origin.y + bounds.size.height);
	
			glTexCoord3f (texSize.width, texSize.height, 0.0); // draw upper right in world coordinates
			glVertex2f (bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size.height);
	
			glTexCoord3f (texSize.width, 0.0, 0.0); // draw lower right in world coordinates
			glVertex2f (bounds.origin.x + bounds.size.width, bounds.origin.y);
		glEnd ();
		glDisable(GL_TEXTURE_RECTANGLE_EXT);
	}
}

- (void) drawAtPoint:(NSPoint)point
{
   
	if (!texName)
		[self genTexture]; // ensure size is calculated for bounds
	if (texName) // if successful
		[self drawWithBounds:NSMakeRect (point.x, point.y, texSize.width, texSize.height)];
}

// these will force the texture to be regenerated at the next draw
- (void) setMargins:(NSSize)size // set offset size and size to fit with offset
{
	[self deleteTexture];
	marginSize = size;
	if (NO == staticFrame) { // ensure dynamic frame sizes will be recalculated
		_framesize.width = 0.0;
		_framesize.height = 0.0;
	}
}

- (void) useStaticFrame:(NSSize)size // set static frame size and size to frame
{
	[self deleteTexture];
	_framesize = size;
	staticFrame = YES;
}

- (void) useDynamicFrame
{
	if (staticFrame) { // set to dynamic frame and set to regen texture
		[self deleteTexture];
		staticFrame = NO;
		_framesize.width = 0.0; // ensure frame sizes will be recalculated
		_framesize.height = 0.0;
	}
}

- (void) setString:(NSAttributedString *)attributedString // set string after initial creation
{
	[self deleteTexture];
	[attributedString retain];
	[string release];
	string = attributedString;
	if (NO == staticFrame) { // ensure dynamic frame sizes will be recalculated
		_framesize.width = 0.0;
		_framesize.height = 0.0;
	}
}

- (void) setString:(NSString *)aString withAttributes:(NSDictionary *)attribs; // set string after initial creation
{
	[self setString:[[[NSAttributedString alloc] initWithString:aString attributes:attribs] autorelease]];
}

- (void) setTextColor:(NSColor *)color // set default text color
{
	[self deleteTexture];
	[color retain];
	[textColor release];
	textColor = color;
}

- (void) setBoxColor:(NSColor *)color // set default text color
{
	[self deleteTexture];
	[color retain];
	[boxColor release];
	boxColor = color;
}

- (void) setBorderColor:(NSColor *)color // set default text color
{
	[self deleteTexture];
	[color retain];
	[borderColor release];
	borderColor = color;
}

- (NSAttributedString *) string
{
    return string;
}

@end
