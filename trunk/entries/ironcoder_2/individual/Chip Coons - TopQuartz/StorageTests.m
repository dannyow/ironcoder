//
//  StorageTests.m
//  TopQuartz
//
//  Created by Chip Coons on 7/22/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import "StorageTests.h"


@implementation StorageTests
- (void)setUp;
{
	testStorage = [[[Storage alloc] init] retain];
}

- (void)tearDown;
{
	[testStorage release];
}

- (void)testCase_initialization;
{
	STAssertNotNil(testStorage, @"testStorage is nil after initialization using [[Storage alloc] init]");
	STAssertTrue ([[testStorage masterList] isKindOfClass:[NSMutableDictionary class]], @"[testStorage MasterList] is not NSMutableDIctionary");
	
}

- (void)testCase_burstString;
{
	NSString *testInput;
	NSArray *output;
	
	testInput = [NSString stringWithString:@"  956 Newtime      0.0% 10:17.27   1    67   112  1.30M  6.60M  4.16M   145M"];
	output= [testStorage burstEntry:testInput];
	STAssertTrue([output count]==11, @"[testCase burstEntry:] has incorrect count of elements for TOP line");
	STAssertTrue([[testStorage pidForEntry:output] isEqualToString:@"956"], @"[testStorage pidForEntry:output] is incorrect for test PID= 956");
	STAssertTrue([[testStorage nameForEntry:output] isEqualToString:@"Newtime"], @"[testStorage nameForEntry:output] is incorrect for test name = Newtime");
	STAssertTrue([[testStorage cpuForEntry:output] floatValue]==0.0, @"[testStorage cpuForEntry:output] is incorrect for test cpu = 0.0");
	STAssertTrue([[testStorage cpuTimeForEntry:output] isEqualToString:@"10:17.27"], @"[testStorage cpuTimeForEntry:output] is incorrect for test time = 10:17.27");
	
	testInput = [NSString stringWithString:@" 1588 top          37.9%  0:00.07   1    17    20   268K   496K   676K  26.9M"];
	output= [testStorage burstEntry:testInput];
	STAssertTrue([output count]==11, @"[testCase burstEntry:] has incorrect count of elements for TOP line");
	
}

- (void)testCase_buildMaster;
{

	NSArray *masterInput = [[NSArray arrayWithObjects: [NSString stringWithString:@"  956 Newtime     32.6% 86:34.12   1    67   112  1.32M  6.66M  4.25M   145M"],
		[NSString stringWithString:@" 2767 mdimport     0.0%  0:14.79   4    63    73  2.28M  10.2M  3.50M  42.3M"],
		[NSString stringWithString:@"  271 Safari       0.0%  1:38.38   7   150   520  43.4M  43.0M  66.7M   245M"],
		[NSString stringWithString:@"  926 VoodooPad    0.0%  0:15.63   4   111   284  10.7M  21.7M- 26.9M-  170M"],
		[NSString stringWithString:@"  488 Xcode        0.0%  9:46.40   9   148  1064  22.2M  46.4M  49.7M   214M"],
		[NSString stringWithString:@"  666 Terminal     4.2%  0:16.15   5   162   171  2.73M  17.7M  7.63M   156M"],
		[NSString stringWithString:@"  669 bash         0.0%  0:00.04   1    14    17   208K   980K   824K  27.2M"],
		[NSString stringWithString:@" 1241 Accessoriz   0.0%  0:04.35   4   112   189  4.58M  21.4M  25.4M   159M"],
		[NSString stringWithString:@" 1782 Sherlock     0.0%  0:11.62  12   156   252  11.4M  16.1M- 34.7M   175M"],
		[NSString stringWithString:@"  980 Interface    0.0%  0:05.79   2    96   221  5.84M  21.6M  13.9M   162M"],
		nil] retain];
	
	[testStorage parseToStorage:masterInput];
	
	STAssertTrue([[testStorage masterList] count]==10, @"[[testStorage masterList] count] incorrect after calling [testStorage parseToStorage:masterInput]");
	
	[masterInput release];
	
	masterInput = [[NSArray arrayWithObjects: [NSString stringWithString:@"  956 Newtime     27.6% 86:34.12   1    67   112  1.32M  6.66M  4.25M   145M"],
		[NSString stringWithString:@" 2767 mdimport     0.7%  0:14.79   4    63    73  2.28M  10.2M  3.50M  42.3M"],
		[NSString stringWithString:@"  271 Safari       0.0%  1:38.38   7   150   520  43.4M  43.0M  66.7M   245M"],
		[NSString stringWithString:@"  926 VoodooPad    1.5%  0:15.63   4   111   284  10.7M  21.7M- 26.9M-  170M"],
		[NSString stringWithString:@"  488 Xcode       21.0%  9:46.40   9   148  1064  22.2M  46.4M  49.7M   214M"],
		[NSString stringWithString:@"  666 Terminal     4.2%  0:16.15   5   162   171  2.73M  17.7M  7.63M   156M"],
		[NSString stringWithString:@"  669 bash         0.4%  0:00.04   1    14    17   208K   980K   824K  27.2M"],
		[NSString stringWithString:@" 1241 Accessoriz   0.0%  0:04.35   4   112   189  4.58M  21.4M  25.4M   159M"],
		[NSString stringWithString:@" 1782 Sherlock     1.8%  0:11.62  12   156   252  11.4M  16.1M- 34.7M   175M"],
		[NSString stringWithString:@"  980 Interface    0.0%  0:05.79   2    96   221  5.84M  21.6M  13.9M   162M"],
		nil] retain];
	
	[testStorage parseToStorage:masterInput];
	
	STAssertTrue([[testStorage masterList] count]==10, @"[[testStorage masterList] count] incorrect after calling [testStorage parseToStorage:masterInput]");
	
	NSLog(@" %@ ", [[testStorage masterList] description]);
	
	[masterInput release];
}

