//
//  NSApplication+Applescript.m
//  Usage
//
//  Created by Grayson Hansard on 7/22/06.
//  Copyright 2006 From Concentrate Software. All rights reserved.
//

#import "NSApplication+Applescript.h"


@implementation NSApplication (Applescript)

-(NSArray *)processes { return [[self delegate] processes]; }

@end
