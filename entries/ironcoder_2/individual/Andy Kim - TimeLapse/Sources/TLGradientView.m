//
//  TLGradientView.m
//  TimeLapse
//
//  Created by Andy Kim on 7/23/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import "TLGradientView.h"
#import "TLDefines.h"

@implementation TLGradientView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


float start_red, start_green, start_blue;
float end_red, end_green, end_blue;
float d_red, d_green, d_blue;


static void evaluate(void *info, const float *in, float *out)
{
	// red
	*out++ = start_red + *in * d_red;

	// green
	*out++ = start_green + *in * d_green;

	// blue
	*out++ = start_blue + *in * d_blue;

	//alpha
    *out++ = 1;
}

- (void)drawRect:(NSRect)rect
{
	// Draw a vertical gradient down the entire view
	
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSaveGState(ctx);

	NSRect bounds = [self bounds];
	
	// set up colors for gradient
	start_red = start_green	= start_blue = 0.79;
	end_red = end_green = end_blue = 0.69;

	d_red		= fabs(end_red - start_red);
	d_green		= fabs(end_green - start_green);
	d_blue		= fabs(end_blue - start_blue);

	// draw gradient
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

    size_t components;
    static const float domain[2] = { 0.0, 1.0 };
    static const float range[10] = { 0, 1, 0, 1, 0, 1, 0, 1, 0, 1 };
    static const CGFunctionCallbacks callbacks = { 0, &evaluate, NULL };

    components = 1 + CGColorSpaceGetNumberOfComponents(colorspace);
    CGFunctionRef function =  CGFunctionCreate((void *)components, 1, domain, components, range, &callbacks);

	static CGPoint startPoint = { 0, 0 };
	static CGPoint endPoint = { 0, 0 };
	
	endPoint.x = 0;
	endPoint.y = NSHeight(bounds);
	
	CGShadingRef shading = CGShadingCreateAxial(colorspace, startPoint, endPoint, function, NO, NO);

	CGContextDrawShading(ctx, shading);

	CGFunctionRelease(function);
	CGShadingRelease(shading);
	CGColorSpaceRelease(colorspace);

	CGContextRestoreGState(ctx);
}

@end
