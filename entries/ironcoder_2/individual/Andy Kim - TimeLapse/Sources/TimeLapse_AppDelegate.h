//
//  TimeLapse_AppDelegate.h
//  TimeLapse
//
//  Created by Andy Kim on 7/22/06.
//  Copyright Potion Factory 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TLBrowserView;
@class TLCGImageView;

@interface TimeLapse_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;

	IBOutlet NSWindow *oZoomWindow;
	IBOutlet TLCGImageView *oImageView;

	IBOutlet NSArrayController *oScreenshotsController;
	IBOutlet TLBrowserView *oBrowserView;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSArrayController*)screenshotsController;

- (IBAction)zoomMin:(id)sender;
- (IBAction)zoomMax:(id)sender;
	
- (void)openZoomWindowWithImage:(CGImageRef)image;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
