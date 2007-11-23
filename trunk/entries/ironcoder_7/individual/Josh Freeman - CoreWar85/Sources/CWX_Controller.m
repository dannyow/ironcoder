//
//  CWX_Controller.m
//  CoreWarX
//
//  Created by Josh Freeman on 11/13/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_Controller.h"

#import "CWX_Defines.h"
#import "CWX_MemoryArrayView.h"
#import "CWX_Simulator.h"
#import "CWX_RedcodeProgram.h"
#import "CWX_String_Defines.h"

#define kCycleTime								(1.0/90.0)
#define kMainWindowIdentifier					@"MainWindow"
#define kRedcodeFileExtension					@"txt"

#define kTournamentTableColumnIdentifier_ProgramName		@"Program Name"
#define kTournamentTableColumnIdentifier_TournamentPoints	@"Tournament Points"
#define kTournamentTableColumnIdentifier_MatchesPlayed		@"Matches Played"
#define kTournamentTableColumnIdentifier_Wins				@"Wins"
#define kTournamentTableColumnIdentifier_Losses				@"Losses"
#define kTournamentTableColumnIdentifier_Ties				@"Ties"

@interface CWX_Controller (PrivateMethods)

- (void) setControllerStatus: (CWX_ControllerStatus) newControllerStatus;

- (void) fileOpenPanelDidEnd: (NSOpenPanel *) panel 
				returnCode: (int) returnCode
				contextInfo: (void  *) contextInfo;
- (void) loadProgramsFromFilenames: (NSArray *) filenamesArray
				returnedErrorString: (NSString **) returnedErrorString;

- (void) verifyTournamentReset;

- (void) beginTournament;
- (void) initAllTournamentValues;
- (void) resetMatchInfoBattleValues;
- (void) beginSimulatorWithCurrentMatchInfo;
- (void) updateMatchDataBoxProgramValues;
- (void) updateMatchDataBoxProcessValues;

- (void) cycleTimerFired: (NSTimer*) theTimer;
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication;
- (void) windowDidResize: (NSNotification *) notification;
- (void) windowDidMove: (NSNotification *) notification;
- (void) updateMemoryArrayViewWithInitialProgramState;
- (void) updateDisplayUsingSimulatorCycleInfo;

@end

@implementation CWX_Controller

- init
{
	self = [super init];
	
	if (self)
	{
		allowedFileTypesArray = [[NSArray arrayWithObjects: kRedcodeFileExtension, nil] retain];

		[[NSRunLoop currentRunLoop] addTimer: [NSTimer timerWithTimeInterval: kCycleTime
														target: self 
														selector: @selector(cycleTimerFired:) 
														userInfo: nil 
														repeats: YES]
									forMode: NSDefaultRunLoopMode];

		programsArray = [[NSMutableArray array] retain];

		[[NSApplication sharedApplication] setDelegate: self];
	}
	
	return self;
}

- (void) dealloc
{
	[programsArray release];
	[allowedFileTypesArray release];
	[cycleTimer release];
	
	
	[super dealloc];
}

- (void) awakeFromNib
{
	[self setControllerStatus: CWX_ControllerStatus_WaitingForUserToLoadPrograms];
	
	[tournamentTableView setDataSource: self];
	
	[mainWindow setFrameUsingName: kMainWindowIdentifier];	
	
	[mainWindow makeKeyAndOrderFront: self];
}

