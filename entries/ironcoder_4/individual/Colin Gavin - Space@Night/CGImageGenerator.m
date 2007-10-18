#import "CGImageGenerator.h"
#import <QuartzCore/QuartzCore.h>

@implementation CGImageGenerator
+(CIImage *)starWithRadius:(float)radius color:(NSColor *)color{
	CIFilter *star = [[CIFilter filterWithName:@"CIStarShineGenerator"] retain];
	CIColor *cic = [[CIColor alloc] initWithColor:color];
	[star setDefaults];
	[star setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
	[star setValue:[NSNumber numberWithFloat:1] forKey:@"inputCrossWidth"];
	[star setValue:[NSNumber numberWithFloat:5] forKey:@"inputCrossScale"];
	[star setValue:cic forKey:@"inputColor"];
	[star setValue:[CIVector vectorWithX:0 Y:0] forKey:@"inputCenter"];
	return [[star valueForKey:@"outputImage"] retain];
}
+(CIImage *)tintImage:(NSImage *)img withColor:(NSColor *)color{
	CIFilter *mono = [[CIFilter filterWithName:@"CIColorMonochrome"] retain];
	[mono setDefaults];
	[mono setValue:[[CIImage alloc] initWithData:[img TIFFRepresentation]] forKey:@"inputImage"];
	[mono setValue:[[CIColor alloc] initWithColor:color] forKey:@"inputColor"];
	[mono setValue:[NSNumber numberWithFloat:0.5] forKey:@"inputIntensity"];
	return [[mono valueForKey:@"outputImage"] retain];
}
+(CIImage *)addGlowToImage:(CIImage *)img amount:(float)blurAmount{
	CIFilter *glow = [[CIFilter filterWithName:@"CIGaussianBlur"] retain];
	[glow setDefaults];
	[glow setValue:[NSNumber numberWithFloat:blurAmount] forKey:@"inputRadius"];
	[glow setValue:img forKey:@"inputImage"];
	return [[glow valueForKey:@"outputImage"] retain];
}
@end
