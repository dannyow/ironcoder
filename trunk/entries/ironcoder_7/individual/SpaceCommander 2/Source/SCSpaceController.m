//
//  SCWindowCreator.m
//  SpaceCommander
//
//  Created by Zac White on 11/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SCSpaceController.h"

#import "SCWindowInfo.h"

#define WINDOW_WIDTH 75

#define max(a,b) a>b?a:b

@implementation SCSpaceController

static id instance = nil;
+ (SCSpaceController *)instance
{
    if (!instance) instance = [[SCSpaceController alloc] init];
    return instance;
}

- (id)init
{
    if(self = [super init]) instance = self;
	
	cols = 3;
	rows = 2;
	current = -1;
//	int i;
//	for(i = 1; i <= 6; i++){
//		NSLog(@"workspace: %d, row:%f col:%f", i, [self positionForWorkspace:i].x, [self positionForWorkspace:i].y);
//	}
	
	showWindows = YES;
	
    return self;
}

- (NSDictionary *)getCurrentSpaceInfo{	
	NSAppleScript *rowScript = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"\n\
		tell expose preferences\n\
			tell spaces preferences\n\
				spaces rows\n\
			end tell\n\
		end tell\n\
	end tell"];
	NSAppleEventDescriptor *desc = [rowScript executeAndReturnError:NULL];
	int numRow = [desc int32Value];
	
	NSLog(@"row: %d", numRow);
	
	NSAppleScript *colScript = [[NSAppleScript alloc] initWithSource:@"tell application \"System Events\"\n\
		tell expose preferences\n\
			tell spaces preferences\n\
				spaces columns\n\
			end tell\n\
		end tell\n\
	end tell"];
	desc = [colScript executeAndReturnError:NULL];
	int numCol = [desc int32Value];

	
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],
													  @"currentSpace",
													  [NSNumber numberWithInt:numCol],
													  @"columns",
											          [NSNumber numberWithInt:numRow],
													  @"rows", nil];
}

//- (id)initWithColumnCount:(int)col rowCount:(int)row currentSpace:(int)currentSpace{
//	if(!(self = [super init])) return nil;
//	
//	cols = col;
//	rows = row;
//	current = currentSpace;
//	
//	showWindows = YES;
//	
//	return self;
//}

- (void)setColumns:(int)columns{
	cols = columns;
}

- (void)setRows:(int)rowCount{
	rows = rowCount;
}

- (void)setCurrentSpace:(int)currentSpace{
	current = currentSpace;
}

- (void)showBezelForWindowList{

	NSArray *windowList = [self getWindowList];
	if(current == -1 || rows == 0 || cols == 0){
		NSDictionary *dict = [self getCurrentSpaceInfo];
		rows = [[dict objectForKey:@"rows"] intValue];
		cols = [[dict objectForKey:@"columns"] intValue];
		current = [[windowList objectAtIndex:0] workspace];
	}
	showWindows = YES;
	
	//find positions based on the position in the space and the space.
	
	//turn that into positions on the edge of the screen.
	
	//get the application icon for each application.
	
	//create windows with layer backing to show the app icon and an arrow.
	
	NSLog(@"count: %d", [windowList count]);
	SCWindowInfo *item;
	
	for(NSWindow *window in windows){
		NSLog(@"window:%@", window);
		if(window) [window orderOut:self];
	}
	
	[windows release];
	windows = [[NSMutableArray alloc] init];
	
	SCWindow *tempWindow;
	for(item in windowList){
		if([item workspace] == current) continue;
		
		tempWindow = [self bezelForWindowFrame:[item bounds] inWorkspace:[item workspace] withApplicationPath:[item owningApplicationPath]];
		
		[windows addObject:[tempWindow retain]];
		[tempWindow orderFront:self];
		[[tempWindow animator] setAlphaValue:1];
		[tempWindow release];
	}
}

