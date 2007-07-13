//
//  TimeLapse_AppDelegate.m
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright Potion Factory 2006 . All rights reserved.
//

#import "TimeLapse_AppDelegate.h"
#import "TLScreenshotGrabber.h"
#import "TLBrowserView.h"
#import "TLCGImageView.h"

@implementation TimeLapse_AppDelegate

+ (void)initialize
{
	// Make 7 seconds the default interval between screenshots
	NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
	[[defaultsController defaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
																	   [NSNumber numberWithInt:7], @"TLScreenshotInterval",
																  nil]];
}

- (void)awakeFromNib
{
	NSSortDescriptor *dateSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease];
	[oScreenshotsController setSortDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];

	// We register ourself to observe the array controller's arrangedObjects because
	// Core Data takes some time to load and we need to draw when it's done
	[oScreenshotsController addObserver:self
							 forKeyPath:@"arrangedObjects" 
								options:nil
								context:NULL];

	[window makeFirstResponder:oBrowserView];
}

- (NSArrayController*)screenshotsController
{
	return oScreenshotsController;
}


- (void)recordScreenshot:(NSTimer*)timer
{
	// Grabs a screenshot and saves it to Core Data
	NSData *imageData = [[TLScreenshotGrabber grabber] screenshotImageData];

	NSManagedObject *newSS = [NSEntityDescription insertNewObjectForEntityForName:@"Screenshot" inManagedObjectContext:[self managedObjectContext]];

	[newSS setValue:[NSDate date] forKey:@"date"];
	[newSS setValue:imageData forKey:@"imageData"];

	[self saveAction:self];

	[newSS release];

	// Start taking screenshots
	float interval = [[[[NSUserDefaultsController sharedUserDefaultsController] defaults] objectForKey:@"TLScreenshotInterval"] floatValue];

	NSAssert(interval > 0, @"Screenshot interval must be greater than 0");
	[NSTimer scheduledTimerWithTimeInterval:interval
									 target:self
								   selector:@selector(recordScreenshot:)
								   userInfo:nil
									repeats:NO];
}

// Open a separate window with the image
- (void)openZoomWindowWithImage:(CGImageRef)image
{
	[oImageView setCGImage:image];
	NSRect frame = [oZoomWindow frame];
	
	frame.size.width = CGImageGetWidth(image);
	frame.size.height = CGImageGetHeight(image);
	
	[oZoomWindow setFrame:frame display:YES];
	[oZoomWindow makeKeyAndOrderFront:self];
}

#pragma mark IBActions
- (IBAction)zoomMin:(id)sender
{
	[oBrowserView setZoomFactor:MIN_ZOOM_FACTOR];
}

- (IBAction)zoomMax:(id)sender
{
	[oBrowserView setZoomFactor:MAX_ZOOM_FACTOR];
}


#pragma mark Notifications
- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
	// Warn if the user's display color mode isn't set to 32 bits. Our screenshot code can only handle 32 bit displays
	if (CGDisplayBitsPerPixel(kCGDirectMainDisplay) != 32)
	{
		NSRunAlertPanel(@"TimeLapse requires that your display be set to the 32 bit color mode.",
						@"Please change the display mode and come back.",
						@"Quit", nil, nil, nil);
		exit(0);
	}
	
	// Start recording screenshots right away
	[self recordScreenshot:nil];

	[oBrowserView setNeedsDisplay:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object 
                        change:(NSDictionary *)change
                       context:(void *)context
{
	// Redraw our browser when the screenshots array controller changes
    if (object == oScreenshotsController && [keyPath isEqual:@"arrangedObjects"]) {
		[oBrowserView recalculateBounds];
		[oBrowserView setNeedsDisplay:YES];
    }
}


#pragma mark Predefined Core Data Stuff

/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "TimeLapse" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"TimeLapse"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle and all of the 
    framework bundles.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    NSMutableSet *allBundles = [[NSMutableSet alloc] init];
    [allBundles addObject: [NSBundle mainBundle]];
    [allBundles addObjectsFromArray: [NSBundle allFrameworks]];
    
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles: [allBundles allObjects]] retain];
    [allBundles release];
    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"TimeLapse.dat"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction)saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}


@end
