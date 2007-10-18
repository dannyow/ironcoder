//
//  MyController.m
//  Deskspace
//
//  Created by Conor on 28/10/06

#import "MyController.h"
#import "MyFullScreenWindow.h"
#import "MyDeskView.h"
#import "MyFile.h"


//Space for the header
#define HEADER_RATIO 16



@interface MyController (Private)
- (void)initializeProperties:(NSMutableArray *)aFilesArray;  //Initalizes all the icon attributes, location, fatness, oldness
@end


@implementation MyController


- (id) init {
	self = [super init];
	if (self != nil) {
		
		//Laast path used otherwise the Desktop
		currentPath = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LastPath"] retain];
		if (currentPath == nil)
			currentPath = [[@"~/Desktop" stringByExpandingTildeInPath] retain];
		
		//Load the file Locations
		fileLocations = [[NSKeyedUnarchiver unarchiveObjectWithFile:[@"~/Library/Application Support/Deskspace/fileLocations" stringByExpandingTildeInPath]] retain];
		if (fileLocations == nil)
			fileLocations = [[NSMutableDictionary alloc] init] ;

	}
	return self;
}


- (void) dealloc {
	[currentPath release];
	[fileLocations release];
	[super dealloc];
}


/* Create MyFile objects for all the files in a given directory 
   Does so by enumerating through the directory  */
- (NSArray *)currentPathFiles {
	
	NSMutableArray *filesArray = [NSMutableArray array];
	NSFileManager *manager = [NSFileManager defaultManager];
	NSEnumerator *fileEnum = [[manager directoryContentsAtPath:currentPath] objectEnumerator];
	NSString *nextFile;
	
	while (nextFile = [fileEnum nextObject]) {
		if (![nextFile hasPrefix:@"."]) {  //Don't include files that start with .
			
			//If we are at root, remove the root slash otherwise we get //Users, works fine but looks ugly
			NSString *prefixFileWith = [[currentPath copy] autorelease];
			if ([prefixFileWith isEqualToString:@"/"])
				prefixFileWith = @"";
			
			NSString *absoluteFilePath = [NSString stringWithFormat:@"%@/%@", prefixFileWith, nextFile];
			MyFile *newFile = [[MyFile alloc] initWithPath:absoluteFilePath];
			[filesArray addObject:newFile];
		}
	}
	
	//Initalize all the file properties relative to each other
	[self initializeProperties:filesArray];
	
	return filesArray;
}



- (void)initializeProperties:(NSMutableArray *)aFilesArray {
		
	NSRect windowFrame = [[NSScreen mainScreen] frame];
	int numberOfFiles = [aFilesArray count];
	//HEADER_RATIO times six as the header ratio is really the size of the text in the header
	float spaceForFiles = (windowFrame.size.width * (windowFrame.size.height - (windowFrame.size.height/HEADER_RATIO * 6)));
	float spaceForEachFile = spaceForFiles / numberOfFiles;
	spaceForEachFile = sqrt(spaceForEachFile);
	
	//Limit largets file to 300 pixels so that folders with only two or three files don't look too big
	if (spaceForEachFile > 300)
		spaceForEachFile = 300.0;
	
	
	float largestDrawingSize = spaceForEachFile * 0.9;  //Leave a .1 margin between files
	float marginLeft = spaceForEachFile * 0.1; //add the margin to the left side

	
	
	int i, numberOfColumns = windowFrame.size.width / spaceForEachFile;
	//Will get populated with files that will be made to bulge depending on size
	NSMutableArray *filesAndNotDirectories = [NSMutableArray array];
	MyFile *nextFile;
	
	NSArray *possibleOrigin;
	NSRect drawingRect;
	drawingRect.size.width = largestDrawingSize;
	drawingRect.size.height = largestDrawingSize;
	
	
	// Go through all the elements and tile the icons depending on the column it should be in
	// Icons that have been moved by the user get the previous position from possibleOrigin array
	for (i =0; i < numberOfFiles; i++) {
		
		nextFile = [aFilesArray objectAtIndex:i];

		// Set a location to draw the icon on screen
		// Remember the location of Icons that have been dragged
		if ((possibleOrigin = [fileLocations objectForKey:[nextFile absolutePath]])) {
			drawingRect.origin.x = [[possibleOrigin objectAtIndex:0] floatValue];
			drawingRect.origin.y = [[possibleOrigin objectAtIndex:1] floatValue];	
		}
		else {
			int x = i % numberOfColumns;
			int y = i / numberOfColumns;
			drawingRect.origin.x = (spaceForEachFile * x) + marginLeft;
			drawingRect.origin.y = (spaceForEachFile * y) + marginLeft;
		}
		
		//Store drawing Rect
		[nextFile setDrawingRect:drawingRect];
		
		
		//If it's a file place into the array for size calculation
		if (![nextFile isDirectory])
			[filesAndNotDirectories addObject:nextFile];
	}
	

	
	// Bulge and make skinny depending on the file size
	// Excludes directories for speed reasons
	[filesAndNotDirectories sortUsingSelector:@selector(fileSizeCompare:)];
	int filesNotDirectoryCount = [filesAndNotDirectories count];
	float bulgeFrom = 2.0 / filesNotDirectoryCount;  //Bulge can be from -1 to 1
	for (i =0; i < filesNotDirectoryCount; i++) {
		[[filesAndNotDirectories objectAtIndex:i] setBulge:(2 - bulgeFrom * i)];
	}


	//Set the sepia tone of the files depending on when they were last modfied
	[aFilesArray sortUsingSelector:@selector(modDateCompare:)];
	float intensity = 1.0 / numberOfFiles;  //Sepia tone can go from 0 to 1
	for (i =0; i < numberOfFiles; i++) {
		[[aFilesArray objectAtIndex:i] setVintage:1 - (intensity *i)];
	}
	
}