- (void) setControllerStatus: (CWX_ControllerStatus) newControllerStatus
{
	switch (newControllerStatus)
	{
		case CWX_ControllerStatus_WaitingForUserToLoadPrograms:
		case CWX_ControllerStatus_WaitingToBeginTournament:
		{
			controllerStatus = newControllerStatus;
	
			[matchDataBox setHidden: YES];
			[resetTournamentButton setEnabled: NO];
			[beginPauseContinueTournamentButton setTitle: kCWX_String_UI_BPCButton_BeginString];
			
			if (simulator)
			{
				[simulator release];
				simulator = nil;
			}
		}
		break;
		
		case CWX_ControllerStatus_TournamentRunning:
		{
			controllerStatus = newControllerStatus;
	
			[matchDataBox setHidden: NO];
			[resetTournamentButton setEnabled: YES];
			[beginPauseContinueTournamentButton setTitle: kCWX_String_UI_BPCButton_PauseString];
		}
		break;

		case CWX_ControllerStatus_TournamentPaused:
		{
			controllerStatus = newControllerStatus;
	
			[matchDataBox setHidden: NO];
			[resetTournamentButton setEnabled: YES];
			[beginPauseContinueTournamentButton 
											setTitle: kCWX_String_UI_BPCButton_ContinueString];
		}
		break;
	}
}

- (IBAction) loadProgramsButtonPressed: (id) sender
{
	NSOpenPanel *openPanel;
	
	if (controllerStatus >= CWX_ControllerStatus_TournamentRunning)
	{
		delayedAction = ControllerDelayedAction_LoadPrograms;
		[self verifyTournamentReset];
		return;
	}
	
	openPanel = [NSOpenPanel openPanel];
	
	[openPanel setCanChooseDirectories: YES];
	[openPanel setAllowsMultipleSelection: YES];

	[openPanel beginSheetForDirectory: fileDirectoryPath
								file: nil
								types: allowedFileTypesArray
						modalForWindow: mainWindow
						modalDelegate: self
						didEndSelector: 
							@selector(fileOpenPanelDidEnd:returnCode:contextInfo:)
						contextInfo: sender];
}

- (void) fileOpenPanelDidEnd: (NSOpenPanel *) panel 
				returnCode: (int) returnCode
				contextInfo: (void  *) contextInfo
{
	NSString *errorString;
	
	[[NSApplication sharedApplication] endSheet: panel];
	[panel orderOut: self];

	if (returnCode != NSOKButton)
		return;
		
	[fileDirectoryPath release];
	fileDirectoryPath = [[[panel filename] stringByDeletingLastPathComponent] retain];

	[self loadProgramsFromFilenames: [panel filenames]
				returnedErrorString: &errorString];
				
	[tournamentTableView reloadData];
				
	if (errorString)
	{
		NSBeginAlertSheet(@" ", kCWX_String_UI_OKButtonString, nil, nil, mainWindow, nil, 
							nil, nil, nil, errorString);
	}
	
	if ((controllerStatus == CWX_ControllerStatus_WaitingForUserToLoadPrograms)
		&& ([programsArray count] >= 2))
	{
		[self setControllerStatus: CWX_ControllerStatus_WaitingToBeginTournament];
	}
}

- (void) loadProgramsFromFilenames: (NSArray *) filenamesArray
				returnedErrorString: (NSString **) returnedErrorString
{
	NSFileManager *fileManager;
	NSMutableString *accumulatedErrorString, *filePath, *fileName;
	NSString *errorString;
	NSMutableArray *allFilenamesArray;
	NSEnumerator *enumerator;
	CWX_RedcodeProgram *program;
	BOOL isDirectory;
	unsigned i;
	
	fileManager = [NSFileManager defaultManager];
	accumulatedErrorString = [NSMutableString string];
	allFilenamesArray = [NSMutableArray arrayWithArray: filenamesArray];
	
	for(i=0; i<[allFilenamesArray count]; i++)
	{
		filePath = [allFilenamesArray objectAtIndex: i];
		
		if ([fileManager fileExistsAtPath: filePath isDirectory: &isDirectory])
		{
			if (isDirectory)
			{
				enumerator = [[fileManager directoryContentsAtPath: filePath] objectEnumerator];
				
				while (fileName = [enumerator nextObject])
				{
					if ([kRedcodeFileExtension compare: [fileName pathExtension]
											options: NSCaseInsensitiveSearch] == NSOrderedSame)
					{
						[allFilenamesArray addObject: 
										[filePath stringByAppendingPathComponent: fileName]];
					}
				}
			}
			else
			{
				if ([kRedcodeFileExtension compare: [filePath pathExtension]
											options: NSCaseInsensitiveSearch] == NSOrderedSame)
				{
					if (program = [CWX_RedcodeProgram programWithFile: filePath 
													returnedError: &errorString])
					{
						[programsArray addObject: program];
					}
					else
					{
						[accumulatedErrorString appendFormat: @"%@: %@\n",
													[filePath lastPathComponent],
													errorString];
					}
				}
			}
		}
	}
	
	if (returnedErrorString)
	{
		if ([accumulatedErrorString length])
			*returnedErrorString = [NSString stringWithString: accumulatedErrorString];
		else
			*returnedErrorString = nil;
	}
}

