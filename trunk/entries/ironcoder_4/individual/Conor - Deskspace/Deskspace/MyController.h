//
//  MyController.h
//  Deskspace
//
//  Created by Conor on 28/10/06


#import <Cocoa/Cocoa.h>

@class MyFile;

@interface MyController : NSObject {
	
	NSWindow *fullScreenWindow;
	NSString *currentPath, *applicationToLaunch;  //The current directory path, poosible app to launch on quit
	NSMutableDictionary *fileLocations;  //Contains arrays of two points describing the location of a draged file

}


- (NSString *)currentPath;
- (void)setCurrentPath:(NSString *)aPath;
- (NSArray *)currentPathFiles;  //Return an array of MyFile types with all the files in the directory

- (void)saveLocationForFile:(MyFile *)aFile; //Store a location in the fileLocations Dictionary for a file
- (void)setAppToLaunch:(NSString *)anApp; 


@end
