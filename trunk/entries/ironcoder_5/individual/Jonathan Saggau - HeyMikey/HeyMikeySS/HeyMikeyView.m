//
//  HeyMikeyView.m
//  HeyMikey
//
//  Created by Jonathan Saggau on 3/31/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import "HeyMikeyView.h"

extern NSMutableArray *mikeySounds;

int useAllScreens;
int playAllSounds;
int playInitialSound;
//bool soundIsPlaying;

static int intValueWithDefault(id object, int def) {
	return (object ? [object intValue] : def);
}

@interface HeyMikeyView (PrivateAPI)
-(void) setPreferencesFromDefaults;
-(void) listenToSounds;
-(void) ignoreSounds;
@end

@implementation HeyMikeyView
- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		NSOpenGLPixelFormatAttribute attribs[] ={	
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADepthSize, 16,
			NSOpenGLPFAMinimumPolicy,
			NSOpenGLPFAClosestPolicy,
			0
		};
		
	    NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attribs] autorelease];
		
		_view = [[[GLView alloc] initWithFrame:NSZeroRect pixelFormat:format] autorelease];
		[self addSubview:_view];
		_vizController = [[GLVizController alloc] initWithOpenGLView:_view zoom:1.0];
		[_vizController setBackgroundColor:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
		[_vizController awake];
		[_view setDelegate:_vizController];
		
		[self setAnimationTimeInterval:1/30.0];
		[self setPreferencesFromDefaults]; 
		//[self listenToSounds];     
    }
    return self;
}

- (void) dealloc {
	[self ignoreSounds];
	[_view setDelegate:nil];
	[_vizController release]; _vizController = nil;
	[super dealloc];
}


-(void)setPreferencesFromDefaults {
	NSUserDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MODULE_NAME];
	useAllScreens = intValueWithDefault([defaults objectForKey:@"useAllScreens"], 0);
	playAllSounds = intValueWithDefault([defaults objectForKey:@"playAllSounds"], 0);
	playInitialSound = intValueWithDefault([defaults objectForKey:@"playInitialSound"], 0);
}

-(void)updatePreferencesFromConfigureSheet {
	NSUserDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:MODULE_NAME];
	[defaults setInteger:([allScreensCheckbox state]==NSOnState) forKey:@"useAllScreens"];
	[defaults setInteger:([allSoundsCheckbox state]==NSOnState) forKey:@"playAllSounds"];
	[defaults setInteger:([initialSoundCheckbox state]==NSOnState) forKey:@"playInitialSound"];
	
	[defaults synchronize];
	[self setPreferencesFromDefaults];
}

-(void)updateControlsFromPreferences {
	[allScreensCheckbox setState:(useAllScreens ? NSOnState : NSOffState)];
	[allSoundsCheckbox setState:(playAllSounds ? NSOnState : NSOffState)];
	[initialSoundCheckbox setState:(playInitialSound ? NSOnState : NSOffState)];
}

- (void)setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
    [_view setFrameSize:newSize];
    _initedGL = NO;
}

- (void)animateOneFrame
{
	if (useAllScreens || [[self window] screen]==[NSScreen mainScreen]) {
		[[_view openGLContext] makeCurrentContext];
		if (!_initedGL) {
			[_vizController awake];
			_initedGL = YES;
		}
		//[_vizController updateGL:_view];
	}
	else {
		// secondary screen; remove OpenGL view and fill with black (only once)
		if (_view) {
			[_view removeFromSuperview];
			_view = nil;
			[[NSColor blackColor] set];
			NSRectFill([self frame]);
		}
	}
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    if (!configureSheet) {
		[NSBundle loadNibNamed:@"HeyMikeyConfigureSheet" owner:self];
    }
    [self updateControlsFromPreferences];
    return configureSheet;
}

-(void)savePrefs:(id)sender {
	[self updatePreferencesFromConfigureSheet];
	
	[NSApp endSheet:configureSheet];
}

-(void)cancelPrefs:(id)sender {
	[NSApp endSheet:configureSheet];
}

@end