- (IBAction) removeProgramsButtonPressed: (id) sender
{
	if (controllerStatus >= CWX_ControllerStatus_TournamentRunning)
	{
		delayedAction = ControllerDelayedAction_RemovePrograms;
		[self verifyTournamentReset];
		return;
	}
	
	[programsArray removeAllObjects];
	[tournamentTableView reloadData];
	[self setControllerStatus: CWX_ControllerStatus_WaitingForUserToLoadPrograms];
}

- (IBAction) resetTournamentButtonPressed: (id) sender
{
	if (controllerStatus >= CWX_ControllerStatus_TournamentRunning)
	{
		delayedAction = ControllerDelayedAction_ResetTournament;
		[self verifyTournamentReset];
		return;
	}
}

- (void) verifyTournamentReset
{
	if (controllerStatus < CWX_ControllerStatus_TournamentRunning)
		return;

	previousControllerStatus = controllerStatus;
	[self setControllerStatus: CWX_ControllerStatus_TournamentPaused];

	NSBeginAlertSheet(@" ", kCWX_String_UI_OKButtonString, kCWX_String_UI_CancelButtonString, 
						nil, mainWindow, self, 
						@selector(verifyTournamentResetSheetDidEnd:returnCode:contextInfo:), 
						nil, nil, kCWX_String_UI_TournamentResetConfirmString);
}

- (void) verifyTournamentResetSheetDidEnd: (NSWindow *) sheet 
							returnCode: (int) returnCode 
							contextInfo: (void *) contextInfo
{
	[[NSApplication sharedApplication] endSheet: sheet];
	[sheet orderOut: self];

	if (returnCode == NSAlertDefaultReturn)
	{
		[self setControllerStatus: CWX_ControllerStatus_WaitingToBeginTournament];
	
		[memoryArrayView clearArray];
		[self initAllTournamentValues];
		[tournamentTableView reloadData];	
		
		switch (delayedAction)
		{
			case ControllerDelayedAction_LoadPrograms:
			{
				[self loadProgramsButtonPressed: self];
			}
			break;
		
			case ControllerDelayedAction_RemovePrograms:
			{
				[self removeProgramsButtonPressed: self];
			}
			break;
		
			case ControllerDelayedAction_ResetTournament:
			{
				[self resetTournamentButtonPressed: self];
			}
			break;
		}
	}
	else
	{
		[self setControllerStatus: previousControllerStatus];
	}
}

- (IBAction) beginPauseContinueTournmentButtonPressed: (id) sender
{
	switch (controllerStatus)
	{
		case CWX_ControllerStatus_WaitingForUserToLoadPrograms:
		{
			NSBeginAlertSheet(@" ", kCWX_String_UI_OKButtonString, nil, nil, mainWindow, nil, 
							nil, nil, nil, kCWX_String_UI_NotEnoughProgramsLoaded);
		}
		break;
		
		case CWX_ControllerStatus_WaitingToBeginTournament:
		{
			[self beginTournament];
		}
		break;
		
		case CWX_ControllerStatus_TournamentRunning:
		{
			[self setControllerStatus: CWX_ControllerStatus_TournamentPaused];
		}
		break;
		
		case CWX_ControllerStatus_TournamentPaused:
		{
			[self setControllerStatus: CWX_ControllerStatus_TournamentRunning];
		}
		break;
	}
}

