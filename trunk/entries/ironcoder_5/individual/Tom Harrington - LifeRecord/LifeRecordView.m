//
//  LifeRecordView.m
//  LifeRecord
//
//  Created by Tom Harrington on 4/1/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import "LifeRecordView.h"
#import <Quartz/Quartz.h>

NSString *kSnapshotInterval = @"kSnapshotInterval";
NSString *kFilterChangeFlag = @"kFilterChangeFlag";
NSString *kSnapshotSaveLocation = @"kSnapshotSaveLocation";
NSString *kSnapshotIndex = @"kSnapshotIndex";
NSString *kSnapshotMaxSaved = @"kSnapshotMaxSaved";

int defaultSnapshotInterval = 5;
BOOL defaultFilterChangeFlag = YES;
int defaultSnapshotIndex = 1;
int defaultSnapshotMaxSaved = 10;

@implementation LifeRecordView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
		if (isPreview || (frame.origin.x == 0.0)) {
			NSRect qtzFrame;
			qtzFrame = NSMakeRect(0.0,0.0,640.0,480.0);
			qtzFrame = SSCenteredRectInRect(qtzFrame,frame);
			qtzView = [[QCView alloc] initWithFrame:qtzFrame];
			NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
			NSString *compositionPath = [myBundle pathForResource:@"imageCaptureMultiFilter" ofType:@"qtz"];
			[qtzView loadCompositionFromFile:compositionPath];
			
			[self addSubview:qtzView];
			[qtzView startRendering];
			
			flashLevel = 0.0;
			
			defaults = [ScreenSaverDefaults defaultsForModuleWithName:[myBundle bundleIdentifier]];
			NSString *defaultSnapshotLocation = [NSString stringWithFormat:@"%@/Pictures", NSHomeDirectory()];
			[defaults registerDefaults:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:defaultSnapshotInterval], [NSNumber numberWithBool:defaultFilterChangeFlag], defaultSnapshotLocation, [NSNumber numberWithInt:defaultSnapshotIndex], [NSNumber numberWithInt:defaultSnapshotMaxSaved], nil]
																   forKeys:[NSArray arrayWithObjects:kSnapshotInterval, kFilterChangeFlag, kSnapshotSaveLocation, kSnapshotIndex, kSnapshotMaxSaved, nil]]];
			snapshotInterval = [defaults integerForKey:kSnapshotInterval];
			changeFilter = [defaults boolForKey:kFilterChangeFlag];
			snapshotSaveLocation = [defaults stringForKey:kSnapshotSaveLocation];
			snapshotIndex = [defaults integerForKey:kSnapshotIndex];
			snapshotMaxSaved = [defaults integerForKey:kSnapshotMaxSaved];
			

			snapshotTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)snapshotInterval
															 target:self
														   selector:@selector(snapshotTimerCallback:)
														   userInfo:nil
															repeats:YES];
			[snapshotTimer retain];
		}
    }
    return self;
}

- (void)_resumeVideo:(id)unused
{
#pragma unused(unused)
	[qtzView setValue:[NSNumber numberWithBool:YES] forInputKey:@"updateImage"];
	if (changeFilter) {
		[qtzView setValue:[NSNumber numberWithInt:SSRandomIntBetween(0,3)] forInputKey:@"filterIndex"];
		[qtzView setValue:[NSNumber numberWithInt:SSRandomIntBetween(0,3)] forInputKey:@"filterGroup"];
	}
}

- (void)_snapshot
{
	// This works but it can't possibly be the best way.
	
	[qtzView setValue:[NSNumber numberWithBool:NO] forInputKey:@"updateImage"];
	NSImage *snapshot = [qtzView valueForOutputKey:@"snapshot"];
	//NSLog(@"snapshot class: %@", [snapshot class]);
	//NSLog(@"image reps: %@", [snapshot representations]);
	NSData *tiffData = [snapshot TIFFRepresentation];
	//[tiffData writeToFile:@"/tmp/image.tiff" atomically:NO];
	NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:tiffData];
	NSData *jpegData = [bitmapRep representationUsingType:NSJPEGFileType properties:nil];
	
	NSString *filename = [NSString stringWithFormat:@"%@/LifeRecord image %d.jpg", snapshotSaveLocation, snapshotIndex];
	if (snapshotIndex > snapshotMaxSaved) {
		NSFileManager *filemanager = [NSFileManager defaultManager];
		NSString *targetFilename = [NSString stringWithFormat:@"%@/LifeRecord image %d.jpg", snapshotSaveLocation, snapshotIndex - snapshotMaxSaved];
		if ([filemanager fileExistsAtPath:targetFilename]) {
			[filemanager removeFileAtPath:targetFilename handler:nil];
		}
	}
	snapshotIndex++;
	[jpegData writeToFile:filename atomically:NO];
	[self performSelector:@selector(_resumeVideo:) withObject:nil afterDelay:2.0];
}

- (void)adjustFlash:(NSTimer *)timer
{
#pragma unused(timer)
	flashLevel += flashStep;
	[qtzView setValue:[NSNumber numberWithFloat:flashLevel] forInputKey:@"flashLevel"];
	if (flashLevel >= 1.0) {
		if (![self isPreview]) {
			[self _snapshot];
		} else {
			[qtzView setValue:[NSNumber numberWithInt:SSRandomIntBetween(0,3)] forInputKey:@"filterIndex"];
			[qtzView setValue:[NSNumber numberWithInt:SSRandomIntBetween(0,3)] forInputKey:@"filterGroup"];
		}
		flashStep *= -1.0;
	}
	if (flashLevel <= 0.0) {
		flashStep *= -1.0;
		[flashTimer invalidate];
		[flashTimer release];
	}
}

- (void)snapshotTimerCallback:(NSTimer *)unused
{
#pragma unused(unused)
	flashStep = 0.1;
	flashTimer = [[NSTimer scheduledTimerWithTimeInterval:0.01
												   target:self 
												 selector:@selector(adjustFlash:)
												 userInfo:nil
												  repeats:YES] retain];
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
	[defaults setInteger:snapshotIndex forKey:kSnapshotIndex];
	[defaults synchronize];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
	if (!configSheet)
	{
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) 
		{
			NSLog( @"Failed to load configure sheet." );
			NSBeep();
		}

	}
	[shapshotIntervalField setIntValue:[defaults integerForKey:kSnapshotInterval]];
	[changeFilterButton setState:[defaults boolForKey:kFilterChangeFlag]];
	[snapshotSaveLocationField setStringValue:[defaults stringForKey:kSnapshotSaveLocation]];
	[snapshotMaxSavedField setIntValue:[defaults integerForKey:kSnapshotMaxSaved]];
	//[self setValue:[NSNumber numberWithInt:[defaults integerForKey:kSnapshotInterval]] forKey:@"snapshotInterval"];
	
	return configSheet;
}

- (IBAction)cancelClick:(id)sender
{
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction)okClick:(id)sender
{
	[defaults setInteger:[shapshotIntervalField intValue] forKey:kSnapshotInterval];
	[defaults setBool:[changeFilterButton state] forKey:kFilterChangeFlag];
	[defaults setValue:[snapshotSaveLocationField stringValue] forKey:kSnapshotSaveLocation];
	[defaults setInteger:[snapshotMaxSavedField intValue] forKey:kSnapshotMaxSaved];
	[defaults synchronize];
	[[NSApplication sharedApplication] endSheet:configSheet];
}

@end
