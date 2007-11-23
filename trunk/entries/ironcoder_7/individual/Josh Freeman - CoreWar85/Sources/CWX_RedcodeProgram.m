//
//  CWX_RedcodeProgram.m
//  CoreWarX
//
//  Created by Josh Freeman on 11/12/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_RedcodeProgram.h"

#import "CWX_Defines.h"
#import "CWX_String_Defines.h"
#import "CWX_RedcodeAssembler.h"

@implementation CWX_RedcodeProgram

+ programWithFile: (NSString *) filePath
	returnedError: (NSString **) returnedErrorString
{
	NSData *fileData;
	NSString *programName, *redcodeText, *errorString = nil;

	if (!filePath || ![filePath length])
	{
		errorString = kCWX_String_BadFilePath;
		goto ERROR;
	}
	
	if (!(programName = [[filePath lastPathComponent] stringByDeletingPathExtension])
		|| ![programName length])
	{
		errorString = kCWX_String_BadProgramParameters;
		goto ERROR;
	}
	
	// Can't use stringWithContentsOfFile: if it's going to run on Panther
	if (!(fileData = [NSData dataWithContentsOfFile: filePath])
		|| !(redcodeText = [[[NSString alloc] initWithData: fileData
												encoding: NSUTF8StringEncoding]
									autorelease]))
	{
		errorString = kCWX_String_UnableToReadProgramFile;
		goto ERROR;
	}
	
	return [self programFromString: redcodeText 
							andName: programName 
							returnedError: returnedErrorString];

ERROR:
	if (returnedErrorString)
		*returnedErrorString = errorString;
		
	return nil;
}

+ programFromString: (NSString *) redcodeText
			andName: (NSString *) programName
		returnedError: (NSString **) returnedErrorString
{
	return [[[self alloc] initWithString: redcodeText 
								andName: programName 
							returnedError: returnedErrorString]
					autorelease];
}
								
- initWithString: (NSString *) redcodeText
		andName: (NSString *) programName
		returnedError: (NSString **) returnedErrorString
{
	NSString *errorString = nil;

	self = [super init];
	
	if (self)
	{
		if (!redcodeText || ![redcodeText length]
			|| !programName || ![programName length])
		{
			errorString = kCWX_String_BadProgramParameters;
			goto ERROR;
		}
		
		if (![self assembleRedcode: redcodeText returnedError: &errorString])
			goto ERROR;
			
		name = [programName retain];
	}
	
	if (returnedErrorString)
		*returnedErrorString = nil;
	
	return self;
	
ERROR:
	[self release];
	
	if (returnedErrorString)
		*returnedErrorString = errorString;
	
	return nil;
}

- init
{
	return [self initWithString: nil andName: nil returnedError: nil];
}

- (void) dealloc
{
	[name release];
	
	[super dealloc];
}

- (NSString *) name
{
	return name;
}

- (Redcode_MemoryCell *) instructionsArray
{
	return instructionsArray;
}

- (short) numInstructions
{
	return numInstructions;
}

- (short) firstExecutableInstruction
{
	return firstExecutableInstruction;
}

- (short) wins
{
	return wins;
}

- (short) losses
{
	return losses;
}

- (short) ties
{
	return ties;
}

- (short) points
{
	return points;
}

- (short) matchesPlayed
{
	return matchesPlayed;
}

- (void) clearTournamentFields
{
	wins = losses = ties = points = matchesPlayed = 0;
}

- (short) incrementWins
{
	matchesPlayed++;
	points += TOURNAMENT_POINTS_PER_WIN;
	
	return ++wins;
}

- (short) incrementLosses
{
	matchesPlayed++;
	points += TOURNAMENT_POINTS_PER_LOSS;
	
	return ++losses;
}

- (short) incrementTies
{
	matchesPlayed++;
	points += TOURNAMENT_POINTS_PER_TIE;
	
	return ++ties;
}

@end
