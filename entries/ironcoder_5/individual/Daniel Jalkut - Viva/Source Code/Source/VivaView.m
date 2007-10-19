//
//  VivaView.m
//  Viva
//
//  Created by Daniel Jalkut on 3/31/07.
//  Copyright (c) 2007, Red Sweater Software. All rights reserved.
//

#import "VivaView.h"
#import "NSColor+Utilities.h"
#import "ScreenSaverHack.h"
#import "ScreenSaverModules+Viva.h"

const float kVivaResetTimeInterval = 15.0;

@interface VivaView (PrivateMethods)
- (void) startAnimatingSubView:(ScreenSaverView*)thisView;
- (void) resetVivaLayout:(NSTimer*)theTimer;
@end

@implementation VivaView

- (NSArray*) userEnabledScreensaverNames
{
	NSMutableArray* filteredNames = [[[ScreenSaverModules usableModuleNamesForViva] mutableCopy] autorelease];
	NSArray* excludedSavers = (NSArray*) CFPreferencesCopyAppValue(CFSTR("TurnedOffSavers"), CFSTR("com.red-sweater.Viva"));
	NSEnumerator* exclusionEnum = [excludedSavers objectEnumerator];
	NSString* thisOmission = nil;
	while (thisOmission = [exclusionEnum nextObject])
	{
		[filteredNames removeObject:thisOmission];
	}
	
	return [NSArray arrayWithArray:filteredNames];
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self)
	{
		mIsPreviewSaver = isPreview;

		// Make sure we default to the user preference, even if we're running in saver mode
		mVisibleScreensaverCount = [(NSNumber*)CFPreferencesCopyAppValue(CFSTR("VivaTiling"), CFSTR("com.red-sweater.Viva")) intValue];
		
		// We should be the content view for the window	
		NSWindow* myWindow = [self window];
		[self retain];
		[self removeFromSuperview];	
		[myWindow setContentView:self];
		[self release];
		
		// Build our initial saver set
		mShownSavers = [[NSMutableArray alloc] initWithCapacity:0];
		mShownSaverNames = [[NSMutableArray alloc] initWithCapacity:0];
		
		// default to all reasonable screen savers
		[self setScreensaverNames:[self userEnabledScreensaverNames]];		
		
		// We want to switch savers every so often
		[NSTimer scheduledTimerWithTimeInterval:kVivaResetTimeInterval target:self selector:@selector(switchOneSaver:) userInfo:nil repeats:YES];		
    }
    return self;
}

- (void) dealloc
{
	[mShownSavers release];
	[mShownSaverNames release];
	[mScreensaverNames release];
	[mBackgroundColor release];
	[super dealloc];
}

//  screensaverNames 
- (NSArray *) screensaverNames
{
    return mScreensaverNames; 
}

- (void) setScreensaverNames: (NSArray *) theScreensaverNames
{
    if (mScreensaverNames != theScreensaverNames)
    {
        [mScreensaverNames release];
        mScreensaverNames = [theScreensaverNames retain];
		
		[self resetVivaLayout:nil];
    }
}

- (NSString*) randomSaverName 
{
	NSString* thisSaverName = nil;;
	
	// Avoid dupes (unless we're desparate and have fewer savers than tiles)
	do
	{
		int thisIndex = random() % [mScreensaverNames count];
		thisSaverName = [mScreensaverNames objectAtIndex:thisIndex];
	} while (([mScreensaverNames count] > mVisibleScreensaverCount) && ([mShownSaverNames containsObject:thisSaverName] == YES));
	
	return thisSaverName;
}

- (void) switchOneSaver:(NSTimer*)theTimer
{
#pragma unused (theTimer)
	// Ignore if we're paused
	if ([self isAnimating] == NO) return;

	int switchIndex = random() % mVisibleScreensaverCount;
	ScreenSaverView* replacingView = [mShownSavers objectAtIndex:switchIndex];
	NSString* thisSaverName = [self randomSaverName];
	NSRect thisFrame = [replacingView frame];
	[replacingView stopAnimation];
	
	// DUPLICATED CODE from reset method below - but I'm in a hurry.
	
	// Load the module
	ScreenSaverModules* modules = [ScreenSaverModules sharedInstance];				
	ScreenSaverView* newView = nil;
	
	// Protect against some bad screensavers throwing exceptions :(
	NS_DURING
			newView = [modules loadModuleWithName:thisSaverName frame:thisFrame isPreview:mIsPreviewSaver];
	NS_HANDLER
			newView = nil;
	NS_ENDHANDLER
	
	if (newView)
	{
		[replacingView removeFromSuperview];	
		[newView setFrame:thisFrame];					
		[self addSubview:newView];

		if ([self isAnimating] == YES)
		{
			[self startAnimatingSubView:newView];
		}
		else
		{
			[newView stopAnimation];
		}
		
		[newView setNeedsDisplay:YES];
					
		// Keep track
		[mShownSavers replaceObjectAtIndex:switchIndex withObject:newView];
		[mShownSaverNames replaceObjectAtIndex:switchIndex withObject:thisSaverName];
	}
	else
	{
		// False alarm, couldn't replace it 
		[replacingView startAnimation];
	}
}

