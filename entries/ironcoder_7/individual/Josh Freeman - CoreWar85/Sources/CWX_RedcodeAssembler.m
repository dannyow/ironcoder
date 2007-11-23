//
//  CWX_RedcodeAssembler.m
//  CoreWarX
//
//  Created by Josh Freeman on 11/12/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_RedcodeAssembler.h"

#import "CWX_String_Defines.h"

static void InitializeGlobals(void);
static NSDictionary *OpsDictionary(void);
static bool ReadRedcodeLineIntoMemoryCell(NSString *redcodeLine, Redcode_MemoryCell *memoryCell,
											bool *returnedSyntaxError);
static bool ReadArgumentFromString(NSString *redcodeLine, unsigned beginIndex, 
									unsigned *returnedEndIndex, bool allowImmediateMode,
									bool allowComma, short *returnedArgumentValue, 
									Redcode_AddressMode *returnedAddressMode);
static bool GetIndexOfFirstNonWhitespaceChar(NSString *string, unsigned *index);

static NSDictionary *gOpsDictionary = nil;
static NSCharacterSet *gNonWhitespaceCharacterSet = nil, *gNonNumberCharacterSet = nil;
static bool globalsAreInitialized = NO;


@implementation CWX_RedcodeProgram (RedcodeAssembler)

- (bool) assembleRedcode: (NSString *) redcodeText
	returnedError: (NSString **) returnedErrorString
{
	NSString *newlineSequence, *errorString, *redcodeLine;
	int numLinesRead;
	NSArray *redcodeTextLines;
	Redcode_MemoryCell *currentMemoryCell;
	NSEnumerator *enumerator;
	bool hadSyntaxError, foundExecutableInstruction;

	if (!globalsAreInitialized)
		InitializeGlobals();
	
	if (!redcodeText || ![redcodeText length])
	{
		errorString = kCWX_String_UnableToReadProgramText;
		goto ERROR;
	}
	
	if ([redcodeText rangeOfString: @"\r\n"].length)
		newlineSequence = @"\r\n";	// Win newlines
	else if ([redcodeText rangeOfString: @"\r"].length)
		newlineSequence = @"\r";	// Mac newlines
	else
		newlineSequence = @"\n";	// Unix newlines
		
	redcodeTextLines = [redcodeText componentsSeparatedByString: newlineSequence];
	
	if (!redcodeTextLines || ![redcodeTextLines count])
	{
		errorString = kCWX_String_UnableToReadProgramText;
		goto ERROR;
	}
	
	enumerator = [redcodeTextLines objectEnumerator];
	numLinesRead = 0;
	numInstructions = 0;
	currentMemoryCell = &instructionsArray[numInstructions];
	foundExecutableInstruction = NO;
	
	while (redcodeLine = [enumerator nextObject])
	{
		numLinesRead++;
		
		if (ReadRedcodeLineIntoMemoryCell(redcodeLine, currentMemoryCell, &hadSyntaxError))
		{
			if (!foundExecutableInstruction 
				&& (currentMemoryCell->opcode != Redcode_Opcode_DAT))
			{
				foundExecutableInstruction = YES;
				firstExecutableInstruction = numInstructions;
			}
		
			numInstructions++;
			currentMemoryCell++;
		}
		
		if (hadSyntaxError)
		{
			errorString = [NSString stringWithFormat: 
								kCWX_String_SyntaxErrorFormatStringWithLineNumberAndLineText,
								numLinesRead,
								redcodeLine];
		
			goto ERROR;
		}
	}
	
	if (!numInstructions)
	{
		errorString = kCWX_String_UnableToReadProgramText;
		goto ERROR;
	}
	
	if (!foundExecutableInstruction)
	{
		errorString = kCWX_String_UnableToReadProgramText;
		goto ERROR;
	}
	
	return YES;

ERROR:
	if (returnedErrorString)
		*returnedErrorString = errorString;

	return NO;
}

@end

static void InitializeGlobals(void)
{
	if (globalsAreInitialized)
		return;

	gNonWhitespaceCharacterSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] 
										retain];
			
	gNonNumberCharacterSet = [[[NSCharacterSet decimalDigitCharacterSet] invertedSet] 
										retain];

	gOpsDictionary = [OpsDictionary() retain];

	globalsAreInitialized = YES;
}

