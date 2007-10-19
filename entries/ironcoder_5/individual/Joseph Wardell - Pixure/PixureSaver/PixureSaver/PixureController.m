//
//  PixureController.m
//  PixureSaver
//
//  Created by Joseph Wardell on 4/1/07.
//  Copyright 2007 Old Jewel Software. All rights reserved.
//

#import "PixureController.h"
#import "PixureSystem.h"
#import "NSImage (ThumbnailCreation).h"
#import "OJW_PixureSaverDefaults.h"
#import "ImageFileThumbnailCache.h"


@implementation PixureController


#pragma mark -
#pragma mark Private Accessors

- (BOOL)isEvolving;
{
	return evolving;
}

- (void)setIsEvolving:(BOOL)inEvolving;
{
	if ([self isEvolving] == inEvolving)
		return;

	evolving = inEvolving;
}

#pragma mark -
#pragma mark Accessors

- (unsigned int)maxImageSize;
{
//#warning remove for real code not in objectalloc
// for purposes of not making objectalloc take years...
//	return 233;

	return 987;
}

- (NSString *)sourcePath;
{ 
	return [[sourcePath copy] autorelease]; 
}


- (void)setSourcePath:(NSString *)inSourcePath;
{
	if ([[self sourcePath] isEqualTo:inSourcePath])
		return;

	[inSourcePath retain];
	[sourcePath release];
	sourcePath = inSourcePath;

	[[self system] setImage:[NSImage thumbnalImageForIconAtPath:[self sourcePath] withSize:[self maxImageSize]]];
}


- (NSImage*)imageToShow;
{
	return [[self system] generatedImage];
}




- (NSArray*)picturePathsContainers
{
	return [NSArray arrayWithObjects:@"/Library/Desktop Pictures/Plants/",
			@"/Library/Desktop Pictures/Nature/",
			@"/System/Library/Screen Savers/Forest.slideSaver/Contents/Resources/",
			@"/System/Library/Screen Savers/Nature Patterns.slideSaver/Contents/Resources/",
			@"/System/Library/Screen%20Savers/Nature%20Patterns.slideSaver/Contents/Resources/",
			nil];
}

- (NSArray*)picturePathsFromFolderAtPath:(NSString*)inFolderPath
{
	NSArray* folderContents = [[NSFileManager defaultManager] directoryContentsAtPath:inFolderPath];
	
	NSMutableArray* outArray = [NSMutableArray array];

	NSEnumerator *enumerator = [folderContents objectEnumerator];
	NSString*thisPath;

	while ((thisPath = [enumerator nextObject]) != nil) 
	{
		if ([[NSImage imageFileTypes] containsObject:[thisPath pathExtension]])
			[outArray addObject:[inFolderPath stringByAppendingString:thisPath]];
	}
	
	return outArray;
}

- (NSArray*)picturePaths;
{
	if (nil != picturePaths)
		return picturePaths;

	NSEnumerator *enumerator = [[self picturePathsContainers] objectEnumerator];
	NSString*  thisFolderPath;

	NSArray* outArray = [NSArray array];

	while ((thisFolderPath = [enumerator nextObject]) != nil) 
	{
		outArray = [outArray arrayByAddingObjectsFromArray:[self picturePathsFromFolderAtPath:thisFolderPath]];
	}


	picturePaths = [outArray retain];
	
	return outArray;
}


- (unsigned int)pictureIndex;
{
	return pictureIndex;
}

- (void)setPictureIndex:(unsigned int)inPictureIndex;
{
	if ([self pictureIndex] == inPictureIndex)
		return;

	pictureIndex = inPictureIndex;

	if (pictureIndex >= [[self picturePaths] count])
		pictureIndex = 0;
}



- (NSString*)pathToSourceFile;
{
	return [[self picturePaths] objectAtIndex:[self pictureIndex]];
}



- (NSTimeInterval)timeBetweenRotations
{
//	return 30;
	return [[OJW_PixureSaverDefaults defaults] integerForKey:@"minutesBetweenRotateImage"] * 60;
}

- (NSImage*)thumbnailForPath:(NSString*)inPath;
{
	if (nil == thumbnails)
		thumbnails = [[ImageFileThumbnailCache alloc] init];

	NSImage* outImage = [thumbnails thumbnailForPath:inPath];
	if (nil != outImage)
		return outImage;
	return nil;
}


#pragma mark -
#pragma mark rotating images