- (void) beginTournament
{
	[self initAllTournamentValues];
	[self beginSimulatorWithCurrentMatchInfo];
	[tournamentTableView reloadData];
	[self setControllerStatus: CWX_ControllerStatus_TournamentRunning];
}

- (void) initAllTournamentValues
{
	NSEnumerator *enumerator;
	CWX_RedcodeProgram *program;
	
	enumerator = [programsArray objectEnumerator];

	while (program = [enumerator nextObject])
		[program clearTournamentFields];
		
	[self resetMatchInfoBattleValues];
	matchInfo[0].programArrayIndex = 0;
	matchInfo[1].programArrayIndex = 1;

	numMatchesPlayed = 0;
	numPrograms = [programsArray count];
}

- (void) resetMatchInfoBattleValues
{
	matchInfo[0].points = 0;
	matchInfo[0].wins = 0;
	matchInfo[0].losses = 0;
	matchInfo[0].ties = 0;
	matchInfo[0].numProcesses = 0;

	matchInfo[1].points = 0;
	matchInfo[1].wins = 0;
	matchInfo[1].losses = 0;
	matchInfo[1].ties = 0;
	matchInfo[1].numProcesses = 0;
}

- (void) beginSimulatorWithCurrentMatchInfo	
{
	if (simulator)
		[simulator release];
		
	programs[0] = [programsArray objectAtIndex: matchInfo[0].programArrayIndex];
	programs[1] = [programsArray objectAtIndex: matchInfo[1].programArrayIndex];
		
	simulator = [[CWX_Simulator simulatorWithProgram0: programs[0]
										andProgram1: programs[1]] retain];
						
	if (!simulator)
	{
		NSBeginAlertSheet(@" ", kCWX_String_UI_OKButtonString, nil, nil, mainWindow, nil, 
							nil, nil, nil, kCWX_String_UI_InternalError);
							
		[self setControllerStatus: CWX_ControllerStatus_WaitingToBeginTournament];
		return;
	}

	[memoryArrayView clearArray];
	[self updateMemoryArrayViewWithInitialProgramState];

	matchInfo[0].numProcesses = 1;
	matchInfo[1].numProcesses = 1;

	[program0NameTextField setStringValue: [programs[0] name]];
	[program1NameTextField setStringValue: [programs[1] name]];
	
	[self updateMatchDataBoxProgramValues];
	[self updateMatchDataBoxProcessValues];
}

- (void) updateMatchDataBoxProgramValues
{
	[program0PointsTextField setIntValue: matchInfo[0].points];
	[program0WinsTextField setIntValue: matchInfo[0].wins];
	[program0LossesTextField setIntValue: matchInfo[0].losses];
	[program0TiesTextField setIntValue: matchInfo[0].ties];
	
	[program1PointsTextField setIntValue: matchInfo[1].points];
	[program1WinsTextField setIntValue: matchInfo[1].wins];
	[program1LossesTextField setIntValue: matchInfo[1].losses];
	[program1TiesTextField setIntValue: matchInfo[1].ties];
}

- (void) updateMatchDataBoxProcessValues
{
	[program0ProcessesTextField setIntValue: matchInfo[0].numProcesses];
	[program1ProcessesTextField setIntValue: matchInfo[1].numProcesses];
}

