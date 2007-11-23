//
//  CWX_RedcodeAssembler.h
//  CoreWarX
//
//  Created by Josh Freeman on 11/12/07.
//  Copyright 2007 Twilight Edge Software. All rights reserved.
//

#import "CWX_RedcodeProgram.h"

@interface CWX_RedcodeProgram (RedcodeAssembler)

- (bool) assembleRedcode: (NSString *) redcodeText
			returnedError: (NSString **) returnedErrorString;

@end
