//
//  HiddenWindow.m
//  Camouflage
//
//  Created by Karsten Kusche on 20.10.06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "HiddenWindow.h"
#import <ScreenSaver/ScreenSaverView.h>
#import <Quartz/Quartz.h>

typedef enum {
	CGSTagExposeFade	= 0x0002,   // Fade out when Expose activates.
	CGSTagNoShadow		= 0x0008,   // No window shadow.
	CGSTagTransparent   = 0x0200,   // Transparent to mouse clicks.
	CGSTagSticky		= 0x0800,   // Appears on all workspaces.
} CGSWindowTag;

@implementation HiddenWindow

+ (id)windowForScreen: (NSScreen*)screen
{
	id window = [[self alloc] initWithContentRect:[screen frame] styleMask: NSBorderlessWindowMask backing:2 defer:NO];
	[window setScreenId:[[screen deviceDescription] objectForKey:@"NSScreenNumber"]];
	return window;
}

+ (id)windowForScreenWithID: (CGDirectDisplayID) display
{
	CGRect rect_ = CGDisplayBounds(display);
	NSRect rect = NSMakeRect(rect_.origin.x,rect_.origin.y,rect_.size.width,rect_.size.height); 
	id window = [[self alloc] initWithContentRect:rect styleMask: NSBorderlessWindowMask backing:2 defer:NO];
	[window setScreenId:[NSNumber numberWithInt:(int)display]];
	return window;
}

- (void)setSticky 
{
	CGSConnectionID cid;
	CGSWindowID wid;
	
	wid = [self windowNumber];
	cid = _CGSDefaultConnection();
	int tags[3] = { 0, 0, 0 };

	OSStatus stat;
	CGSGetWindowTags(cid, wid, tags, 32);
	//		NSLog(@"stat = %i, tags = 0x%x 0x%x 0x%x",stat, tags[0],tags[1],tags[2]);
	
	stat = CGSClearWindowTags(cid,wid,tags,32);
	//		NSLog(@"stat = %i, tags = 0x%x 0x%x 0x%x",stat, tags[0],tags[1],tags[2]);
	tags[0] = 0x00000000 | CGSTagSticky;
/*	if ([NSApp clickThrough])
	{
		tags[0] |= CGSTagTransparent;
	}
*/	tags[1] = 0x3;
	
	stat = CGSSetWindowTags(cid, wid, tags, 32);
	//		NSLog(@"stat = %i, tags = 0x%x 0x%x 0x%x",stat, tags[0],tags[1],tags[2]);
	
	CGSGetWindowTags(cid, wid, tags, 32);
	//		NSLog(@"stat = %i, tags = 0x%x 0x%x 0x%x",stat, tags[0],tags[1],tags[2]);
	return;
}

- (void)setContentViewWithRect:(NSRect)contentRect
{
	[self setContentView:[[NSView alloc] initWithFrame:contentRect]];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{	
	if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])
	{
		[self useOptimizedDrawing:NO];
		[self setOpaque:NO];
		[self setHasShadow:NO];
		[self setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"]];
		[self setLevel:NSStatusWindowLevel+100];
		[self setSticky];
		[self setReleasedWhenClosed:NO];
		[self setContentViewWithRect:contentRect];
		[self setAcceptsMouseMovedEvents:YES];
		[self setupScreenSaver];
		[[self contentView] addTrackingRect:contentRect owner:self userData:nil assumeInside:YES];


//		[self setReleasedWhenClosed:YES];
	}
	return self;
}

- (BOOL)canBecomeMainWindow
{
	return YES;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void) setScreenId:(NSNumber*)theID
{
	screenID = [theID retain];
	[self updateDisplay];
}

- (NSNumber*) screenID
{
	return screenID;
}

- (void)updateDisplay
{
	[self display];
}

- (void) dealloc
{
	[lastModified release];	
	[screenID release];
	[infoDict release];

	[super dealloc];
}

- (NSColor*) backgroundColor
{
	NSColor* color = [NSColor colorWithCalibratedWhite:0.0 alpha:1.0];
	return color;
}

- (void)mouseDown:(NSEvent*)theEvent
{
	[NSApp hide:nil];
}

- (void)keyDown:(NSEvent*)theEvent
{
	[NSApp hide:nil];
}

- (BOOL)noUnintendedMoveInEvent:(NSEvent*)theEvent
{
	float deltaX = [theEvent deltaX];
	float deltaY = [theEvent deltaY];
	return ((deltaX*deltaX)+(deltaY*deltaY)) > 10; //didn't even move 10 pixels
}

- (void)mouseMoved:(NSEvent*)theEvent
{
	if ([self noUnintendedMoveInEvent:theEvent])
	{
		[NSApp hide:nil];
	}
}

- (void)setupScreenSaver
{
	ScreenSaverDefaults* userDefs = [ScreenSaverDefaults defaultsForEngine];
	[userDefs synchronize];
	NSString* modulePath = [userDefs objectForKey:@"modulePath"];
	if (modulePath)
	{
//		Class pluginClass = [[ScreenSaverModules sharedInstance] classForModuleWithPath:modulePath];
//		ScreenSaverView* newView = [[pluginClass alloc] initWithFrame:[self frame] isPreview:NO];
		ScreenSaverView* newView = [[ScreenSaverModules sharedInstance] loadModuleWithPath:modulePath 
																					 frame:[self frame]
																				 isPreview:NO];
		if (newView)
		{
			[self setContentView:newView];
		}
		else
		{
			NSLog(@"meh...something went wrong here :-/");
		}
	}
	else
	{
		NSLog(@"module path is empty?!");
	}
	
	[self setAlphaValue:[[NSUserDefaults standardUserDefaults] floatForKey:@"opacity"]];
}

- (void)makeKeyAndOrderFront:(id)sender
{
	[self setupScreenSaver];
	[self startAnimating];
	[super makeKeyAndOrderFront:sender];
}

- (void)close
{
	[self stopAnimating];
	
//	CGDisplayRelease((CGDirectDisplayID)[[self screenID] intValue]);
	[super close];
}


@end