- (SCWindow *)bezelForWindowFrame:(CGRect)frame inWorkspace:(int)workspace withApplicationPath:(NSString *)path{
	//bam, math.
	if(current == -1) return nil;
	
	NSPoint edgePoint = NSZeroPoint;
	
	NSPoint workspacePosition = [self positionForWorkspace:workspace];
	NSPoint currentPosition = [self positionForWorkspace:current];
	
	NSRect screenRect = [[NSScreen mainScreen] frame];
		
	//if(workspacePosition.x < currentPosition.x) edgePoint.x = 0;
	//else edgePoint.x = screenRect.size.width - WINDOW_WIDTH;
	
	NSPoint currentCoordinate = NSMakePoint(currentPosition.x-1 * screenRect.size.width + screenRect.size.width/2, currentPosition.y-1 * screenRect.size.height + screenRect.size.height/2);	
	NSPoint bigFrameCoordinate = NSMakePoint(workspacePosition.x * screenRect.size.width + frame.size.width/2, workspacePosition.y * screenRect.size.height + frame.size.height/2);
	
	NSLog(@"current: %f, %f", currentCoordinate.x, currentCoordinate.y);
	NSLog(@"bigFrame: %f, %f", bigFrameCoordinate.x, bigFrameCoordinate.y);
	
	//find the angle between them.
	double diffX = 0;
	double diffY = 0;
	
	diffX = bigFrameCoordinate.x - currentCoordinate.x;
	diffY = bigFrameCoordinate.y - currentCoordinate.y;
	
	NSLog(@"diffx: %f diffy: %f", diffX, diffY);
	
	double angle = atan2(diffY, diffX) * (180 / M_PI);
	
	if(angle < 0) angle += 360;
	
	angle = angle - 90;
	angle = fmod(angle, 360.0);
	
	//find the vector for the edgePoint.
	NSLog(@"Angle to %@ is %f", path, angle);
	
	//make sure we don't overstep our bounds.
	double multiplier = 1/ max(cols, rows);
	
	edgePoint.x = (currentCoordinate.x-bigFrameCoordinate.x) * multiplier;
	edgePoint.y = (currentCoordinate.y-bigFrameCoordinate.y) * multiplier;
	
	NSLog(@"edgePoint for: %@ = %f, %f", path, edgePoint.x, edgePoint.y);
	
	edgePoint.x = screenRect.size.width/2 + edgePoint.x;
	edgePoint.y = screenRect.size.height/2 - edgePoint.y;
	
	NSLog(@"edgePoint for: %@ = %f, %f", path, edgePoint.x, edgePoint.y);
	
	//screw it.
	
	if(workspacePosition.x < currentPosition.x) edgePoint.x = 0;
	else edgePoint.x = screenRect.size.width - WINDOW_WIDTH;
	
	edgePoint.y = frame.origin.y;
	
	if(abs(current - workspace) % cols == 0){
		if(current < workspace) edgePoint.y = WINDOW_WIDTH;
		else edgePoint.y = screenRect.size.height - WINDOW_WIDTH - 100;
		
		edgePoint.x = frame.origin.x;
	}
	
	//NSRect initialWindowRect = NSMakeRect(screenRect.origin.x/2,screenRect.origin.y/2,WINDOW_WIDTH, WINDOW_WIDTH);
	NSRect windowRect = NSMakeRect(edgePoint.x,edgePoint.y, WINDOW_WIDTH, WINDOW_WIDTH);
	
	SCWindow *tempWindow = [[SCWindow alloc] initWithContentRect:windowRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[tempWindow setImage:[[NSWorkspace sharedWorkspace] iconForFile:path] withRotation:angle];
	
	[tempWindow setAlphaValue:0];
	
	//determine the y coordinate.
	
	//find out if directly above or below.
	//if(abs(current - workspace) % cols == 0)
	
	//if(ceil((double)workspace / (double)cols) < currentRow)
	
	return [tempWindow autorelease];
}

//x coordinate = column
//y coordinate = row
- (NSPoint)positionForWorkspace:(int)workspace{
	double row = ceil((double)workspace / (double)cols);
	return NSMakePoint(workspace - ((row-1) * cols) , row);
}

- (void)left{
	//decrement current and mod with rows * columns.
	int next;
	if(current <= 1) next = rows * cols;
	else next = current - 1;
	current = next;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.switchSpaces" object:[NSString stringWithFormat:@"%d", next-1]];
	[self showBezelForWindowList];
}

- (void)right{
	//increment current and mod with rows * columns.
	int next = (int)fmod((current+1), (rows * cols));
	current = next;
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.switchSpaces" object:[NSString stringWithFormat:@"%d", next-1]];
	[self showBezelForWindowList];
}

- (void)down{
	//add columns to current and check if greater than rows * columns. If so, do nothing.
	int next = current + cols;
	if(next <= rows * cols){
		current = next;
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.switchSpaces" object:[NSString stringWithFormat:@"%d", next-1]];
		[self showBezelForWindowList];
	}
}

- (void)up{
	//subtract columns from current and check if greater than 0. If so, do it.
	int next = current - cols;
	if(next > 0){
		current = next;
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"com.apple.switchSpaces" object:[NSString stringWithFormat:@"%d", next-1]];
		[self showBezelForWindowList];
	}
}

