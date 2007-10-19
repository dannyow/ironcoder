#import "Basic_LifeView.h"
#import "CTGradient.h"
enum{
	kAdenine,
	kCytosine,
	kGuanine,
	kThymine
};
@implementation Basic_LifeView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    if(![super initWithFrame:frame isPreview:isPreview])
		return nil;
	
	NSFileHandle *bases_handle = [NSFileHandle fileHandleForReadingAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"arm_4_dmel" ofType:@"txt"]];
	bases = [[NSString alloc] initWithData:[bases_handle availableData] encoding:NSISOLatin1StringEncoding];
	//initialize the rendering view
	rendering_view = [[QCView alloc] initWithFrame:(NSRect){0,0,frame.size.width,frame.size.height}];
	[rendering_view loadCompositionFromFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"dna" ofType:@"qtz"]];
	[rendering_view setValue:[self pairFor:kAdenine] forInputKey:@"A"];
	[rendering_view setValue:[self pairFor:kCytosine] forInputKey:@"C"];
	[rendering_view setValue:[self pairFor:kGuanine] forInputKey:@"G"];
	[rendering_view setValue:[self pairFor:kThymine] forInputKey:@"T"];
	//add it
	[self addSubview:rendering_view];
	[rendering_view startRendering];
	//finish the setup
	pairs_showing = frame.size.height / 14;
	[rendering_view setValue:[bases substringWithRange:(NSRange){0,pairs_showing}] forInputKey:@"DNA"];
	current_position = pairs_showing;
	//setup animation duration
	[self setAnimationTimeInterval:0.1];
	return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor colorWithDeviceWhite:0.94 alpha:1.00] set];
	NSRectFill(rect);
	[rendering_view drawRect:rect];
}

- (void)animateOneFrame
{
    [rendering_view setValue:[bases substringWithRange:(NSRange){current_position,current_position + pairs_showing}] forInputKey:@"DNA"];
	current_position += 1;
	if(current_position >= [bases length])
		current_position = 0;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

-(NSImage *)pairFor:(int)base{
	NSImage *pair = [[NSImage alloc] initWithSize:(NSSize){28,14}];
	[pair lockFocus];
	[self drawBase:base atPoint:(NSPoint){0,0}];
	if(base == kAdenine){
		[self drawBase:kThymine atPoint:(NSPoint){14,0}];
	}
	else if(base == kCytosine){
		[self drawBase:kGuanine atPoint:(NSPoint){14,0}];
	}
	else if(base == kGuanine){
		[self drawBase:kCytosine atPoint:(NSPoint){14,0}];
	}
	else if(base == kThymine){
		[self drawBase:kAdenine atPoint:(NSPoint){14,0}];
	}
	[pair unlockFocus];
	return pair;
}
-(void)drawBase:(int)base atPoint:(NSPoint)aPoint{
	NSColor *start;
	NSColor *end;
	if(base == kAdenine){
		start = [NSColor colorWithCalibratedRed:0.21 green:0.60 blue:0.03 alpha:1.0];
	}
	else if(base == kCytosine){
		start = [NSColor colorWithCalibratedRed:0.60 green:0.00 blue:0.10 alpha:1.0];
	}
	else if(base == kGuanine){
		start = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.62 alpha:1.0];
	}
	else if(base == kThymine){
		start = [NSColor colorWithCalibratedRed:0.83 green:0.81 blue:0.30 alpha:1.0];
	}
	end = [NSColor colorWithDeviceRed:[start redComponent] * 0.4 green:[start greenComponent] * 0.4 blue:[start blueComponent] * 0.4 alpha:1.0];
	NSBezierPath *base_path = [NSBezierPath bezierPathWithOvalInRect:(NSRect){aPoint, (NSSize){14,14}}];
	[[CTGradient gradientWithBeginningColor:start endingColor:end] fillBezierPath:base_path angle:90];
}
@end