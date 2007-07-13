//
//  MyController.m
//  TopQuartz
//
//  Created by Chip Coons on 7/21/06.
//  Copyright 2006 GWSoftware. All rights reserved.
//

#import "MyController.h"
#import "Storage.h"
#import "TopQuartzView.h"


@implementation MyController

- (id)init;
{
	if(![super init])
		return nil;
	
	myContainer = [[[Storage alloc] init] retain];

	
	return self;
}

- (void)dealloc;
{
	[renderTimer invalidate];
	[renderTimer release];
	[myContainer release];
	[super dealloc];
}



- (void)applicationDidFinishLaunching:(NSNotification*)notification;
{
	
	/*
	NSFont *myFont = [NSFont fontWithName:@"Courier New" size:12.0];
	[textview setFont:myFont];
	*/
	
    NSTask *ls=[[NSTask alloc] init];
    NSPipe *pipe=[[NSPipe alloc] init];
    NSFileHandle *handle;
    
    [ls setLaunchPath:@"/usr/bin/top"];
    [ls setArguments:[NSArray arrayWithObjects:@"-F",@"-l", @"0", @"-o", @"cpu", @"-R",@"-n", @"10" ,nil]];
    [ls setStandardOutput:pipe];
    handle=[pipe fileHandleForReading];
	
    [ls launch];
    
    [NSThread detachNewThreadSelector:@selector(copyData:)
							 toTarget:self withObject:handle];
    [pipe release];
    [ls release];
	
	renderTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 
                                                    target:self
                                                  selector:@selector(update)
                                                  userInfo:NULL repeats:YES]
		retain];
	 
}

- (void)update;
{
	NSArray *sortedArray = [myContainer sortedKeysUsing:@"currentCPU"];
	[graphicsView updateData:sortedArray];
	[graphicsView setNeedsDisplay:YES];
	[myContainer checkStaleEntries];
	
}


- (void)copyData:(NSFileHandle*)handle;
{
	
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    NSData *data;
	NSRange listRange;
	
	listRange.length = 10;
	
    while([data=[handle availableData] length]) { // until EOF (check reference)
			NSString *string=[[NSString alloc] initWithData:data
											   encoding:NSASCIIStringEncoding];
			
			NSArray *master = [string componentsSeparatedByString:@"\n"];
			listRange.location = [master count] - 11;
			NSArray *list = [master subarrayWithRange:listRange];
			//NSLog(@"array count = %d", [master count]);
			[myContainer parseToStorage:list];
			string = [list componentsJoinedByString:@"\n"];
			
			/*
			NSRange theEnd=NSMakeRange(0,[[textview string] length]);
			[textview replaceCharactersInRange:theEnd
									withString:string]; // append new string to the end
			*/
			
			[list release];
			[master release];
			[string release];
		
    }
	
	
    [pool release];
	
}




@end
