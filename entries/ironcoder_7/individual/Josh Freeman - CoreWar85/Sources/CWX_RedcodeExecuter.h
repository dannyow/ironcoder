//
//  CWX_RedcodeExecuter.h
//  CoreWarX
//
//  Created by Josh Freeman on 11/12/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_Simulator.h"

@interface CWX_Simulator (RedcodeExecuter)

- (bool) executeOneInstructionForProcessQueue: (CWX_ProcessQueue *) processQueue
						returnedProcessInfo: (CWX_SimulatorProcessInfo *) returnedProcessInfo;

@end