NSDictionary *OpsDictionary(void)
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_DAT],	// DAT Opcode
					[NSNumber numberWithBool: NO],					// Has second argument
					[NSNumber numberWithBool: NO],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: NO],					// Uses ArgA for jump
					nil],
				@"DAT",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_MOV],	// MOV Opcode
					[NSNumber numberWithBool: YES],					// Has second argument
					[NSNumber numberWithBool: YES],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: NO],					// Uses ArgA for jump
					nil],
				@"MOV",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_ADD],	// ADD Opcode
					[NSNumber numberWithBool: YES],					// Has second argument
					[NSNumber numberWithBool: YES],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: NO],					// Uses ArgA for jump
					nil],
				@"ADD",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_SUB],	// SUB Opcode
					[NSNumber numberWithBool: YES],					// Has second argument
					[NSNumber numberWithBool: YES],					// Allow immediate mode
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: NO],					// Uses ArgA for jump
					nil],
				@"SUB",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_JMP],	// JMP Opcode
					[NSNumber numberWithBool: NO],					// Has second argument
					[NSNumber numberWithBool: NO],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: YES],					// Uses ArgA for jump
					nil],
				@"JMP",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_JMZ],	// JMZ Opcode
					[NSNumber numberWithBool: YES],					// Has second argument
					[NSNumber numberWithBool: NO],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: YES],					// Uses ArgA for jump
					nil],
				@"JMZ",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_JMG],	// JMG Opcode
					[NSNumber numberWithBool: YES],					// Has second argument
					[NSNumber numberWithBool: NO],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: YES],					// Uses ArgA for jump
					nil],
				@"JMG",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_DJZ],	// DJZ Opcode
					[NSNumber numberWithBool: YES],					// Has second argument
					[NSNumber numberWithBool: NO],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: YES],					// Uses ArgA for jump
					nil],
				@"DJZ",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_CMP],	// CMP Opcode
					[NSNumber numberWithBool: YES],					// Has second argument
					[NSNumber numberWithBool: YES],					// Allow immediate mode A
					[NSNumber numberWithBool: YES],					// Allow immediate mode B
					[NSNumber numberWithBool: NO],					// Uses ArgA for jump
					nil],
				@"CMP",
				
				[NSArray arrayWithObjects:
					[NSNumber numberWithInt: Redcode_Opcode_SPL],	// SPL Opcode
					[NSNumber numberWithBool: NO],					// Has second argument
					[NSNumber numberWithBool: NO],					// Allow immediate mode A
					[NSNumber numberWithBool: NO],					// Allow immediate mode B
					[NSNumber numberWithBool: YES],					// Uses ArgA for jump
					nil],
				@"SPL",
				
				nil];
}

static bool ReadRedcodeLineIntoMemoryCell(NSString *redcodeLine, Redcode_MemoryCell *memoryCell,
											bool *returnedSyntaxError)
{
	NSString *opString;
	bool instructionWasParsed, hadSyntaxError, hasSecondArgument, usesArgAForJMP;
	bool allowImmediateModeA, allowImmediateModeB;
	unsigned beginIndex, endIndex;
	short argumentValue;
	NSArray *opDataArray;
	Redcode_AddressMode addressMode;
	NSRange range;

	instructionWasParsed = NO;
	hadSyntaxError = NO;
		
	if (!redcodeLine || ![redcodeLine length] || !memoryCell)
		goto EXIT;
		
	memset(memoryCell, 0, sizeof(Redcode_MemoryCell));
	
	// ignore anything after ";"
	range = [redcodeLine rangeOfString: @";"];
	
	if (range.length)
	{
		if (range.location == 0)
			goto EXIT;
	
		redcodeLine = [redcodeLine substringToIndex: range.location];
	}
	
	// look for op beginning with first non-whitespace char
	range = [redcodeLine rangeOfCharacterFromSet: gNonWhitespaceCharacterSet];
	
	if (!range.length)
		goto EXIT;
		
	if (range.location >= ([redcodeLine length] - 3))
	{
		hadSyntaxError = YES;
		goto EXIT;
	}
	
	range.length = 3;
		
	opString = [[redcodeLine substringWithRange: range] uppercaseString];
		
	opDataArray = [gOpsDictionary objectForKey: opString];
	
	if (!opDataArray)
	{
		hadSyntaxError = YES;
		goto EXIT;
	}

	memoryCell->opcode = [[opDataArray objectAtIndex: 0] intValue];
	hasSecondArgument = [[opDataArray objectAtIndex: 1] boolValue];
	allowImmediateModeA = [[opDataArray objectAtIndex: 2] boolValue];	
	allowImmediateModeB = [[opDataArray objectAtIndex: 3] boolValue];
	usesArgAForJMP = [[opDataArray objectAtIndex: 4] boolValue];
	
	beginIndex = range.location + 3;
	
	if (!ReadArgumentFromString(redcodeLine, beginIndex, &endIndex, allowImmediateModeA, NO,
								&argumentValue, &addressMode))
	{
		hadSyntaxError = YES;
		goto EXIT;
	}
	
	if (memoryCell->opcode != Redcode_Opcode_DAT)
	{
		memoryCell->argumentA = argumentValue;
		memoryCell->addressModeA = addressMode;
	}
	else
	{
		if (addressMode != Redcode_AddressMode_Direct)
		{
			hadSyntaxError = YES;
			goto EXIT;
		}
		
		memoryCell->argumentB = argumentValue;
	}	

	if (hasSecondArgument)
	{
		if (!ReadArgumentFromString(redcodeLine, endIndex, nil, allowImmediateModeB, YES, 
									&memoryCell->argumentB, &addressMode))
		{
			hadSyntaxError = YES;
			goto EXIT;
		}

		memoryCell->addressModeB = addressMode;
	}

	instructionWasParsed = YES;	
		
EXIT:
	if (returnedSyntaxError)
		*returnedSyntaxError = hadSyntaxError;
	
	return instructionWasParsed;
}