- (void) cycleTimerFired: (NSTimer *) theTimer
{
	bool finishedBattle = NO;
	CWX_ContestStatus simulatorStatus;

	if ((controllerStatus != CWX_ControllerStatus_TournamentRunning)
		|| !simulator 
		|| (simulator && ([simulator contestStatus] != contestStatus_Running)))
	{
		return;
	}
	
	simulatorStatus = [simulator executeOneCycleWithReturnedInfo: &simulatorCycleInfo];
	
	switch (simulatorStatus)
	{
		case contestStatus_Running:
		break;
	
		case contestStatus_WonByProgram0:
		{
			matchInfo[0].points += MATCH_POINTS_PER_WIN;
			matchInfo[0].wins++;
			
			matchInfo[1].points += MATCH_POINTS_PER_LOSS;
			matchInfo[1].losses++;

			finishedBattle = YES;
		}
		break;
		
		case contestStatus_WonByProgram1:
		{
			matchInfo[0].points += MATCH_POINTS_PER_LOSS;
			matchInfo[0].losses++;
			
			matchInfo[1].points += MATCH_POINTS_PER_WIN;
			matchInfo[1].wins++;
			
			finishedBattle = YES;
		}
		break;
		
		case contestStatus_Draw:
		{
			matchInfo[0].points += MATCH_POINTS_PER_TIE;
			matchInfo[0].ties++;
			
			matchInfo[1].points += MATCH_POINTS_PER_TIE;
			matchInfo[1].ties++;
			
			finishedBattle = YES;
		}		
		break;
		
		case contestStatus_HasNotStarted:
		case contestStatus_Error:
		{
			NSBeginAlertSheet(@" ", kCWX_String_UI_OKButtonString, nil, nil, mainWindow, nil, 
								nil, nil, nil, kCWX_String_UI_InternalError);
								
			[self setControllerStatus: CWX_ControllerStatus_WaitingToBeginTournament];
			return;
		}
		break;
			
		default:
		break;
	}

	[self updateDisplayUsingSimulatorCycleInfo];	

	if (finishedBattle)
	{
		[self updateMatchDataBoxProgramValues];

		if (++numMatchesPlayed >= BATTLES_PER_MATCH)
		{
			if (matchInfo[0].points > matchInfo[1].points)
			{
				[programs[0] incrementWins];
				[programs[1] incrementLosses];
			}
			else if (matchInfo[0].points < matchInfo[1].points)
			{
				[programs[0] incrementLosses];
				[programs[1] incrementWins];
			}
			else
			{
				[programs[0] incrementTies];
				[programs[1] incrementTies];
			}
		
			[tournamentTableView reloadData];
			[self resetMatchInfoBattleValues];

			if (++matchInfo[1].programArrayIndex >= numPrograms)
			{
				if (++matchInfo[0].programArrayIndex >= (numPrograms-1))
				{
					NSBeginAlertSheet(@" ", kCWX_String_UI_OKButtonString, nil, nil, mainWindow, 
								nil, nil, nil, nil, kCWX_String_UI_TournamentCompleteString);
										
					[self setControllerStatus: CWX_ControllerStatus_WaitingToBeginTournament];
					return;
				}
				
				matchInfo[1].programArrayIndex = matchInfo[0].programArrayIndex+1;
			}
			
			numMatchesPlayed = 0;
		}
		
		[self beginSimulatorWithCurrentMatchInfo];
	}
}

- (void) updateMemoryArrayViewWithInitialProgramState
{
	short addressForProgram0, addressForProgram1, endAddress, i;
	
	[simulator getStartingAddressForProgram0: &addressForProgram0 
									andProgram1: &addressForProgram1];
	
	endAddress = addressForProgram0 + [programs[0] numInstructions];	
	for (i = addressForProgram0; i < endAddress; i++)
	{
		[memoryArrayView setStatus: memoryCellStatus_Program0Instruction forCellAtAddress: i];
	}
	
	endAddress = addressForProgram1 + [programs[1] numInstructions];	
	for (i = addressForProgram1; i < endAddress; i++)
	{
		[memoryArrayView setStatus: memoryCellStatus_Program1Instruction forCellAtAddress: i];
	}
}

