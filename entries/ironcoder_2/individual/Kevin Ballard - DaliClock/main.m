//
//  main.m
//  DaliClock
//
//  Created by Kevin Ballard on 7/23/06.
//  Copyright Tildesoft 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	srandom((unsigned long)[NSDate timeIntervalSinceReferenceDate]);
    return NSApplicationMain(argc, (const char **) argv);
}
