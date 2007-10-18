//
//  CCPULoad.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 10/26/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CCPULoad.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach-o/arch.h>
#import <mach/mach.h>
#import <mach/mach_error.h>

float cpuload()
{
/*
int mib[2] = { CTL_HW, HW_NCPU };
unsigned long theCPUCount;
size_t theCPUCountLenth = sizeof(theCPUCount);
sysctl(mib, 2, &theCPUCount, &theCPUCountLenth, NULL, 0);
*/

natural_t processorCount;
processor_cpu_load_info_t	processorTickInfo;
mach_msg_type_number_t		processorMsgCount;

host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &processorCount,  (processor_info_array_t *)&processorTickInfo, &processorMsgCount);

int N;
for (N = 0; N < processorCount; N++)
	{
	unsigned long theUserState = processorTickInfo[N].cpu_ticks[CPU_STATE_USER];
	unsigned long theSystemState = processorTickInfo[N].cpu_ticks[CPU_STATE_SYSTEM];
	unsigned long theIdleState = processorTickInfo[N].cpu_ticks[CPU_STATE_IDLE];
	unsigned long theNiceState = processorTickInfo[N].cpu_ticks[CPU_STATE_NICE];
	unsigned long theTotalState = theUserState + theSystemState + theIdleState + theNiceState;
	NSLog(@"CPU LOADS: %d %d %d %d %d", theUserState, theSystemState, theIdleState, theNiceState, theTotalState);
	}

vm_deallocate(mach_task_self(), (vm_address_t)processorTickInfo, (vm_size_t)(processorMsgCount * sizeof(*processorTickInfo)));

return(0);
}