//
//  Storage.h
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define MAX_STALE 120

@interface Storage : NSObject {
	int staleCounter;
	
	NSMutableDictionary *masterList;
    NSTimeInterval lastTime;
}

- (void)parseToStorage:(NSArray *)inputArray;

- (NSArray *)burstEntry:(NSString *)inputString;
- (NSString *)pidForEntry:(NSArray *)inputArray;
- (NSString *)nameForEntry:(NSArray *)inputArray;
- (NSNumber *)cpuForEntry:(NSArray *)inputArray;
- (NSString *)cpuTimeForEntry:(NSArray *)inputArray;


- (NSMutableDictionary *)masterList;
- (void)setMasterList:(NSMutableDictionary *)aMasterList;
- (void)setMasterListObject:(id)aMasterListObject forKey:(id)aKey;
- (void)removeMasterListObjectForKey:(id)aKey;

- (NSArray *)sortedKeysUsing:(NSString *)aKey;

- (void)trimCPUArraysToMax:(unsigned int)maxMarks;
- (void)trimArray:(NSMutableArray *)anArray toMax:(unsigned int)maxCount;

- (void)checkStaleEntries;
- (void)ageEntries;

@end
