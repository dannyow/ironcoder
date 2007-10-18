//
//  FSBAppController.m
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 Henry Skelton. All rights reserved.
//

#import "FSBAppController.h"

FSBAppController* theController;

@implementation FSBAppController

- (id)init
{
	if ((self = [super init]) == nil) return nil;
	memoryMonitor = [[FSBMemoryMonitor alloc] init];
	[memoryMonitor beginMonitoringMemory];
	theController = self;
	return self;
}

+ (id)theController
{
	return theController;
}

- (double)totalMemory
{
	return [memoryMonitor totalMemory];
}

- (double)usedMemory
{
	return [memoryMonitor usedMemory];
}

- (double)lastChange
{
	return [memoryMonitor lastChange];
}


@end