#pragma mark setters and getters


- (NSString *)currentPath {
	return currentPath;
}


- (void)setCurrentPath:(NSString *)aPath {
	[currentPath release];
	currentPath = [aPath retain];
}


- (void)saveLocationForFile:(MyFile *)aFile {
	
	NSPoint location = [aFile location];
	[fileLocations setObject:[NSArray arrayWithObjects:[NSNumber numberWithFloat:location.x], [NSNumber numberWithFloat:location.y], nil] forKey:[aFile absolutePath]];
	
}


- (void)setAppToLaunch:(NSString *)anApp {
	applicationToLaunch = [anApp retain];
}



#pragma mark Application Delegate

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
	

	//Create the window and the drawing content for the fullscreen
	fullScreenWindow = [[MyFullScreenWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame] styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	
	[fullScreenWindow setLevel: NSNormalWindowLevel];
	[fullScreenWindow setBackgroundColor: [NSColor blackColor]];
	[fullScreenWindow setAlphaValue:1.00];
	[fullScreenWindow setOpaque:YES];
	[fullScreenWindow setHasShadow:NO];
	MyDeskView *deskView = [[[MyDeskView alloc] initWithFrame:[[fullScreenWindow contentView] bounds]] autorelease];
	[fullScreenWindow setContentView:deskView];
	
	
	
	//Enter fullscreen mode hiding the dock and menu bar
	if (CGDisplayCapture( kCGDirectMainDisplay ) != kCGErrorSuccess) {
		NSLog( @"Couldn't capture the main display!" );
	}
	// Get the shielding window level
	[fullScreenWindow setLevel:CGShieldingWindowLevel()];
	

	[fullScreenWindow makeKeyAndOrderFront:self];
	
}

- (void)applicationWillTerminate:(NSNotification*)notification  {
	
	//Save the working directory
	[[NSUserDefaults standardUserDefaults] setObject:currentPath forKey:@"LastPath"];
	
	//Save file locations for moved files in Application Support
	NSString *applicationSupport = [@"~/Library/Application Support/Deskspace" stringByExpandingTildeInPath];
	if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupport])
		[[NSFileManager defaultManager] createDirectoryAtPath:applicationSupport attributes:nil];
	
	[NSKeyedArchiver archiveRootObject:fileLocations toFile:[NSString stringWithFormat:@"%@/fileLocations", applicationSupport]];

	
	//Exist fullscreen
	[fullScreenWindow orderOut:self];
	[fullScreenWindow release];
	
	if (CGDisplayRelease( kCGDirectMainDisplay ) != kCGErrorSuccess) {
		NSLog( @"Couldn't release the display(s)!" );
	}
	
	
	//bring the launched app forward right before quiting
	if (applicationToLaunch != nil) {
		[[NSWorkspace  sharedWorkspace] launchApplication:applicationToLaunch];
		[applicationToLaunch release];
	}
	
}

@end
