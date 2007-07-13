//
//  CFallingSandWindowController.m
//  FallingSand
//
//  Created by Jonathan Wight on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CFallingSandWindowController.h"

#import "CSandbox.h"
#import "QTMovie_Extensions.h"
#import "CFallingSandView.h"
#import "CSandboxRenderer.h"
#import "NSImage_Extensions.h"

static CFallingSandWindowController *gInstance = NULL;

@implementation CFallingSandWindowController

+ (CFallingSandWindowController *)instance
{
if (gInstance == NULL)
	{
	gInstance = [[CFallingSandWindowController alloc] init];
	}
return(gInstance);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"Hourglass_Demo" ofType:@"tiff"];
	
	[[self sandbox] loadFromImageAtUrl:[NSURL fileURLWithPath:thePath]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:NULL];
	}
return(self);
}

- (void)dealloc
{
[sandbox autorelease];
sandbox = NULL;
//
[renderer autorelease];
renderer = NULL;

[movie autorelease];
movie = NULL;

//
[super dealloc];
}

- (NSString *)windowNibName
{
return(@"FallingSandWindow");
}

- (void)windowDidLoad
{
[outletSandboxView setSandbox:[self sandbox]];
[[self renderer] setSandbox:[self sandbox]];

[NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0 target:self selector:@selector(tick:) userInfo:NULL repeats:YES]; // TODO Leak!
}

#pragma mark -

- (CSandbox *)sandbox
{
if (sandbox == NULL)
	{
	sandbox = [[CSandbox alloc] init];
	}
return(sandbox);
}

- (CSandboxRenderer *)renderer
{
if (renderer == NULL)
	{
	renderer = [[CSandboxRenderer alloc] init];
	}
return(renderer);
}

- (NSArray *)particleTemplates
{
NSMutableArray *theArray = [NSMutableArray array];

for (int N = 0; N != ParticleType_LENGTH; ++N)
	{
	NSDictionary *theDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
		[[self sandbox] particleTemplates][N].name, @"title",
		[NSNumber numberWithInt:N], @"index",
		NULL];
	[theArray addObject:theDictionary];
	}
return(theArray);
}

- (int)currentParticle
{
return([outletSandboxView currentParticle]);
}

- (void)setCurrentParticle:(int)inCurrentParticle
{
[outletSandboxView setCurrentParticle:inCurrentParticle];
}

- (float)penRadius
{
return([outletSandboxView penRadius]);
}

- (void)setPenRadius:(float)inPenRadius
{
[outletSandboxView setPenRadius:inPenRadius];
}

- (QTMovie *)movie
{
if (movie == NULL)
	{
	movie = [[QTMovie movieWithTempWritableMovie] retain];
	}
return(movie);
}

#pragma mark -

- (void)applicationWillTerminate:(NSNotification *)inNotification
{
#pragma unused (inNotification)
if (movie != NULL)
	{
	NSSavePanel *theSavePanel = [NSSavePanel savePanel];
	[theSavePanel setRequiredFileType:@"mov"];
	if ([theSavePanel runModal] == NSOKButton)
		{
		[[self movie] writeFlattenedToFile:[theSavePanel filename]];		
		}
	}
}

- (void)tick:(id)inParameter
{
#pragma unused (inParameter)

[[self sandbox] update];
[[self renderer] render];
[outletSandboxView setImage:[renderer image]];

if (writeMovie)
	{
	[[self movie] addMP4Image:[NSImage imageFromCGImageRef:[renderer image]]];
	}
}

#pragma mark -

- (IBAction)actionSaveScreen:(id)inSender
{
#pragma unused (inSender)

NSSavePanel *theSavePanel = [NSSavePanel savePanel];
[theSavePanel setRequiredFileType:@"png"];
if ([theSavePanel runModal] == NSOKButton)
	{
	CGImageDestinationRef theImageDestination = CGImageDestinationCreateWithURL((CFURLRef)[theSavePanel URL], (CFStringRef)@"public.png", 1, 0L);
	CGImageDestinationAddImage(theImageDestination, [[self renderer] image], 0L);
	CGImageDestinationFinalize(theImageDestination);
	CFRelease(theImageDestination);
	}
}

- (IBAction)actionLoadScreen:(id)inSender
{
#pragma unused (inSender)

NSOpenPanel *theOpenPanel = [NSOpenPanel openPanel]; 
if ([theOpenPanel runModal] == NSOKButton)
	{
	[sandbox loadFromImageAtUrl:[theOpenPanel URL]]; 
	}
}

@end
