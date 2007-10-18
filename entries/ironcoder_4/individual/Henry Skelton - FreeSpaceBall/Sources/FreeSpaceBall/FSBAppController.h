//
//  FSBAppController.h
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 Henry Skelton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSBMemoryMonitor.h"
#import "globals.h"


/*!
	@class			FSBAppController
	@abstract		This is the main controller the application.
	@discussion		This facilitates the operation of the application and the interaction of the objects.
*/
@interface FSBAppController : NSObject {
	FSBMemoryMonitor* memoryMonitor;
}

- (id)init;

- (double)totalMemory;

- (double)usedMemory;

+ (id)theController;

- (double)lastChange;

@end
