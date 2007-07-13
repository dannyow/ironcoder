//
//  Storage.m
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import "Storage.h"
#define MAX_MARKS 60

int sortObjects(id dict1, id dict2, void *context)
{
	return [[dict2 objectForKey:@"currentCPU"] compare:[dict1 objectForKey:@"currentCPU"]];
}


@implementation Storage
- (id)init;
{
	if(![super init])
		return nil;
	
	masterList = [[NSMutableDictionary dictionaryWithCapacity:20] retain];
	NSCalendarDate *d = [NSCalendarDate calendarDate];
	lastTime  = [d timeIntervalSince1970];
	
	return self;
}

- (void)dealloc;
{

    [self setMasterList:nil];
	[super dealloc];
}

- (NSString *)description;
{
	return [masterList description];
}

- (void)parseToStorage:(NSArray *)inputArray;
{
	NSEnumerator *e = [inputArray objectEnumerator];
	NSString *entry;
	NSArray *output;
	NSString *pid;
	
	NSTimeInterval nowTime;
    NSTimeInterval diff;
	
	NSCalendarDate *d;
	
	// all entries in a parse cycle have the same time (nowTime)
    d	 = [NSCalendarDate calendarDate];
    
    nowTime  = [d timeIntervalSince1970];
    diff = nowTime - lastTime;	// for scaling
    lastTime = nowTime;
	
	@synchronized(masterList){
		
		while((entry = [e nextObject])){
			output = [self burstEntry:entry];
			pid = [self pidForEntry:output];
			
			@try{
				if([masterList objectForKey:pid]==nil){
					NSMutableDictionary *newEntry = [[NSMutableDictionary dictionaryWithCapacity:2] retain];
					[newEntry setObject:pid forKey:@"pid"];
					[newEntry setObject:[self nameForEntry:output] forKey:@"process"];
					[newEntry setObject:[NSNumber numberWithDouble:nowTime] forKey:@"creationTime"];
					[newEntry setObject:[NSNumber numberWithDouble:nowTime] forKey:@"updateTime"];
					[newEntry setObject:[self cpuForEntry:output] forKey:@"currentCPU"];
					[newEntry setObject:[NSMutableArray arrayWithObjects:[self cpuForEntry:output], nil] forKey:@"cpuArray"];
					[masterList setObject:newEntry forKey:pid];
					[newEntry release];
				}else{
					NSMutableDictionary *updateEntry = [masterList objectForKey:pid];
					[updateEntry setObject:[NSNumber numberWithDouble:nowTime] forKey:@"updateTime"];
					[updateEntry setObject:[self cpuForEntry:output] forKey:@"currentCPU"];
					if([[updateEntry objectForKey:@"cpuArray"] count] >= MAX_MARKS)
						[self trimArray:[updateEntry objectForKey:@"cpuArray"] toMax:MAX_MARKS-1];
					[[updateEntry objectForKey:@"cpuArray"] addObject:[self cpuForEntry:output]];
				}}
			@catch(id anything){
				//NSLog(@"caught: %@", [anything description]); 
			}
			
		}
	}
}



- (NSArray *)burstEntry:(NSString *)inputString;
{
	NSCharacterSet *colonSet, *digitSet, *letterSet, *whiteSpaceSet;
	NSScanner *theScanner;
	
	int processID;
	NSString *processName;
	NSString *cpuPercent;
	NSString *hourAmount;
	float minuteAmount;
	int threadCount;
	int prtsCount;
	int mregsCount;
	NSString *rprvtCount, *rshrdCount, *rSize, *vSize;
	
	NSArray *result= [[NSArray alloc] init];
	
	colonSet = [NSCharacterSet characterSetWithCharactersInString:@":"];
	digitSet = [NSCharacterSet decimalDigitCharacterSet];
	letterSet = [NSCharacterSet letterCharacterSet];
	whiteSpaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	theScanner = [NSScanner scannerWithString:inputString];
	//NSLog(@"input = %@", inputString);
	//NSLog(@"scanner = %@", [theScanner string]);
	
	while ([theScanner isAtEnd] == NO) {
        if ([theScanner scanInt:&processID] &&
			[theScanner scanUpToCharactersFromSet:digitSet
									  intoString:&processName] &&
            [theScanner scanUpToString:@"%"
									   intoString:&cpuPercent] &&
			[theScanner scanUpToCharactersFromSet:digitSet
									   intoString:NULL] &&
			[theScanner scanUpToString:@":"
							intoString:&hourAmount] &&
			[theScanner scanUpToCharactersFromSet:digitSet
									   intoString:NULL] &&
			[theScanner scanFloat:&minuteAmount] &&
			[theScanner scanInt:&threadCount] &&
			[theScanner scanInt:&prtsCount] &&
			[theScanner scanInt:&mregsCount] &&
			[theScanner scanUpToCharactersFromSet:letterSet
									   intoString:&rprvtCount] &&
			[theScanner scanUpToCharactersFromSet:digitSet
									   intoString:NULL] &&
			[theScanner scanUpToCharactersFromSet:letterSet
									   intoString:&rshrdCount] &&
			[theScanner scanUpToCharactersFromSet:digitSet
									   intoString:NULL] &&
			[theScanner scanUpToCharactersFromSet:letterSet
									   intoString:&rSize] &&
			[theScanner scanUpToCharactersFromSet:digitSet
									   intoString:NULL] &&
			[theScanner scanUpToCharactersFromSet:letterSet
									   intoString:&vSize] &&
			[theScanner scanUpToCharactersFromSet:whiteSpaceSet
									   intoString:NULL])
			{
			result = [NSArray arrayWithObjects: [NSString stringWithFormat:@"%d", processID], 
				[processName stringByTrimmingCharactersInSet:whiteSpaceSet], 
				cpuPercent,
				[NSString stringWithFormat:@"%@:%1.2f",hourAmount, minuteAmount],
				[NSNumber numberWithInt:threadCount],
				[NSNumber numberWithInt:prtsCount],
				[NSNumber numberWithInt:mregsCount],
				[rprvtCount stringByTrimmingCharactersInSet:whiteSpaceSet],
				[rshrdCount stringByTrimmingCharactersInSet:whiteSpaceSet],
				[rSize stringByTrimmingCharactersInSet:whiteSpaceSet],
				[vSize stringByTrimmingCharactersInSet:whiteSpaceSet],
				nil];
			//NSLog(@"%@", result);
			
			}else{
				//NSLog(@"Failed");
				return nil;

			}     
	}
    return [[result retain] autorelease];
}