- (void) updateDisplayUsingSimulatorCycleInfo
{
	CWX_MemoryCellStatus cellStatus;
	
	[memoryArrayView resetHighlightsFromPreviousCycle];

	if (simulatorCycleInfo.processInfo[0].memoryCellWasWritten)
	{
		if (simulatorCycleInfo.processInfo[0].writtenCellContainsExecutableOpcode)
			cellStatus = memoryCellStatus_Program0Instruction;
		else
			cellStatus = memoryCellStatus_Program0Data;
			
		[memoryArrayView setStatus: cellStatus 
					forCellAtAddress: simulatorCycleInfo.processInfo[0].writeAddress];
	}

	if (simulatorCycleInfo.processInfo[1].memoryCellWasWritten)
	{
		if (simulatorCycleInfo.processInfo[1].writtenCellContainsExecutableOpcode)
			cellStatus = memoryCellStatus_Program1Instruction;
		else
			cellStatus = memoryCellStatus_Program1Data;
			
		[memoryArrayView setStatus: cellStatus 
					forCellAtAddress: simulatorCycleInfo.processInfo[1].writeAddress];
	}
	
	if (simulatorCycleInfo.processInfo[0].processDidDie
		|| simulatorCycleInfo.processInfo[1].processDidDie
		|| simulatorCycleInfo.processInfo[0].processWasSpawned
		|| simulatorCycleInfo.processInfo[1].processWasSpawned)
	{
		[simulator getProcessCountForProgram0: &matchInfo[0].numProcesses
								andProgram1: &matchInfo[1].numProcesses];
								
		[self updateMatchDataBoxProcessValues];
	}
	
	[memoryArrayView 
				highlightExecutionAddress: simulatorCycleInfo.processInfo[0].executionAddress
				forProgramNumber: 0
				processDied: simulatorCycleInfo.processInfo[0].processDidDie];

	[memoryArrayView 
				highlightExecutionAddress: simulatorCycleInfo.processInfo[1].executionAddress
				forProgramNumber: 1
				processDied: simulatorCycleInfo.processInfo[1].processDidDie];
}

- (int) numberOfRowsInTableView: (NSTableView *) aTableView
{
	return [programsArray count];
}

- (id) tableView: (NSTableView *) aTableView 
			objectValueForTableColumn: (NSTableColumn *) aTableColumn 
			row: (int) rowIndex
{
	id identifier;
	CWX_RedcodeProgram *program;
	
	identifier = [aTableColumn identifier];
	program = [programsArray objectAtIndex: rowIndex];
	
	if ([kTournamentTableColumnIdentifier_ProgramName isEqualToString: identifier])
		return [program name];
	else if ([kTournamentTableColumnIdentifier_TournamentPoints isEqualToString: identifier])
		return [NSString stringWithFormat: @"%d", [program points]];
	else if ([kTournamentTableColumnIdentifier_MatchesPlayed isEqualToString: identifier])
		return [NSString stringWithFormat: @"%d", [program matchesPlayed]];
	else if ([kTournamentTableColumnIdentifier_Wins isEqualToString: identifier])
		return [NSString stringWithFormat: @"%d", [program wins]];
	else if ([kTournamentTableColumnIdentifier_Losses isEqualToString: identifier])
		return [NSString stringWithFormat: @"%d", [program losses]];
	else if ([kTournamentTableColumnIdentifier_Ties isEqualToString: identifier])
		return [NSString stringWithFormat: @"%d", [program ties]];
	else
		return nil;
}

- (IBAction) doAbout: (id) sender
{
	previousControllerStatus = controllerStatus;

	if (controllerStatus >= CWX_ControllerStatus_TournamentRunning)
		[self setControllerStatus: CWX_ControllerStatus_TournamentPaused];

	NSBeginAlertSheet(kCWX_String_UI_AboutTitleString, kCWX_String_UI_OKButtonString, nil, 
						nil, mainWindow, self, 
						@selector(aboutSheetDidEnd:returnCode:contextInfo:), 
						nil, nil, kCWX_String_UI_AboutString);
}

- (void) aboutSheetDidEnd: (NSWindow *) sheet 
							returnCode: (int) returnCode 
							contextInfo: (void *) contextInfo
{
	[[NSApplication sharedApplication] endSheet: sheet];
	[sheet orderOut: self];
	
	if (controllerStatus != previousControllerStatus)
		[self setControllerStatus: previousControllerStatus];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void) windowDidResize: (NSNotification *) notification
{
	[mainWindow saveFrameUsingName: kMainWindowIdentifier];
}

- (void) windowDidMove: (NSNotification *) notification
{
	[mainWindow saveFrameUsingName: kMainWindowIdentifier];
}

@end
