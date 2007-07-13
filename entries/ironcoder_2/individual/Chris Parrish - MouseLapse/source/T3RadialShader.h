//
//  T3RadialShader.h
//  IronCoder v2
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef struct
{
	size_t		components;
	float		alpha;
} T3ShaderColorParameters;

@interface T3RadialShader : NSObject
{
	CGColorSpaceRef				fColorSpace;
	CGFunctionRef				fColorFunction;
	CGShadingRef				fShader;
	T3ShaderColorParameters		fColorParameters;
}

+ (T3RadialShader*)	radialShader;

+ (T3RadialShader*) sphericalRadialShader;
	// creates a radial shader setup look like a shaded sphere


- (id) initWithColorFunction:( CGFunctionEvaluateCallback )colorFunction
                    startPoint:(CGPoint)start
				   startRadius:(float)firstRadius
					  endPoint:(CGPoint)end
                     endRadius:(float)secondRadius;

- (void) paintShader:(NSGraphicsContext*) context inRect:(NSRect) bounds;

@end
