//
//  FSBMemoryMonitor.m
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FSBMemoryMonitor.h"


@implementation FSBMemoryMonitor

- (id)init
{
	if ((self = [super init]) == nil) return nil;
	return self;
}

- (void)beginMonitoringMemory
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	
	top = [[NSTask alloc] init];
	
   // [defaultCenter addObserver:self selector:@selector(taskCompleted:) name:NSTaskDidTerminateNotification object:top];
    [top setLaunchPath:@"/usr/bin/top"];
    outputPipe = [NSPipe pipe];
    topOutput = [outputPipe fileHandleForReading];
    [defaultCenter addObserver:self selector:@selector(taskDataAvailable:) name:NSFileHandleReadCompletionNotification object:topOutput];
	
	[top setArguments:[NSArray arrayWithObjects:@"-l0",@"0",nil]];
    [top setStandardOutput:outputPipe];
    [top setStandardError:outputPipe];
    
    [top launch];
    [topOutput readInBackgroundAndNotify];
    
}

- (void)taskDataAvailable:(NSNotification *)notification
{
	//[NSThread detachNewThreadSelector:@selector(processTopData:) toTarget:self withObject:notification];
	//[topOutput readInBackgroundAndNotify];
	//return;
	
	//NSLog(@"Task Data available");
	//NSLog(@"Beginning Memory Evaluation");     
	NSData *incomingData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (incomingData && [incomingData length])
    {
		NSString* dataAsString = [[NSString alloc] initWithData:incomingData encoding:NSASCIIStringEncoding];
		NSArray* dataAsLines = [dataAsString  componentsSeparatedByString:@"\n"];
		NSString* memoryInformation;
		
		
		NSEnumerator* dataEnumerator = [dataAsLines objectEnumerator];
		NSString* currentLine;
		while ((currentLine = [dataEnumerator nextObject]))
		{
			if ([currentLine length] > 7)
			{
				NSString* beginningOfData = [currentLine substringToIndex:7];
				if ([beginningOfData isEqualTo:@"PhysMem"])
				{
					memoryInformation = currentLine;
					break;
				}
			}
		}
		if (!memoryInformation)
		{
			NSLog(@"Insufficient data from top"); 
			[topOutput readInBackgroundAndNotify];
			return;
		}
		FSBStorageSize wired, active, inactive, free;
		
		sscanf([memoryInformation UTF8String], "%*s %lf%c %*s %lf%c %*s %lf%c %*s %*lf%*c %*s %lf%c %*s ", &wired.value, &wired.unit, &active.value, &active.unit, &inactive.value, &inactive.unit, &free.value, &free.unit);
		
		usedMemory = covertToUnit(wired, 'M') + covertToUnit(active, 'M');
		freeMemory = covertToUnit(inactive, 'M') + covertToUnit(free, 'M');
		
		if (!totalMemory) totalMemory = usedMemory + freeMemory;
		
		oldPercentUsedMemory = percentUsedMemory;
		percentUsedMemory = ((usedMemory/totalMemory)*100);
		
		lastChange = percentUsedMemory - oldPercentUsedMemory;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MemoryUsageChanged" object:[NSNumber numberWithDouble:lastChange]];
		[topOutput readInBackgroundAndNotify];
        return;
    }
	
}


- (void)processTopData:(NSNotification *)notification
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	
	NSLog(@"Task Data available");
	//sleep(5);
	NSLog(@"Beginning Memory Evaluation");
    NSData *incomingData = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if (incomingData && [incomingData length])
    {
		NSString* dataAsString = [[NSString alloc] initWithData:incomingData encoding:NSASCIIStringEncoding];
		NSArray* dataAsLines = [dataAsString  componentsSeparatedByString:@"\n"];
		NSString* memoryInformation;
		if ([dataAsLines count] > 4) memoryInformation = [dataAsLines objectAtIndex:4];
		else
		{
			NSLog(@"Insufficient data from top"); 
			[topOutput readInBackgroundAndNotify];
			return;
		}
		FSBStorageSize wired, active, inactive, free;
		
		sscanf([memoryInformation UTF8String], "%*s %lf%c %*s %lf%c %*s %lf%c %*s %*lf%*c %*s %lf%c %*s ", &wired.value, &wired.unit, &active.value, &active.unit, &inactive.value, &inactive.unit, &free.value, &free.unit);
		
		usedMemory = covertToUnit(wired, 'M') + covertToUnit(active, 'M');
		freeMemory = covertToUnit(inactive, 'M') + covertToUnit(free, 'M');
		
		if (!totalMemory) totalMemory = usedMemory + freeMemory;
		
		oldPercentUsedMemory = percentUsedMemory;
		percentUsedMemory = ((usedMemory/totalMemory)*100);
		
		lastChange = percentUsedMemory - oldPercentUsedMemory;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MemoryUsageChanged" object:[NSNumber numberWithDouble:lastChange]];
		
        return;
    }
	
	[pool release];
}

- (double)totalMemory
{
	return totalMemory;
}

- (double)usedMemory
{
	return usedMemory;
}

- (double)lastChange
{
	return lastChange;
}

double covertToUnit(FSBStorageSize size, char unit)
{
	double result;
	result = size.value;
	if (unit == 'M')
	{
		if (size.unit == 'G')
		{
			result = (size.value * 1000);
		}
	}
	return result;
}

@end