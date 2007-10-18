//
//  FSBMemoryMonitor.h
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
	@class			FSBMemoryMonitor
	@abstract		This object monitors the memory usage in Mac OS X.
	@discussion		This object utilizes top to monitor memory usage.
*/
@interface FSBMemoryMonitor : NSObject {
	NSTask* top;
	NSPipe* outputPipe;
	NSFileHandle* topOutput;
	double usedMemory;
	double freeMemory;
	double totalMemory;
	double percentUsedMemory;
	double oldPercentUsedMemory;
	double lastChange;
}

- (id)init;

- (void)beginMonitoringMemory;

- (double)totalMemory;

- (double)usedMemory;

- (double)lastChange;

@end

typedef struct{
	double value;
	char unit;
} FSBStorageSize;

double covertToUnit(FSBStorageSize size, char unit);