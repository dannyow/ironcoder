//
//  CWX_Controller.h
//  CoreWarX
//
//  Created by Josh Freeman on 11/13/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CWX_Simulator.h"

typedef enum
{
	CWX_ControllerStatus_WaitingForUserToLoadPrograms = 0,
	CWX_ControllerStatus_WaitingToBeginTournament,
	CWX_ControllerStatus_TournamentRunning,
	CWX_ControllerStatus_TournamentPaused

} CWX_ControllerStatus;

typedef enum
{
	ControllerDelayedAction_LoadPrograms,
	ControllerDelayedAction_RemovePrograms,
	ControllerDelayedAction_ResetTournament

} CWX_ControllerDelayedAction;

typedef struct
{
	short programArrayIndex;
	short points;
	short wins;
	short losses;
	short ties;
	short numProcesses;
	
} CWX_MatchInfo;

@class CWX_MemoryArrayView;

@interface CWX_Controller : NSObject
{
	IBOutlet NSWindow *mainWindow;
	IBOutlet CWX_MemoryArrayView *memoryArrayView;
	IBOutlet NSBox *matchDataBox;
	
	IBOutlet NSTextField *program0NameTextField;
	IBOutlet NSTextField *program0PointsTextField;
	IBOutlet NSTextField *program0WinsTextField;
	IBOutlet NSTextField *program0LossesTextField;
	IBOutlet NSTextField *program0TiesTextField;
	IBOutlet NSTextField *program0ProcessesTextField;
	
	IBOutlet NSTextField *program1NameTextField;
	IBOutlet NSTextField *program1PointsTextField;
	IBOutlet NSTextField *program1WinsTextField;
	IBOutlet NSTextField *program1LossesTextField;
	IBOutlet NSTextField *program1TiesTextField;
	IBOutlet NSTextField *program1ProcessesTextField;

	IBOutlet NSTableView *tournamentTableView;

	IBOutlet NSButton *resetTournamentButton;
	IBOutlet NSButton *beginPauseContinueTournamentButton;
	
	CWX_ControllerStatus controllerStatus;

	CWX_Simulator *simulator;
	CWX_SimulatorCycleInfo simulatorCycleInfo;
	NSTimer *cycleTimer;

	NSMutableArray *programsArray;
	short numPrograms;
	
	CWX_RedcodeProgram *programs[2];
	CWX_MatchInfo matchInfo[2];
	short numMatchesPlayed;
	
	NSString *fileDirectoryPath;
	NSArray *allowedFileTypesArray;
	
	CWX_ControllerDelayedAction delayedAction;
	CWX_ControllerStatus previousControllerStatus;
}

- (IBAction) loadProgramsButtonPressed: (id) sender;
- (IBAction) removeProgramsButtonPressed: (id) sender;
- (IBAction) resetTournamentButtonPressed: (id) sender;
- (IBAction) beginPauseContinueTournmentButtonPressed: (id) sender;
- (IBAction) doAbout: (id) sender;

@end
