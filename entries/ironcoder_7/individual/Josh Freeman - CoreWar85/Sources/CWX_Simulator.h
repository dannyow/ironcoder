//
//  CWX_Simulator.h
//  CoreWarX
//
//  Created by Josh Freeman on 11/11/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CWX_Defines.h"
#import "CWX_Redcode_Defines.h"

typedef struct
{
	int processAddresses[SIMULATOR_MAX_NUM_PROCESSES];
	int currentProcess;
	int numProcesses;
	bool initialized;
	bool _unusedAlign[3];
	
} CWX_ProcessQueue;

typedef struct
{
	short opcode;
	short executionAddress;
	short writeAddress;
	short numAddressesRead;
	short readAddresses[4];
	bool memoryCellWasWritten;
	bool writtenCellContainsExecutableOpcode;
	bool processDidDie;
	bool processWasSpawned;
	
} CWX_SimulatorProcessInfo;

typedef struct
{
	CWX_SimulatorProcessInfo processInfo[2];
	
} CWX_SimulatorCycleInfo;


typedef enum
{
	contestStatus_HasNotStarted = 0,
	contestStatus_Running,
	contestStatus_WonByProgram0,
	contestStatus_WonByProgram1,
	contestStatus_Draw,
	contestStatus_Error

} CWX_ContestStatus;


@class CWX_RedcodeProgram;

@interface CWX_Simulator : NSObject 
{
	Redcode_MemoryCell memoryArray[SIMULATOR_MEMORY_ARRAY_SIZE 
									+ SIMULATOR_NUM_IMMEDIATE_MODE_REGISTERS];
									
	CWX_ProcessQueue programProcessQueues[2];
	long cycleCount;
	CWX_ContestStatus contestStatus;
	int startingAddressForProgram0;
	int startingAddressForProgram1;
}

+ simulatorWithProgram0: (CWX_RedcodeProgram *) program0
			andProgram1: (CWX_RedcodeProgram *) program1;
		   
- initWithProgram0: (CWX_RedcodeProgram *) program0
		andProgram1: (CWX_RedcodeProgram *) program1;
		
- (CWX_ContestStatus) executeOneCycleWithReturnedInfo: 
												(CWX_SimulatorCycleInfo *) returnedCycleInfo;

- (CWX_ContestStatus) contestStatus;
- (int) cycleCount;
- (void) getStartingAddressForProgram0: (short *) returnedAddressProgram0
							andProgram1: (short *) returnedAddressProgram1;
							
- (void) getProcessCountForProgram0: (short *) returnedProcessCount0
						andProgram1: (short *) returnedProcessCount1;

@end
