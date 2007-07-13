// BWShader.h -- interface to a wrapper around a CGShader

#import <Cocoa/Cocoa.h>

// abstrat base class
@interface BWShader : NSObject
{
    // the color space for the shader
    CGColorSpaceRef colorSpace;

    // the shader
    CGFunctionRef shaderFunction;
}

// designated initializer
- (id) initWithCallbacks: (CGFunctionCallbacks) callbacks
           andColorSpace: (CGColorSpaceRef) colorspace;

// do the drawing
- (void) drawInContext: (CGContextRef) context;

// subclasses override this to make the actual shader (axial or radial, or
// whatever) to be used in drawing.
- (CGShadingRef) createShader;

@end // BWShader


// Axial (linear) Shading

@interface BWAxialShader : BWShader
{
    // interpolate between two colors
    NSColor *startColor, *endColor;

    // shade from point A to point B.  Actual shading is perpendicular
    // and extends out to infinity
    NSPoint startPoint, endPoint;

    // fill in the rest of the world with the start and end color
    BOOL extendStart, extendEnd;

    // cache of the RGB values from the colors, so we don't have
    // to do that every time in the shader function.
    float startRgb[3];
    float endRgb[3];
}

// creation methods

+ (id) shaderWithStartColor: (NSColor *) start
                   endColor: (NSColor *) end
                 startPoint: (NSPoint) point
                   endPoint: (NSPoint) endPoint
                extendStart: (BOOL) extendStart
                  extendEnd: (BOOL) extendEnd
                 colorSpace: (CGColorSpaceRef) colorSpace;

@end // BWAxialShader




