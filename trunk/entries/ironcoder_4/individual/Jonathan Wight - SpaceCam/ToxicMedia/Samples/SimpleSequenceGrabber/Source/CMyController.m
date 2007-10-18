//
//  CMyController.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/24/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CMyController.h"

#import "CSequenceGrabberWindowController.h"

@implementation CMyController

- (void)awakeFromNib
{
[[CSequenceGrabberWindowController alloc] init];

// Note: Uncomment this line to get a second cam window...
//[[CSequenceGrabberWindowController alloc] init];
}

- (IBAction)actionNewWindow:(id)inSender
{
[[CSequenceGrabberWindowController alloc] init];
}

@end