- (void) resetVivaLayout:(NSTimer*)theTimer
{
#pragma unused (theTimer)
	BOOL wasAnimating = [self isAnimating];
	if (wasAnimating)
	{
		[(ScreenSaverWindow*)[self window] stopAnimating];
	}
	
	NSEnumerator* viewEnum = [mShownSavers objectEnumerator];	
	ScreenSaverView* thisView = nil;
	while (thisView = [viewEnum nextObject])
	{
		[thisView stopAnimation];
		[thisView removeFromSuperview];
	}
	[mShownSavers removeAllObjects];
	[mShownSaverNames removeAllObjects];
	
	// Add some random savers to our tiled view
	unsigned int matrixHeight = 1;
	unsigned int matrixWidth = 1;
	if (mVisibleScreensaverCount == 2)
	{
		// Randomize the orientation, between top-bottom and side-side
		if ((random() % 2) == 1)
		{
			matrixWidth = 2; matrixHeight = 1;
		}
		else
		{
			matrixWidth = 1; matrixHeight = 2;
		}
	}
	else
	{
		// All other allowable choices are perfect squares
		matrixHeight = sqrt(mVisibleScreensaverCount);
		matrixWidth = sqrt(mVisibleScreensaverCount);
	}
	unsigned int thisXPos = 0;
	unsigned int thisYPos = 0;
	while ([mShownSavers count] < mVisibleScreensaverCount)
	{
		NSRect thisFrame = [self frame];
		float unitWidth = (thisFrame.size.width / matrixWidth);
		float unitHeight = (thisFrame.size.height / matrixHeight);
		thisFrame.size.width = unitWidth;
		thisFrame.size.height =  unitHeight;
		thisFrame.origin.x = thisXPos * unitWidth;
		thisFrame.origin.y = thisYPos * unitHeight;
		
		NSString* nextSaverName = [self randomSaverName];
		{
			// Load the module
			ScreenSaverModules* modules = [ScreenSaverModules sharedInstance];				
			ScreenSaverView* newView = nil;
			
			// Protect against some bad screensavers throwing exceptions :(
			NS_DURING
					newView = [modules loadModuleWithName:nextSaverName frame:thisFrame isPreview:mIsPreviewSaver];
			NS_HANDLER
					newView = nil;
			NS_ENDHANDLER
			
			if (newView)
			{
//				NSLog(@"Setting view %@ frame %@ for cell at %d/%d", newView, NSStringFromRect(thisFrame), thisXPos, thisYPos);
				[newView setFrame:thisFrame];					
				[self addSubview:newView];

				if ([self isAnimating] == YES)
				{
					[self startAnimatingSubView:newView];
				}
				else
				{
					[newView stopAnimation];
				}
				
				[newView setNeedsDisplay:YES];
							
				// Keep track
				[mShownSavers addObject:newView];
				[mShownSaverNames addObject:nextSaverName];
				
				if (thisXPos >= (matrixWidth - 1))
				{
					thisXPos = 0;
					thisYPos++;
				}
				else
				{
					thisXPos++;
				}
			}
		}
	}
	
	if (wasAnimating)
	{
		[(ScreenSaverWindow*)[self window] startAnimating];
	}
}

- (void)keyDown:(NSEvent *)theEvent
{
	// Keycode 11 == 'b'
	if (([theEvent type] == NSKeyDown) && ([theEvent keyCode] == 11))
	{
		NSSound* blipSound = [NSSound soundNamed:@"Submarine"];
		[blipSound stop];
		[blipSound play];
	}
}

- (void) startAnimatingSubView:(ScreenSaverView*)thisView
{
	if ([thisView isAnimating] == NO)
	{
		[thisView startAnimation];
	}
}
- (void)startAnimation
{
	NSEnumerator* viewEnum = [mShownSavers objectEnumerator];	
	ScreenSaverView* thisView = nil;
	while (thisView = [viewEnum nextObject])
	{
		[self startAnimatingSubView:thisView];
	}

	// This is our chance to sneak the transparency of the screensaver
	NSWindow* parentWindow = [self window];
	
	// Avoid setting transparency of the System Prefs window :) 
	if ([parentWindow isKindOfClass:[ScreenSaverWindow class]])
	{
		float userAlphaPref = [(NSNumber*)CFPreferencesCopyAppValue(CFSTR("VivaTransparency"), CFSTR("com.red-sweater.Viva")) floatValue];
		[[self window] setAlphaValue:userAlphaPref];
	}
	
    [super startAnimation];
}

- (void)stopAnimation
{
	NSEnumerator* viewEnum = [mShownSavers objectEnumerator];	
	ScreenSaverView* thisView = nil;
	while (thisView = [viewEnum nextObject])
	{
		[thisView stopAnimation];
	}

    [super stopAnimation];
}

- (BOOL) isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)rect
{
	[[NSColor clearColor] set];
	NSRectFill(rect);
}

- (void)animateOneFrame
{		
	NSEnumerator* viewEnum = [mShownSavers objectEnumerator];	
	ScreenSaverView* thisView = nil;
	while (thisView = [viewEnum nextObject])
	{
		[thisView animateOneFrame];
	}

    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
	// Our "configure sheet" is in Viva.app
	NSString* scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"OpenPrefs" ofType:@"scpt"];
	if (scriptPath != nil)
	{
		NSURL* scriptURL = [NSURL fileURLWithPath:scriptPath];
		NSAppleScript* myScript = [[NSAppleScript alloc] initWithContentsOfURL:scriptURL error:nil];
		if (myScript != nil)
		{
			[myScript executeAndReturnError:nil];
			[myScript release];
		}
	}

    return nil;
}

//  backgroundColor 
- (NSColor *) backgroundColor
{
    return mBackgroundColor; 
}

- (void) setBackgroundColor: (NSColor *) theBackgroundColor
{
    if (mBackgroundColor != theBackgroundColor)
    {
        [mBackgroundColor release];
        mBackgroundColor = [theBackgroundColor retain];
    }
}

//  visibleScreensaverCount 
- (int) visibleScreensaverCount
{
    return mVisibleScreensaverCount;
}

- (void) setVisibleScreensaverCount: (int) theVisibleScreensaverCount
{
    mVisibleScreensaverCount = theVisibleScreensaverCount;
	[self resetVivaLayout:nil];
}

@end