- (void)rotateImage;
{
	[[PixureController PixureController] stopEvolving];
	[[PixureController PixureController] setPictureIndex:random() % [[[PixureController PixureController] picturePaths] count]];
	[[PixureController PixureController] setSourcePath:[self pathToSourceFile]];
	[[PixureController PixureController] startEvolving];

	[self performSelector:@selector(rotateImage) withObject:nil afterDelay:[self timeBetweenRotations]];
}


- (void)startAnimation;
{
	[[PixureController PixureController] rotateImage];
}

- (void)stopAnimation;
{
	[[PixureController PixureController] stopEvolving];
	
	[picturePaths release];
	picturePaths = nil;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark -
#pragma mark Actions


- (void)startEvolving;
{
	if ([self isEvolving])
	{	
		return; // if there's more than one monitor, then there's more than one view, but I only want one  
	}
	[self setIsEvolving:YES];
	
	[evolutionLock lock];
	[NSThread detachNewThreadSelector:@selector(evolveInThread:) toTarget:self withObject:nil];
}

- (void)stopEvolving;
{
	if (![self isEvolving])
		return;

	[self setIsEvolving:NO];
	[evolutionLock unlock];
}


#pragma mark -
#pragma mark Pixure

- (void)advanceAGeneration;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];	
	[[self system] advanceOneGeneration];
	[pool release];
}

- (void)evolveInThread:(id)unused;
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	// seed random here to allow for random color production
	srandom(floor([NSDate timeIntervalSinceReferenceDate]));
			
	while ([self isEvolving])
	{
		[self advanceAGeneration];
	}
	
	
	[pool release];
}


- (PixureSystem*)system;
{
	if (nil == system)
		system = [[PixureSystem alloc] initWithImage:nil];

	return system;
}


#pragma mark -
#pragma mark defaults



+ (void)setupDefaults;
{
	NSMutableDictionary* def = [NSMutableDictionary dictionary];
	
	// delay 5 minutes between images
	[def setObject:[NSNumber numberWithFloat:5.0] forKey:@"minutesBetweenRotateImage"];
	
	// use a random grayscale pixure on populate
	[def setObject:[NSNumber numberWithInt:0] forKey:@"startingPixureType"];

	// show file name and a smal thumbnail in the bottom left corner
	[def setObject:[NSNumber numberWithBool:YES] forKey:@"drawPictureName"];
	[def setObject:[NSNumber numberWithBool:YES] forKey:@"drawThumbnail"];

	// use installed files by default
	[def setObject:[NSNumber numberWithBool:NO] forKey:@"userSelectedFolder"];
	
	// but if using other, then default to Pictures folder
	// should generalize this
	[def setObject:[@"~/Pictures/" stringByStandardizingPath] forKey:@"userPictureFolderPath"];
	
	// mutation rate of 0.5 (how often pixures mutate)
	[def setObject:[NSNumber numberWithFloat:0.5] forKey:@"mutationRate"];
	
	// mutation rate of 0.25 (how much of a change happens in a mutation)
	[def setObject:[NSNumber numberWithFloat:0.25] forKey:@"mutationIntensity"];
	
	[[OJW_PixureSaverDefaults defaults] registerDefaults:def];	
	
	[[OJW_PixureSaverDefaults defaults] synchronize];
}

+ (void)initialize;
{
	// seed random here to allow for random image file selection
	srandom(floor([NSDate timeIntervalSinceReferenceDate]));
	
	[self setupDefaults];
}


#pragma mark -
#pragma mark May want to change
- (void)finishInit;
{
	// do all the specific init here so it's called at the right time
}

- (void)finishDealloc;
{
	// do all the specific dealloc here so it's called at the right time
	[system release];
	[sourcePath release];
	[evolutionLock release];
	[picturePaths release];
	[thumbnails release];
}

- (void)finishAppQuit;
{
	// do all the specific app termination code here so it's called at the right time
}








#pragma mark -
#pragma mark Initialization

- (id) init {

    static PixureController *sharedInstance = nil;

    if (sharedInstance) {
        [self autorelease];
        self = [sharedInstance retain];
    } else {
        self = [super init];
        if (self) 
		{
            sharedInstance = [self retain];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillQuit:) name:NSApplicationWillTerminateNotification object:NSApp];
			[self finishInit];
		}
    }

    return self;
}

- (void)dealloc
{
	[self finishDealloc];
	[super dealloc];
}

+ (PixureController*)PixureController;
{
	static PixureController * sharedInstance = nil;

	if ( sharedInstance == nil )
	        sharedInstance = [[self alloc] init];

	return sharedInstance;
}

- (void)appWillQuit:(NSNotification*)unused
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self finishAppQuit];
}



@end