- (void)hideBezel{
	showWindows = NO;
	
	//order out all the windows.
}

#pragma mark Window List & Window Image Methods
typedef struct
{
	// Where to add window information
	NSMutableArray * outputArray;
	// Tracks the index of the window when first inserted
	// so that we can always request that the windows be drawn in order.
	int order;
} WindowListApplierData;

void WindowListApplierFunction(const void *inputDictionary, void *context)
{
	NSDictionary *entry = (NSDictionary*)inputDictionary;
	WindowListApplierData *data = (WindowListApplierData*)context;
	
	// The flags that we pass to CGWindowListCopyWindowInfo will automatically filter out most undesirable windows.
	// However, it is possible that we will get back a window that we cannot read from, so we'll filter those out manually.
	int sharingState = [[entry objectForKey:(id)kCGWindowSharingState] intValue];
	if(sharingState != kCGWindowSharingNone && [entry objectForKey:(id)kCGWindowWorkspace])
	{		
		SCWindowInfo *info = [[SCWindowInfo alloc] init];
		
		// Grab the application name, but since it's optional so we need to check before we can use it.
		NSString *applicationName = [entry objectForKey:(id)kCGWindowOwnerName];
		
		// Grab the Window Bounds, it's a dictionary in the array, but we want to display it as strings
		CGRect bounds;
		CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:(id)kCGWindowBounds], &bounds);
		info.bounds = bounds;
		
		NSString *workspaceString = [entry objectForKey:(id)kCGWindowWorkspace];
		info.workspace = [workspaceString intValue];
		
		if([applicationName isEqualTo:@"SpaceCommander"]){
			if(bounds.size.width == 1 && bounds.size.height == 1) [[SCSpaceController instance] setCurrentSpace:[workspaceString intValue]];
			[info release];
			return;
		}
		
		int applicationPID = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
		if(applicationName != NULL) {
			// PID is required so we assume it's present.
			info.owningApplication = applicationName;
			info.owningApplicationPath = [[NSWorkspace sharedWorkspace] fullPathForApplication:applicationName];
			//NSLog(@"applicationPath: %@", info.owningApplicationPath);
			if(!info.owningApplicationPath){
				//NSLog(@"application: %@", info.owningApplication);
			}
			info.owningApplicationPID = applicationPID;
		}else{
			info.owningApplication = @"Unknown";
			info.owningApplicationPID = applicationPID;
		}
		
		
		// Grab the Window ID & Window Level. Both are required, so just copy from one to the other
		info.windowID = [[entry objectForKey:(id)kCGWindowNumber] intValue];
		info.windowLevel = [[entry objectForKey:(id)kCGWindowLayer] intValue];
		
		// Finally, we are passed the windows in order from front to back by the window server
		// Should the user sort the window list we want to retain that order so that screen shots
		// look correct no matter what selection they make, or what order the items are in. We do this
		// by maintaining a window order key that we'll apply later.
		info.windowOrder = data->order;
		data->order++;
		
		[data->outputArray addObject:info];
	}
}

- (NSMutableArray *)getWindowList{
	CGWindowListOption listOptions = kCGWindowListOptionAll;
	listOptions | kCGWindowListOptionOnScreenOnly;
	listOptions | kCGWindowListExcludeDesktopElements;
	
	NSWindow *tempWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0,0,1,1) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[tempWindow center];
	[tempWindow setBackgroundColor:[NSColor clearColor]];
	[tempWindow orderFront:self];
	
	CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
	
	// Copy the returned list, further pruned, to another list. This also adds some bookkeeping
	// information to the list as well as 
	NSMutableArray * prunedWindowList = [NSMutableArray array];
	WindowListApplierData data = {prunedWindowList, 0};
	CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
	CFRelease(windowList);
	
	[tempWindow orderOut:self];
	[tempWindow release];
	
	// Set the new window list
	return prunedWindowList;
}

@end