- (void)testCase_sortedMaster;
{
	
	NSArray *masterInput = [[NSArray arrayWithObjects: [NSString stringWithString:@"  956 Newtime     32.6% 86:34.12   1    67   112  1.32M  6.66M  4.25M   145M"],
		[NSString stringWithString:@" 2767 mdimport     0.0%  0:14.79   4    63    73  2.28M  10.2M  3.50M  42.3M"],
		[NSString stringWithString:@"  271 Safari       0.0%  1:38.38   7   150   520  43.4M  43.0M  66.7M   245M"],
		[NSString stringWithString:@"  926 VoodooPad    0.0%  0:15.63   4   111   284  10.7M  21.7M- 26.9M-  170M"],
		[NSString stringWithString:@"  488 Xcode        0.0%  9:46.40   9   148  1064  22.2M  46.4M  49.7M   214M"],
		[NSString stringWithString:@"  666 Terminal     4.2%  0:16.15   5   162   171  2.73M  17.7M  7.63M   156M"],
		[NSString stringWithString:@"  669 bash         0.0%  0:00.04   1    14    17   208K   980K   824K  27.2M"],
		[NSString stringWithString:@" 1241 Accessoriz   0.0%  0:04.35   4   112   189  4.58M  21.4M  25.4M   159M"],
		[NSString stringWithString:@" 1782 Sherlock     0.0%  0:11.62  12   156   252  11.4M  16.1M- 34.7M   175M"],
		[NSString stringWithString:@"  980 Interface    0.0%  0:05.79   2    96   221  5.84M  21.6M  13.9M   162M"],
		nil] retain];
	
	[testStorage parseToStorage:masterInput];
	[masterInput release];
	
	masterInput = [[NSArray arrayWithObjects: [NSString stringWithString:@"  956 Newtime     27.6% 86:34.12   1    67   112  1.32M  6.66M  4.25M   145M"],
		[NSString stringWithString:@" 2767 mdimport     0.7%  0:14.79   4    63    73  2.28M  10.2M  3.50M  42.3M"],
		[NSString stringWithString:@"  271 Safari       0.0%  1:38.38   7   150   520  43.4M  43.0M  66.7M   245M"],
		[NSString stringWithString:@"  926 VoodooPad    1.5%  0:15.63   4   111   284  10.7M  21.7M- 26.9M-  170M"],
		[NSString stringWithString:@"  488 Xcode       21.0%  9:46.40   9   148  1064  22.2M  46.4M  49.7M   214M"],
		[NSString stringWithString:@"  666 Terminal     4.2%  0:16.15   5   162   171  2.73M  17.7M  7.63M   156M"],
		[NSString stringWithString:@"  669 bash         0.4%  0:00.04   1    14    17   208K   980K   824K  27.2M"],
		[NSString stringWithString:@" 1241 Accessoriz   0.0%  0:04.35   4   112   189  4.58M  21.4M  25.4M   159M"],
		[NSString stringWithString:@" 1782 Sherlock     1.8%  0:11.62  12   156   252  11.4M  16.1M- 34.7M   175M"],
		[NSString stringWithString:@"  980 Interface    0.0%  0:05.79   2    96   221  5.84M  21.6M  13.9M   162M"],
		nil] retain];
	
	[testStorage parseToStorage:masterInput];
	
	NSArray *sortedKeys = [testStorage sortedKeysUsing:@"currentCPU"];
	NSLog(@"\n\n%@\n", [sortedKeys description]);
	STAssertTrue([[[sortedKeys objectAtIndex:0] objectForKey:@"process"] isEqualToString:@"Newtime"], @"[testStorage sortedKeysUsing:@currentCPU] failed");
}

@end
