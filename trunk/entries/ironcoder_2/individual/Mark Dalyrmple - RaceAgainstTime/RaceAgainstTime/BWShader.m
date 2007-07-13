// Cocoa wrapper around CGShaders

#import "BWShader.h"
#import "BWCGUtils.h"

@implementation BWShader

// Designated initializer.  The callbacks and color space are used by both
// axial and radial shaders, so consolidates this bit of initialization
// fooby.

- (id) initWithCallbacks: (CGFunctionCallbacks) callbacks
           andColorSpace: (CGColorSpaceRef) cs
{
    if ((self = [super init])) {
        colorSpace = cs;

        // colors and alpha have values from 0 to 1
        float domain[2] = { 0.0, 1.0 };	// 1-in function
        float range[8] = { 0.0, 1.0,	// N-out, RGBA
                           0.0, 1.0,
                           0.0, 1.0,
                           0.0, 1.0 };

        shaderFunction = CGFunctionCreate (self,   // info / rock / context
                                           1,	   // # of inputs for domain
                                           domain,
                                           4,	   // # of inputs for range
                                           range, 
                                           &callbacks);
    }

    return (self);

} // initWithCallbacks


// subclassess override this to actually make the CGShading object

- (CGShadingRef) createShader
{
    assert (!"subclassess need to verride");
} // createShader



// do the drawing.

- (void) drawInContext: (CGContextRef) context
{
    CGShadingRef shader = [self createShader];

    CGContextDrawShading (context, shader);

    CGShadingRelease (shader);

} // drawInContext

@end // BWShader



// Axial Shader.  There is no radial shader here yet.

@implementation BWAxialShader

// evaluation function that is called repeatedly during drawing.
// It acts like y = f(x), where there are arbitrary sets for the
// domain and range.  In our case, the domain is a single value
// that varies from zero to 1, the range is 4 values for the color
// to use.

// Info is the rock to hide data under, in is a value from the
// domain, out is the corresponding value from the range.

static void axialEvaluate (void *info, const float *in, float *out)
{
    BWAxialShader *shader = (BWAxialShader *) info;

    float thing;
    thing = in[0];

    // move through the delta between the components of the two
    // colors
    float redDelta = shader->startRgb[0] - shader->endRgb[0];
    float greenDelta = shader->startRgb[1] - shader->endRgb[1];
    float blueDelta = shader->startRgb[2] - shader->endRgb[2];

    out[0] = shader->startRgb[0] - redDelta * thing;
    out[1] = shader->startRgb[1] - greenDelta * thing;
    out[2] = shader->startRgb[2] - blueDelta * thing;
    out[3] = 1.0; // alpha

} // axialEvaluate


- (id) initWithStartColor: (NSColor *) start
                 endColor: (NSColor *) end
               startPoint: (NSPoint) sp
                 endPoint: (NSPoint) ep
              extendStart: (BOOL) es
                extendEnd: (BOOL) ee
               colorSpace: (CGColorSpaceRef) cs
{
    CGFunctionCallbacks backcalls = { 0, axialEvaluate, NULL };

    if ((self = [super initWithCallbacks: backcalls
                       andColorSpace: cs])) {
        startColor = [start retain];
        endColor = [end retain];
        startPoint = sp;
        endPoint = ep;
        extendStart = es;
        extendEnd = ee;

        startRgb[0] = [startColor redComponent];
        startRgb[1] = [startColor greenComponent];
        startRgb[2] = [startColor blueComponent];
        
        endRgb[0] = [endColor redComponent];
        endRgb[1] = [endColor greenComponent];
        endRgb[2] = [endColor blueComponent];
    }

    return (self);

} // initWithStartColor


- (void) dealloc
{
    [startColor release];
    [endColor release];

    [super dealloc];

} // dealloc


// convenience, since users will just want to make one, draw it, and
// nuke it.

+ (id) shaderWithStartColor: (NSColor *) start
                   endColor: (NSColor *) end
                 startPoint: (NSPoint) sp
                   endPoint: (NSPoint) ep
                extendStart: (BOOL) es
                  extendEnd: (BOOL) ee
                 colorSpace: (CGColorSpaceRef) cs
{
    id shader = [[self alloc] initWithStartColor: start
                              endColor: end
                              startPoint: sp
                              endPoint: ep
                              extendStart: es
                              extendEnd: ee
                              colorSpace: cs];
    
    return ([shader autorelease]);

} // shaderWithStartColor


// make a new shader with the specific attributes we were created
// with.

- (CGShadingRef) createShader
{
    CGShadingRef shader; // darth shader
    shader = CGShadingCreateAxial (colorSpace,
                                   cgpoint(startPoint),
                                   cgpoint(endPoint),
                                   shaderFunction,
                                   extendStart,
                                   extendEnd);
    return (shader);

} // createShader

@end // BWAxialShader