- (NSString *)pidForEntry:(NSArray *)inputArray;
{
	return [[[inputArray objectAtIndex:0] retain] autorelease];
}

- (NSString *)nameForEntry:(NSArray *)inputArray;
{
	return [[[inputArray objectAtIndex:1] retain] autorelease];
}

- (NSNumber *)cpuForEntry:(NSArray *)inputArray;
{
	return [[[NSNumber numberWithFloat:[[inputArray objectAtIndex:2] floatValue]] retain] autorelease];
}


- (NSString *)cpuTimeForEntry:(NSArray *)inputArray;
{
	return [[[inputArray objectAtIndex:3] retain] autorelease];
}



//  masterList 
- (NSMutableDictionary *)masterList
{
    return [[masterList retain] autorelease]; 
}
- (void)setMasterList:(NSMutableDictionary *)aMasterList
{
    if (masterList != aMasterList) {
        [masterList release];
        masterList = [aMasterList copy];
    }
}

- (void)setMasterListObject:(id)aMasterListObject forKey:(id)aKey
{
    [[self masterList] setObject:aMasterListObject forKey:aKey];
}
- (void)removeMasterListObjectForKey:(id)aKey
{
    [[self masterList] removeObjectForKey:aKey];
}

- (NSArray *)sortedKeysUsing:(NSString *)aKey;
{
	[self ageEntries];
	NSArray *currentArray = [[[masterList allValues] sortedArrayUsingFunction: sortObjects context:NULL] retain];
	return [[currentArray retain] autorelease];
	
}


- (void)trimCPUArraysToMax:(unsigned int)maxMarks;
{
	// trim cpu array if greater than maxMarks
	NSEnumerator *e = [masterList objectEnumerator];
	NSDictionary *entry;
	NSRange longRange;
	longRange.location = 0;
	
	@synchronized(masterList){
		
		while(entry = [e nextObject]){
			if([[entry objectForKey:@"cpuArray"] count] > maxMarks){
				
				//NSLog(@" trimming \n %@", [[entry objectForKey:@"cpuArray"] description]);
				
				longRange.length = [[entry objectForKey:@"cpuArray"] count] - maxMarks;
				[[entry objectForKey:@"cpuArray"] removeObjectsInRange:longRange];
				
				//NSLog(@"\n trimmed \n %@", [[entry objectForKey:@"cpuArray"] description]);
			}
		}
	}
	
}

- (void)trimArray:(NSMutableArray *)anArray toMax:(unsigned int)maxCount;
{
	NSRange maxRange;
	maxRange.location = 0;
	
	@synchronized(anArray){
		if([anArray count] <= maxCount)
			return;
		
		maxRange.length = [anArray count] - maxCount;
		[anArray removeObjectsInRange:maxRange];
	}
}

- (void)checkStaleEntries;
{
	staleCounter++;
	
	if(staleCounter <= MAX_STALE)
		return;
	
	staleCounter = 0;
	
	// trim cpu array if greater than maxMarks
	NSEnumerator *e = [masterList objectEnumerator];
	NSMutableArray *del = [[NSMutableArray arrayWithCapacity:2] retain];
	
	NSTimeInterval nowTime;
    NSTimeInterval diff;
    NSCalendarDate *d;
    d	 = [NSCalendarDate calendarDate];
    nowTime  = [d timeIntervalSince1970];
    id entry;
	
	
	@synchronized(masterList){
		
		while(entry = [e nextObject]){
			diff = nowTime - [[entry objectForKey:@"updateTime"] doubleValue];
			if(diff >= MAX_STALE){
				[del addObject:[entry objectForKey:@"pid"]];
			}
		}
		
		e = [del objectEnumerator];
		while(entry = [e nextObject]){
			[masterList removeObjectForKey:entry];
		}
	}
	
}


- (void)ageEntries;
{
	NSTimeInterval nowTime;
    NSTimeInterval diff, entryTime, entryDiff;
    NSCalendarDate *d;
    d	 = [NSCalendarDate calendarDate];
    nowTime  = [d timeIntervalSince1970];

	diff = nowTime - lastTime;
	lastTime = nowTime;
	
	NSEnumerator *e = [masterList objectEnumerator];
	id anObject;
	
	@synchronized(masterList){
	
		while(anObject = [e nextObject]){
			// check to see if last last update is beyond horizon
			entryTime = [[anObject valueForKey:@"updateTime"] doubleValue];
			entryDiff = nowTime - entryTime;
			if(entryDiff > diff){
				[anObject setObject:[NSNumber numberWithFloat:0.0] forKey:@"currentCPU"];
				[anObject setObject:[NSNumber numberWithDouble:nowTime] forKey:@"updateTime"];
				NSMutableArray *tArray = [[NSMutableArray arrayWithArray:[anObject objectForKey:@"cpuArray"]] retain];
				[tArray addObject:[NSNumber numberWithFloat:0.0]];
				[anObject setObject:tArray forKey:@"cpuArray"];
			}
			
		}
		
	}
	
}

@end
