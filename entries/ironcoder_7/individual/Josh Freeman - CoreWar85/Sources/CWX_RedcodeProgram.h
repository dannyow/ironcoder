//
//  CWX_RedcodeProgram.h
//  CoreWarX
//
//  Created by Josh Freeman on 11/12/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CWX_Defines.h"
#import "CWX_Redcode_Defines.h"

@interface CWX_RedcodeProgram : NSObject 
{
	NSString *name;
	Redcode_MemoryCell instructionsArray[REDCODE_PROGRAM_MAX_NUM_INSTRUCTIONS];
	short numInstructions;
	short firstExecutableInstruction;
	
	// tournament fields
	short wins;
	short losses;
	short ties;
	short points;
	short matchesPlayed;
}

+ programWithFile: (NSString *) filePath
	returnedError: (NSString **) returnedErrorString;

+ programFromString: (NSString *) redcodeText
			andName: (NSString *) programName
		returnedError: (NSString **) returnedErrorString;
								
- initWithString: (NSString *) redcodeText
		andName: (NSString *) programName
		returnedError: (NSString **) returnedErrorString;
		
- (NSString *) name;
- (Redcode_MemoryCell *) instructionsArray;
- (short) numInstructions;
- (short) firstExecutableInstruction;

- (short) wins;
- (short) losses;
- (short) ties;
- (short) points;
- (short) matchesPlayed;

- (void) clearTournamentFields;
- (short) incrementWins;
- (short) incrementLosses;
- (short) incrementTies;

@end
