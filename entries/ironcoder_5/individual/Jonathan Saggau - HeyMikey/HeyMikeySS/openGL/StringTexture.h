#import <Foundation/Foundation.h>
#import <OpenGL/gl.h>
#import <OpenGL/glext.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/CGLContext.h>
#import <Cocoa/Cocoa.h>

@interface StringTexture : NSObject {
	GLuint texName;
	NSSize texSize;
	
	NSAttributedString * string;
	NSColor * textColor; // default is opaque white
	NSColor * boxColor; // default transparent or none
	NSColor * borderColor; // default transparent or none
	BOOL staticFrame; // default in NO
	NSSize marginSize; // offset or frame size, default is 4 width 2 height
	NSSize _framesize; // offset or frame size, default is 4 width 2 height
}

// this API requires a current rendering context and all operations will be performed in regards to that context
// the same context should be current for all method calls for a particular object instance

// designated initializer
- (id) initWithAttributedString:(NSAttributedString *)attributedString withTextColor:(NSColor *)color withBoxColor:(NSColor *)color withBorderColor:(NSColor *)color;

- (id) initWithString:(NSString *)aString withAttributes:(NSDictionary *)attribs withTextColor:(NSColor *)color withBoxColor:(NSColor *)color withBorderColor:(NSColor *)color;

// basic methods that pick up defaults
- (id) initWithString:(NSString *)aString withAttributes:(NSDictionary *)attribs;
- (id) initWithAttributedString:(NSAttributedString *)attributedString;

- (void) dealloc;

- (GLuint) texName; // 0 if no texture allocated (usually an error condition)
- (NSSize) texSize; // actually size of texture generated in texels, (0, 0) if no texture allocated

- (NSColor *) textColor; // get the pre-multiplied default text color (includes alpha) string attributes could override this
- (NSColor *) boxColor; // get the pre-multiplied box color (includes alpha) alpha of 0.0 means no background box
- (NSColor *) borderColor; // get the pre-multiplied border color (includes alpha) alpha of 0.0 means no border
- (BOOL) staticFrame; // returns whether or not a static frame will be used

- (NSSize) framesize; // returns either dynamc frame (text sizze + margins) or static frame size (switch with staticFrame)

- (NSSize) marginSize; // current margins for text offset and pads for dynamic frame

- (void) genTexture; // generates the texture without drawing texture to current context
- (void) drawWithBounds:(NSRect)bounds; // will update the texture if required due to change in settings (note context should be setup to be orthographic scaled to per pixel scale)
- (void) drawAtPoint:(NSPoint)point;

// these will force the texture to be regenerated at the next draw
- (void) setMargins:(NSSize)size; // set offset size and size to fit with offset
- (void) useStaticFrame:(NSSize)size; // set static frame size and size to frame
- (void) useDynamicFrame; // set static frame size and size to frame

- (void) setString:(NSAttributedString *)attributedString; // set string after initial creation
- (void) setString:(NSString *)aString withAttributes:(NSDictionary *)attribs; // set string after initial creation

- (void) setTextColor:(NSColor *)color; // set default text color
- (void) setBoxColor:(NSColor *)color; // set default text color
- (void) setBorderColor:(NSColor *)color; // set default text color

- (NSAttributedString *) string;

@end

