//
//  CWX_RedcodeExecuter.m
//  CoreWarX
//
//  Created by Josh Freeman on 11/12/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_RedcodeExecuter.h"


#define kDummyArgumentValue			0xBAADBEEF

static inline short BoundedValueForMemoryAddress(short value)
{
	if (value >= 0)
		return value % SIMULATOR_MEMORY_ARRAY_SIZE;
	else
		return (value % SIMULATOR_MEMORY_ARRAY_SIZE) + SIMULATOR_MEMORY_ARRAY_SIZE;
}

@implementation CWX_Simulator (RedcodeExecuter)

- (bool) executeOneInstructionForProcessQueue: (CWX_ProcessQueue *) processQueue
						returnedProcessInfo: (CWX_SimulatorProcessInfo *) returnedProcessInfo
{
	int executionAddress, directAddressA, indirectAddressA, directAddressB, indirectAddressB;
	int argumentA, argumentB, nextExecutionAddress;
	bool processHadError = NO, argumentBWasWrittenTo = NO, argumentAWasReadFrom = YES;
	bool processWasSpawned = NO;
	Redcode_MemoryCell *executingCell;
	
	if (!processQueue || (processQueue->numProcesses <= 0))
		return NO;
		
	executionAddress = processQueue->processAddresses[processQueue->currentProcess];
	executingCell = &memoryArray[executionAddress];
	
	switch (executingCell->addressModeA)
	{
		case Redcode_AddressMode_Immediate:
		{
			// things are simpler if we pass arguments in direct mode, so this is 
			// done by stashing the immediate mode value in an unused cell at the
			// end of memory, then setting the argument to point to it so the 
			// executer can treat it as direct mode
			argumentA = SIMULATOR_IMMEDIATE_MODE_REGISTER_A_ADDRESS;
			memoryArray[argumentA].argumentB = executingCell->argumentA;
			directAddressA = indirectAddressA = -1;
		}
		break;
		
		case Redcode_AddressMode_Direct:
		{
			argumentA = directAddressA = 
					BoundedValueForMemoryAddress(executionAddress + executingCell->argumentA);
				
			indirectAddressA = -1;
		}
		break;
		
		case Redcode_AddressMode_Indirect:
		{
			indirectAddressA = 
					BoundedValueForMemoryAddress(executionAddress + executingCell->argumentA);
			
			// dereference the indirect address so we can pass the argument in direct mode
			argumentA = directAddressA = 
					BoundedValueForMemoryAddress(indirectAddressA 
												+ memoryArray[indirectAddressA].argumentB);
		}
		break;
	}
	
	switch (executingCell->addressModeB)
	{
		case Redcode_AddressMode_Immediate:
		{
			// things are simpler if we pass arguments in direct mode, so this is 
			// done by stashing the immediate mode value in an unused cell at the
			// end of memory, then setting the argument to point to it so the 
			// executer can treat it as direct mode
			argumentB = SIMULATOR_IMMEDIATE_MODE_REGISTER_B_ADDRESS;
			memoryArray[argumentB].argumentB = executingCell->argumentB;
			directAddressB = indirectAddressB = -1;
		}
		break;
		
		case Redcode_AddressMode_Direct:
		{
			argumentB = directAddressB = 
					BoundedValueForMemoryAddress(executionAddress + executingCell->argumentB);
				
			indirectAddressB = -1;
		}
		break;
		
		case Redcode_AddressMode_Indirect:
		{
			indirectAddressB = 
					BoundedValueForMemoryAddress(executionAddress + executingCell->argumentB);
			
			// dereference the indirect address so we can pass the argument in direct mode
			argumentB = directAddressB = 
					BoundedValueForMemoryAddress(indirectAddressB 
													+ memoryArray[indirectAddressB].argumentB); 
		}
		break;
	}
	
	switch (executingCell->opcode)
	{
		case Redcode_Opcode_DAT:
		{
			processHadError = YES;
			
			if (--processQueue->numProcesses)
			{
				if (processQueue->currentProcess < processQueue->numProcesses)
				{
					memmove(&processQueue->processAddresses[processQueue->currentProcess],
							&processQueue->processAddresses[processQueue->currentProcess+1],
							(processQueue->numProcesses - processQueue->currentProcess)
								* sizeof (int));
				}
				else
				{
					processQueue->currentProcess = 0;
				}
			}
			
			argumentAWasReadFrom = NO;
		}
		break;
		
		case Redcode_Opcode_MOV:
		{
			memmove(&memoryArray[argumentB], &memoryArray[argumentA],
					sizeof(Redcode_MemoryCell));
					
			argumentBWasWrittenTo = YES;
			nextExecutionAddress = executionAddress+1;
		}
		break;
		
		case Redcode_Opcode_ADD:
		{
			memoryArray[argumentB].argumentB += memoryArray[argumentA].argumentB;

			argumentBWasWrittenTo = YES;
			nextExecutionAddress = executionAddress+1;		
		}
		break;
		
		case Redcode_Opcode_SUB:
		{
			memoryArray[argumentB].argumentB -= memoryArray[argumentA].argumentB;

			argumentBWasWrittenTo = YES;
			nextExecutionAddress = executionAddress+1;		
		}
		break;
		
		case Redcode_Opcode_JMP:
		{
			argumentAWasReadFrom = NO;
			
			nextExecutionAddress = argumentA;
		}
		break;
		
		case Redcode_Opcode_JMZ:
		{
			argumentAWasReadFrom = NO;

			if (!memoryArray[argumentB].argumentB)
				nextExecutionAddress = argumentA;
		}
		break;
		
		case Redcode_Opcode_JMG:
		{
			argumentAWasReadFrom = NO;

			if (memoryArray[argumentB].argumentB > 0)
				nextExecutionAddress = argumentA;
		}
		break;
		
		case Redcode_Opcode_DJZ:
		{
			argumentAWasReadFrom = NO;

			if (!--memoryArray[argumentB].argumentB)
				nextExecutionAddress = argumentA;
		}
		break;
		
		case Redcode_Opcode_CMP:
		{
			nextExecutionAddress = executionAddress+1;
		
			if (memcmp(&memoryArray[argumentA], &memoryArray[argumentB],
						sizeof(Redcode_MemoryCell)) != 0)
			{
				nextExecutionAddress++;
			}
		}
		break;
		
		case Redcode_Opcode_SPL:
		{
			argumentAWasReadFrom = NO;

			if (processQueue->numProcesses < SIMULATOR_MAX_NUM_PROCESSES)
			{
				memmove(&processQueue->processAddresses[processQueue->currentProcess+1],
						&processQueue->processAddresses[processQueue->currentProcess],
						(processQueue->numProcesses - processQueue->currentProcess)
							* sizeof (int));
				
				processQueue->processAddresses[processQueue->currentProcess] = argumentA;
				processQueue->currentProcess++;
				nextExecutionAddress = executionAddress+1;
				processQueue->numProcesses++;
				processWasSpawned = YES;
			}
		}
	}
	
	if (!processHadError)
	{
		processQueue->processAddresses[processQueue->currentProcess] = 
										BoundedValueForMemoryAddress(nextExecutionAddress);
				
		processQueue->currentProcess = 
							(processQueue->currentProcess + 1) % processQueue->numProcesses;
	}

	if (returnedProcessInfo)
	{
		short numAddressesRead = 0;
	
		returnedProcessInfo->opcode = executingCell->opcode;
		returnedProcessInfo->executionAddress = executionAddress;
		
		if (argumentAWasReadFrom && (directAddressA != -1))
			returnedProcessInfo->readAddresses[numAddressesRead++] = directAddressA;

		if (indirectAddressA != -1)
			returnedProcessInfo->readAddresses[numAddressesRead++] = indirectAddressA;
			
		if (argumentBWasWrittenTo)
		{
			returnedProcessInfo->writeAddress = directAddressB;
			returnedProcessInfo->memoryCellWasWritten = YES;
			returnedProcessInfo->writtenCellContainsExecutableOpcode = 
						(memoryArray[directAddressB].opcode != Redcode_Opcode_DAT) ? YES : NO;
		}
		else
		{
			returnedProcessInfo->writeAddress = -1;
			returnedProcessInfo->memoryCellWasWritten = NO;
			returnedProcessInfo->writtenCellContainsExecutableOpcode = NO;
		
			if (directAddressB != -1)
				returnedProcessInfo->readAddresses[numAddressesRead++] = directAddressB;
		}
		
		if (indirectAddressB != -1)
			returnedProcessInfo->readAddresses[numAddressesRead++] = indirectAddressB;
			
		returnedProcessInfo->numAddressesRead = numAddressesRead;
		returnedProcessInfo->processDidDie = processHadError;
		returnedProcessInfo->processWasSpawned = processWasSpawned;
	}
	
	return YES;
}

@end
