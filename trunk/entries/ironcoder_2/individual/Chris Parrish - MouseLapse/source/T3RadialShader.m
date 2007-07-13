//
//  T3RadialShader.m
//  IronCoder v2
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import "T3RadialShader.h"
#import "T3CategoryNSGraphicsContext.h"

@interface T3RadialShader (PrivateMethods)

- (CGFunctionRef) createColorFunction:(CGFunctionEvaluateCallback)colorFunction;

- (CGShadingRef) createRadialShader:(CGPoint)start			       
						startRadius:(float)firstRadius
					       endPoint:(CGPoint)end
                          endRadius:(float)secondRadius;

@end
#pragma mark -

@implementation T3RadialShader

#pragma mark Color Computation Callbacks

//----- these callbacks map from an input value between 0.0 and 1.0 
//      to an output color

// Computes color values based on a sin wave trigonometric function
//		info : pointer to a T3RadialShader structure

static void colorComputation_sin( void* info, const float* in, float* out )
{
	double frequency[4] = { 55, 220, 110, 0 };
       // defines the frequency of the sin wave for each color component
	
	T3ShaderColorParameters* parameters = (T3ShaderColorParameters*)info;

	int	k;
    for ( k = 0; k < parameters->components - 1; k++)
	{
        *(out++) = ( 1 + ( sin( (*in) * frequency[k] ) ) )  / 2;
	}
		  
	 *(out++) = parameters->alpha;
}

// Computes color values based on simple linear mapping (good for spheres)
//		info : pointer to a T3RadialShader structure

static void colorComputation_linear( void* info, const float* in, float* out )
{	
	T3ShaderColorParameters* parameters = (T3ShaderColorParameters*)info;

	// TODO : right now the color values here are specific to MouseLapse
	//        should open this open as a linear blending between 2 colors
	//		  that are client specified 
	int	k;
    for ( k = 0; k < parameters->components - 1; k++)
	{
        *(out++) = 0.5 + (*in) * 0.5;
	}
		  
	 *(out++) = parameters->alpha;
}

#pragma mark -

+ (T3RadialShader*)	radialShader
{
	T3RadialShader* newShader	=	[ [ [ T3RadialShader alloc ] init ] autorelease ];
		
	return newShader;
}

+ (T3RadialShader*) sphericalRadialShader
{
	T3RadialShader* newShader	=
		[ [ T3RadialShader alloc ] initWithColorFunction:&colorComputation_linear
								    startPoint:CGPointMake( 0.5, 0.5 )
									startRadius:1.0
									endPoint:CGPointMake( 0.75, 0.75 )
									endRadius:0.0 ];
	
	[ newShader autorelease ];
	
	return newShader;
}

#pragma mark -

- (id) initWithColorFunction:(CGFunctionEvaluateCallback)colorFunction
                    startPoint:(CGPoint)start
				   startRadius:(float)firstRadius
					  endPoint:(CGPoint)end
                     endRadius:(float)secondRadius
{

	self = [ super init ];
	
	if ( self != nil )
	{
		//----- only RGB color space for now, could expose this to clients later

		fColorSpace					=	CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
		fColorParameters.components =	4;
		fColorParameters.alpha		=	1.0;
		// TODO : I thought I would be able to change these parameters that are passed
		//        to the shader caller function. The problem is that the shader seems
		//        to be cached and the color function is not always called again when drawing
		//        and there appears to be no way to invalidate the shading
		//        so...alpha must be controlled elsewhere. This also likely means
		//        there is no simple way to change the color without creating a new shader
		
		fColorFunction		=	[ self createColorFunction:colorFunction ];
		fShader				=	[ self createRadialShader:start
											  startRadius:firstRadius
												 endPoint:end
												endRadius:secondRadius ];
	}
	
	return self;
}

- (id) init
{	
	//----- just some default values that make an interesting fruit
	//      stripe cylinder...straight outta apple's sample code
	
	[ self initWithColorFunction:&colorComputation_sin
			          startPoint:CGPointMake( 0.25, 0.3 ) 
					 startRadius:0.1
			            endPoint:CGPointMake( 0.7, 0.7 )
					   endRadius:0.25 ];
					   
	return self;
}

- (void) dealloc
{
	CGShadingRelease( fShader );
	CGFunctionRelease( fColorFunction );
	CGColorSpaceRelease( fColorSpace );

	[ super dealloc ];
}

- (void) paintShader:(NSGraphicsContext*) context inRect:(NSRect) bounds
{
	CGContextRef coreContext = [ context coreGraphicsContext ];

    float		width		= bounds.size.width;
    float		height		= bounds.size.height;
	float		x			= bounds.origin.x;
	float		y			= bounds.origin.y;

	CGContextSaveGState( coreContext );
 
    CGAffineTransform scaleTransform;
	scaleTransform = CGAffineTransformMakeScale( width, height );

    CGAffineTransform translateTransform;
	translateTransform = CGAffineTransformMakeTranslation( x, y );

	CGContextConcatCTM( coreContext, translateTransform );	
    CGContextConcatCTM( coreContext, scaleTransform );

	CGContextDrawShading( coreContext, fShader );
	
	CGContextRestoreGState( coreContext ); 
}

@end

#pragma mark -
@implementation T3RadialShader (PrivateMethods)

- (CGFunctionRef) createColorFunction:(CGFunctionEvaluateCallback)colorFunction
{
    float input_value_range[ 2 ] = { 0, 1 };
    float output_value_ranges[ 8 ] = { 0, 1, 0, 1, 0, 1, 0, 1 };
    
	CGFunctionCallbacks callbacks = { 0, colorFunction, NULL };
 
    size_t components = CGColorSpaceGetNumberOfComponents( fColorSpace ) + 1;
		// +1 to account for alpha channel
		
    return CGFunctionCreate( (void *) &fColorParameters,
                                1,
                                input_value_range,
                                components,
                                output_value_ranges,
                                &callbacks);
}

- (CGShadingRef) createRadialShader:(CGPoint)start
				        startRadius:(float)firstRadius
					       endPoint:(CGPoint)end
                          endRadius:(float)secondRadius
{
	//----- points are in a scale of 0 to 1.0
	//      where 0 and 1.0 are are mapped to the outer bounds of the rect
	//      the shader is drawn into
    
	return CGShadingCreateRadial
		(
			fColorSpace, 
			start, 
			firstRadius,
			end, 
			secondRadius,
			fColorFunction, 
			false, 
			false
		);
}

@end