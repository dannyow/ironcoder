//
//  CFallingSandController.m
//  FallingSand
//
//  Created by Jonathan Wight on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CFallingSandController.h"

#import "CFallingSandWindowController.h"

@implementation CFallingSandController

- (void)applicationDidFinishLaunching:(NSNotification *)inNotification
{
#pragma unused (inNotification)
[[CFallingSandWindowController instance] showWindow:self];
}

@end