static bool ReadArgumentFromString(NSString *redcodeLine, unsigned beginIndex, 
									unsigned *returnedEndIndex, bool allowImmediateMode,
									bool allowComma, short *returnedArgumentValue, 
									Redcode_AddressMode *returnedAddressMode)
{
	int lineLength;
	unichar currentChar;
	unsigned currentIndex;
	
	lineLength = [redcodeLine length];
	currentIndex = beginIndex;
	
	if (!redcodeLine || !returnedArgumentValue || !returnedAddressMode
		|| (currentIndex >= lineLength)
		|| !GetIndexOfFirstNonWhitespaceChar(redcodeLine, &currentIndex))
		return NO;

	*returnedAddressMode = Redcode_AddressMode_Direct;	
	currentChar = [redcodeLine characterAtIndex: currentIndex];
	
	if (currentChar == ',')
	{
		currentIndex++;
		
		if (!allowComma 
				|| !GetIndexOfFirstNonWhitespaceChar(redcodeLine, &currentIndex))
		{
			return NO;
		}	
		
		currentChar = [redcodeLine characterAtIndex: currentIndex];
	}

	if (currentChar == '#')
	{
		currentIndex++;
	
		if (!allowImmediateMode 
				|| !GetIndexOfFirstNonWhitespaceChar(redcodeLine, &currentIndex))
		{
			return NO;
		}	
		
		currentChar = [redcodeLine characterAtIndex: currentIndex];
		*returnedAddressMode = Redcode_AddressMode_Immediate;
	}
	else if (currentChar == '@')
	{
		currentIndex++;
	
		if (!GetIndexOfFirstNonWhitespaceChar(redcodeLine, &currentIndex))
			return NO;

		currentChar = [redcodeLine characterAtIndex: currentIndex];
		*returnedAddressMode = Redcode_AddressMode_Indirect;
	}
	
	if (currentChar == '-')
	{
		// get next char to check for number, but leave currentIndex at its current value
		// so the '-' gets read by intValue
		currentChar = [redcodeLine characterAtIndex: currentIndex+1];
	}
		
	if ((currentChar < '0') || (currentChar > '9'))
		return NO;
	
	*returnedArgumentValue = [[redcodeLine substringFromIndex: currentIndex] intValue];
	
	if (returnedEndIndex)
	{
		currentIndex++;
		
		if (currentIndex < lineLength)
		{
			NSRange range;

			range = [redcodeLine rangeOfCharacterFromSet: gNonNumberCharacterSet
								options: 0
								range: NSMakeRange(currentIndex, lineLength - currentIndex)];
							
			*returnedEndIndex = (range.length) ? range.location : lineLength;
		}
		else
		{
			*returnedEndIndex = lineLength;
		}
	}
	
	return YES;
}

static bool GetIndexOfFirstNonWhitespaceChar(NSString *string, unsigned *index)
{
	NSRange range;
	
	if (!string || !index || (*index >= [string length]))
		return NO;
		
	range = [string rangeOfCharacterFromSet: gNonWhitespaceCharacterSet
							options: 0
							range: NSMakeRange(*index, [string length] - *index)];
	
	if (!range.length)
		return NO;
	
	*index = range.location;
	return YES;
}

