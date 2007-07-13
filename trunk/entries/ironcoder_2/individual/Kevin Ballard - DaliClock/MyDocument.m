//
//  MyDocument.m
//  DaliClock
//
//  Created by Kevin Ballard on 7/23/06.
//  Copyright Tildesoft 2006. All rights reserved.
//

#import "MyDocument.h"
#import "ClockControl.h"
#import "DaliWindow.h"
#import "UnicornView.h"

typedef struct CGPointWarp {
	CGPoint local;
	CGPoint global;
} CGPointWarp;

typedef int CGSConnectionID;
typedef int CGSWindowID;

extern CGSConnectionID _CGSDefaultConnection();

extern CGError CGSSetWindowWarp(CGSConnectionID, CGSWindowID, int w, int h, CGPointWarp mesh[w][h]);
extern OSStatus CGSGetScreenRectForWindow(CGSConnectionID cid, CGSWindowID wid, CGRect *outRect);
extern OSStatus CGSGetWindowBounds(CGSConnectionID cid, CGSWindowID wid, CGRect *bounds);

@implementation MyDocument

- (void)dealloc {
	[clockControl release];
	
	[animationTimer invalidate];
	[animationTimer release];
	
	[super dealloc];
}

- (void)close {
	[animationTimer invalidate];
	[animationTimer release];
	animationTimer = nil;
	
	[super close];
}

- (void)makeWindowControllers {
	// create the window now
	NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
	float randX = (random() % (int)(NSWidth(screenFrame) - 200)) + NSMinX(screenFrame);
	float randY = (random() % (int)(NSHeight(screenFrame) - 200)) + NSMinY(screenFrame);
	NSWindow *clockWindow = [[DaliWindow alloc] initWithContentRect:NSMakeRect(randX, randY, 200, 200)
														  styleMask:NSBorderlessWindowMask
															backing:NSBackingStoreBuffered\
															  defer:NO];
	[clockWindow setMovableByWindowBackground:YES];
	[clockWindow setOpaque:NO];
	[clockWindow setLevel:[clockWindow level]+1];
	
	// make sure the first time we make a clock
	static BOOL firstCall = YES;
	if (!firstCall && (random() % 100) < 15) {
		// 15% of the time, UNICORN!
		UnicornView *unicornView = [[UnicornView alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
		[clockWindow setContentView:unicornView];
	} else {
		clockControl = [[ClockControl alloc] initWithFrame:NSMakeRect(0, 0, 200, 200)];
		[clockWindow setContentView:clockControl];
	}
	firstCall = NO;
	NSWindowController *windowController = [[NSWindowController alloc] initWithWindow:clockWindow];
	[windowController setShouldCloseDocument:YES];
	[clockWindow release];
	[self addWindowController:windowController];
	[windowController release];
	
	// setup animation timer
	startDate = [[NSDate alloc] init];
	duration = 15 + (random() % 21); // 15-35 seconds
	slump = (random() % 100) * (1 - (random()&0x1) * 2);
	animationTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1
													   target:self
													 selector:@selector(updateDeformation:)
													 userInfo:nil
													  repeats:YES] retain];
}

#define H 64
#define W 2

#define kWaveOffset 16

- (void)updateTime:(NSTimer *)aTimer {
	[clockControl setTime:[NSCalendarDate calendarDate]];
}

- (void)updateDeformation:(NSTimer *)aTimer {
	[self updateTime:aTimer];
	
	// deform the clock
	CGPointWarp meshes[H][W];
	NSTimeInterval progress = [NSDate timeIntervalSinceReferenceDate] - [startDate timeIntervalSinceReferenceDate];
	float percent = MIN(progress / duration, 1);
	
	// do a sine wave curve down the sides
	CGSConnectionID cid = _CGSDefaultConnection();
	NSWindow *window = [[[self windowControllers] lastObject] window];
	if (window == nil) {
		// this should never happen, but I like to be careful
		[aTimer invalidate];
		return;
	}
	CGRect frame;
	CGSGetWindowBounds(cid, [window windowNumber], &frame);
	for (int h = 0; h < H; h++) {
		for (int w = 0; w < W; w++) {
			CGPointWarp point;
			point.local.x = w * (frame.size.width / (W - 1));
			point.local.y = h * (frame.size.height / (H - 1));
			float waveAmount = kWaveOffset * sin(point.local.y / 10) * percent;
			// slump formula was experimentally derived via Grapher.app
			float slumpAmount = (1 / (2 * (point.local.y / frame.size.height) + 0.73) - 0.365) * slump * percent;
			point.global.x = point.local.x + frame.origin.x + waveAmount + slumpAmount;
			point.global.y = point.local.y + frame.origin.y + (fabs(slumpAmount) / 3);
			meshes[h][w] = point;
		}
	}
	
	CGSSetWindowWarp(cid, [window windowNumber], W, H, meshes);
	
	// see if we can kill the deformation timer
	if (progress >= duration) {
		[aTimer invalidate];
		// figure out next minute
		NSCalendarDate *date = [NSCalendarDate calendarDate];
		NSTimeInterval interval = [date timeIntervalSinceReferenceDate];
		NSTimeInterval milliseconds = interval - floor(interval);
		NSDate *fireDate = [date addTimeInterval:(60 - [date secondOfMinute] - milliseconds)];
		[animationTimer release];
		animationTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:60 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
		[[NSRunLoop currentRunLoop] addTimer:animationTimer forMode:NSDefaultRunLoopMode];
	}
}

@end
