#import "CGNightView.h"
inline CGPoint CGPointFromNSPoint(NSPoint point){
	return (CGPoint){point.x,point.y};
}
@implementation CGNightView

- (id)initWithFrame:(NSRect)frameRect
{
	if(![super initWithFrame:frameRect])
		return nil;
	blurMoon = YES;
	return self;
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor blackColor] set];
	NSRectFill(rect);
	NSEnumerator *starEnum = [stars objectEnumerator];
	NSValue *encodedStar;
	int i = 0;
	while(encodedStar = [starEnum nextObject]){
		CGStar toDraw;
		[encodedStar getValue:&toDraw];
		[self drawStar:&toDraw];
		[stars removeObjectAtIndex:i];
		[stars insertObject:[NSValue value:&toDraw withObjCType:@encode(CGStar)] atIndex:i];
		i++;
	}
	BOOL blur = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blurMoon"] boolValue];
	float amount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"blurAmount"] floatValue];
	BOOL colorize = [[[NSUserDefaults standardUserDefaults] objectForKey:@"colorizeMoon"] floatValue];
	if(blur != blurMoon || amount != blurAmount || colorize != colorizeMoon){
		tintedMoon = nil;
		
	}
	[self drawMoonWithGlow:blur tint:(colorize) ? [NSColor blueColor] : [NSColor clearColor] glowAmount:amount];
	blurMoon = blur;
	colorizeMoon = colorize;
	blurAmount = amount;
}
-(void)drawMoonWithGlow:(BOOL)glow tint:(NSColor *)tint glowAmount:(float)a{
	if(!tintedMoon){
		id moon = [NSImage imageNamed:@"moon.jpg"];
		tintedMoon = [CGImageGenerator tintImage:moon withColor:tint];
		if(glow)
			bluredMoon = [CGImageGenerator addGlowToImage:tintedMoon amount:a];
	}
	if(glow)
		[[[NSGraphicsContext currentContext] CIContext] drawImage:bluredMoon inRect:(CGRect){300,500,100,100} fromRect:[bluredMoon extent]];
	else
		[[[NSGraphicsContext currentContext] CIContext] drawImage:tintedMoon inRect:(CGRect){300,500,100,100} fromRect:[tintedMoon extent]];
}
-(void)update{
	[self setNeedsDisplay:YES];
}

-(void)drawStar:(CGStar *)aStar{
	int radius = aStar->radius;
	CIImage *img;
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"colorizeStars"] boolValue] == YES)
		img = [CGImageGenerator starWithRadius:radius color:aStar->color];
	else if(aStar->on)
		img = [CGImageGenerator starWithRadius:radius color:[NSColor whiteColor]];
	else
		img = [CGImageGenerator starWithRadius:radius color:[NSColor colorWithDeviceWhite:0.8 alpha:1.0]];	
	[[[NSGraphicsContext currentContext] CIContext] drawImage:img atPoint:CGPointFromNSPoint(aStar->center) fromRect:(CGRect){-8*radius,-8*radius,16*radius,16*radius}];
	if(aStar->on)
		aStar->color = [[self darken:aStar->color] retain];
	else
		aStar->color = [[self lighten:aStar->color] retain];
	aStar->on = !aStar->on;
	[img release];
}
-(NSColor *)darken:(NSColor *)to{
	float delta = 0.3;
	float red = [to redComponent];
	red -= delta;
	float green = [to greenComponent];
	green -= delta;
	float blue = [to blueComponent];
	blue -= delta;
	return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0];
}
-(NSColor *)lighten:(NSColor *)to{
	float delta = -0.3;
	float red = [to redComponent];
	red -= delta;
	float green = [to greenComponent];
	green -= delta;
	float blue = [to blueComponent];
	blue -= delta;
	return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:1.0];
}
-(void)setStars:(NSArray *)anArray{
	stars = [anArray retain];
}
@end
