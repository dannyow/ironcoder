//
//  CWX_Simulator.m
//  CoreWarX
//
//  Created by Josh Freeman on 11/11/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_Simulator.h"

#import "CWX_RedcodeExecuter.h"
#import "CWX_RedcodeProgram.h"

@interface CWX_Simulator (PrivateMethods)

- (bool) installProgram: (CWX_RedcodeProgram *) program
			asProgramNumber: (int) programNumber
			atMemoryAddress: (int) memoryAddress;

@end


@implementation CWX_Simulator

+ simulatorWithProgram0: (CWX_RedcodeProgram *) program0
			andProgram1: (CWX_RedcodeProgram *) program1
{
	return [[[self alloc] initWithProgram0: program0 andProgram1: program1] autorelease];
}
		   
- initWithProgram0: (CWX_RedcodeProgram *) program0
		andProgram1: (CWX_RedcodeProgram *) program1
{
	self = [super init];
	
	if (self)
	{
		srandom(time(0L));

		startingAddressForProgram0 = 0;
		startingAddressForProgram1 = SIMULATOR_MEMORY_ARRAY_SIZE/3 
										+ (random() % (SIMULATOR_MEMORY_ARRAY_SIZE/3));
	
		[self installProgram: program0
				asProgramNumber: 0
				atMemoryAddress: startingAddressForProgram0];
				
		[self installProgram: program1
				asProgramNumber: 1
				atMemoryAddress: startingAddressForProgram1];
				
		contestStatus = contestStatus_Running;
	}
	
	return self;
}

- init
{
	return [self initWithProgram0: nil andProgram1: nil];
}

- (void) dealloc
{
	[super dealloc];
}

- (bool) installProgram: (CWX_RedcodeProgram *) program
			asProgramNumber: (int) programNumber
			atMemoryAddress: (int) memoryAddress
{
	int numInstructions;
	
	if (!program || ((programNumber != 0) && (programNumber != 1)))
		goto ERROR;
		
	numInstructions = [program numInstructions];
	
	if ((memoryAddress < 0) 
			|| (memoryAddress >= (SIMULATOR_MEMORY_ARRAY_SIZE - numInstructions)))
		goto ERROR;

	memcpy(&memoryArray[memoryAddress], [program instructionsArray], 
			numInstructions * sizeof(Redcode_MemoryCell));
			
	programProcessQueues[programNumber].processAddresses[0] = 
										memoryAddress + [program firstExecutableInstruction];
	programProcessQueues[programNumber].currentProcess = 0;
	programProcessQueues[programNumber].numProcesses = 1;
	programProcessQueues[programNumber].initialized = YES;
	
	return YES;
			
ERROR:
	return NO;
}
		
- (CWX_ContestStatus) executeOneCycleWithReturnedInfo: 
												(CWX_SimulatorCycleInfo *) returnedCycleInfo
{
	if (!returnedCycleInfo || (contestStatus != contestStatus_Running))
		goto END;
	
	if (![self executeOneInstructionForProcessQueue: &programProcessQueues[0]
							returnedProcessInfo: &returnedCycleInfo->processInfo[0]]
		|| ![self executeOneInstructionForProcessQueue: &programProcessQueues[1]
							returnedProcessInfo: &returnedCycleInfo->processInfo[1]])
	{
		contestStatus = contestStatus_Error;
		goto END;
	}

	cycleCount++;
	
	if (programProcessQueues[0].numProcesses)
	{
		if (programProcessQueues[1].numProcesses)
		{
			if (cycleCount >= SIMULATOR_MAX_ALLOWED_CYCLES)
				contestStatus = contestStatus_Draw;
		}
		else
		{
			contestStatus = contestStatus_WonByProgram0;
		}
	}
	else 
	{
		if (programProcessQueues[1].numProcesses)
		{
			contestStatus = contestStatus_WonByProgram1;
		}
		else
		{
			contestStatus = contestStatus_Draw;
		}
	}

END:	 
	return contestStatus;
}

- (CWX_ContestStatus) contestStatus
{
	return contestStatus;
}

- (int) cycleCount
{
	return cycleCount;
}

- (void) getStartingAddressForProgram0: (short *) returnedAddressProgram0
							andProgram1: (short *) returnedAddressProgram1
{
	if (returnedAddressProgram0)
		*returnedAddressProgram0 = startingAddressForProgram0;
		
	if (returnedAddressProgram1)
		*returnedAddressProgram1 = startingAddressForProgram1;
}

- (void) getProcessCountForProgram0: (short *) returnedProcessCount0
						andProgram1: (short *) returnedProcessCount1
{
	if (returnedProcessCount0)
		*returnedProcessCount0 = programProcessQueues[0].numProcesses;

	if (returnedProcessCount1)
		*returnedProcessCount1 = programProcessQueues[1].numProcesses;
}

@end
