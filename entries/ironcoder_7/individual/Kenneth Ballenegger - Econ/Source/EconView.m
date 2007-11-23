//
//  EconView.m
//  Econ
//
//  Created by Kenneth Ballenegger on 2007/11/17.
//  Copyright (c) 2007, Azure Talon. All rights reserved.
//

#import "EconView.h"

#define RANDOM_LOADING 60

NSArray *AllApplications(NSArray *searchPaths) {
	NSArray *urls;
	_LSCopyAllApplicationURLs(&urls);
	NSMutableArray *array = [NSMutableArray array];
	for(NSURL *url in urls) {
		for(NSString *searchPath in searchPaths)
		{
			if([[[url path] substringToIndex:[searchPath length]] isEqualToString:searchPath])
				[array addObject:[url path]];
		}
	}
	return array;
	
}


@implementation EconView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/100.0];
		
		[NSThread detachNewThreadSelector:@selector(calculationThread:) toTarget:self withObject:nil];
    }
    return self;
}

- (void)calculationThread:(id)obj
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	int i, j;
	
	NSArray *applications = AllApplications([NSArray arrayWithObject:@"/Applications/"]);
	NSMutableArray *iconsTmp = [[NSMutableArray new] autorelease];
	
	NSMutableArray *randomIds = [[NSMutableArray new] autorelease];
	for(j=0; j<RANDOM_LOADING; j++)
	{
		[randomIds addObject:[NSNumber numberWithInt:SSRandomIntBetween(0,[applications count]-1)]];
	}
	for(i=0; i<[applications count]; i++)
	{
		if(RANDOM_LOADING>0)
		{
			if([randomIds containsObject:[NSNumber numberWithInt:i]])
				[iconsTmp addObject:[[NSWorkspace sharedWorkspace] iconForFile:[applications objectAtIndex:i]]];
		}else
			[iconsTmp addObject:[[NSWorkspace sharedWorkspace] iconForFile:[applications objectAtIndex:i]]];
	}
	icons = [[NSArray arrayWithArray:iconsTmp] retain]; 

	didCalc = YES;
	
	[pool release];
	
}


- (void)startAnimation
{
	[super startAnimation];
}

- (void)stopAnimation
{
	didCalc = NO;
	didStartAnim = NO;
	didDrawLoading = NO;
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
	if(didCalc)
	{
		if(!didStartAnim)
		{
			NSOpenGLPixelFormatAttribute	attributes[] = {
				NSOpenGLPFAFullScreen,
				NSOpenGLPFAScreenMask, CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
				NSOpenGLPFANoRecovery,
				NSOpenGLPFADoubleBuffer,
				NSOpenGLPFAAccelerated,
				NSOpenGLPFADepthSize, 24,
				(NSOpenGLPixelFormatAttribute) 0
			};
			NSOpenGLPixelFormat *format;
			
			format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
			
			glView = [[MyOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
			
			if (!glView)
			{             
				NSLog( @"Couldn't initialize OpenGL view." );
				[self release];
			} 
			
			[self addSubview:glView];
			
			renderer = [[QCRenderer alloc] initWithOpenGLContext:[glView openGLContext] pixelFormat:format file:[[NSBundle bundleForClass:[self class]] pathForResource:@"prolif" ofType:@"qtz"]];
			
			int i;
			NSImage *resizedIcon;
			for(i=0;i<=59;i++)
			{
				//if(SSRandomIntBetween(0,1))
				//{
					resizedIcon = [[icons objectAtIndex:SSRandomIntBetween(0,([icons count]-1))] copy];
					[resizedIcon setSize:NSMakeSize(512, 512)];
				//}
				//else
				//	resizedIcon = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:@"alpha0.png"]] autorelease];
				[renderer setValue:[resizedIcon TIFFRepresentation] forInputKey:[NSString stringWithFormat:@"Source_%d", i]];
			}
			
			
			[glView setFrameSize:[self frame].size];
			
			didStartAnim = YES;
		}
		
		NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
		NSPoint mouseLocation;
		
		//Let's compute our local time
		if(startTime == 0) {
			startTime = time;
			time = 0;
		}
		else
			time -= startTime;
		
		
		mouseLocation.x = 0;
		mouseLocation.y = 0;
		NSDictionary *arguments = [NSDictionary dictionaryWithObject:[NSValue valueWithPoint:mouseLocation] forKey:QCRendererMouseLocationKey];
		
		//Render a frame
		if(![renderer renderAtTime:time arguments:arguments])
			NSLog(@"Rendering failed at time %.3fs", time);
		
		[[glView openGLContext] flushBuffer];
	}
	else
	{
		if(!didDrawLoading)
		{
			[[NSColor blackColor] set];
			NSRectFill([self bounds]);
			
			NSImage *sample = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:@"loading.png"]] autorelease];
			NSPoint point;
			point.x = ([self bounds].size.width-[sample size].width)/2;
			point.y = ([self bounds].size.height-[sample size].height)/2;
			[sample compositeToPoint:point operation:NSCompositeSourceOver fraction:1.0];
			
			didDrawLoading = YES;
		}
	}
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
