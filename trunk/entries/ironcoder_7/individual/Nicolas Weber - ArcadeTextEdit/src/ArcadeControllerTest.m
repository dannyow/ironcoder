//
//  ArcadeControllerTest.m
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ArcadeControllerTest.h"


@implementation ArcadeControllerTest

- (void)setUp
{
    controller = [[ArcadeController alloc] init];
}

- (void)tearDown
{
    [controller release];
}

- (void)testWordsInRangeForString
{
    NSArray *array = [controller wordsInRange:NSMakeRange(5, 1)
        forString:@"I like Cocoa"];

    // STAssertEquals(1, [array count], @"");
    
}

@end
