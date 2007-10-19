//
//  IronLifeView.m
//  IronLife
//
//  Created by 23 on 3/30/07.
//  Copyright (c) 2007, Chris Parrish. All rights reserved.
//

#import "IronLifeView.h"


@implementation IronLifeView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [ super initWithFrame:frame isPreview:isPreview ];

    if ( !self)
		return self;
	
	//----- defaults
	
	ScreenSaverDefaults *defaults = [ ScreenSaverDefaults defaultsForModuleWithName:@"com.twenty3.IronLife" ];
	[ defaults registerDefaults:[ NSDictionary dictionaryWithObjectsAndKeys:
									@"NO", @"firstKey",
									nil ] ];
	
	//----- set up subviews
	
	NSString* compositionPath =
		[ [ NSBundle bundleForClass:[ self class ] ] pathForResource:@"composition" ofType:@"qtz" ]; 
	
	_compositionView = [ [ [ QCView alloc ] initWithFrame:frame ] autorelease ];
	[ _compositionView setAutostartsRendering:YES ];
	[ _compositionView loadCompositionFromFile:compositionPath ];
	[ _compositionView setEraseColor:[ NSColor colorWithDeviceWhite:0.0 alpha:0.0 ] ];
	[ self addSubview: _compositionView ];
	
	[ self setAnimationTimeInterval: ( 1 / 30.0 ) ];

    return self;
}

- (void) dealloc
{	
	[ _compositionView removeFromSuperview ];
	//[ _lifeView removeFromSuperview ];
	
	[ super dealloc ];
}


#pragma mark Animation

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

	[ [ NSColor grayColor ] set ];
	[ NSBezierPath fillRect: rect ];
}

- (void)animateOneFrame
{
	return;
}


#pragma mark Configuration

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
	[ ScreenSaverDefaults defaultsForModuleWithName:@"com.twenty3.IronLife" ];

	if ( !_configurationSheet )
	{
		[ NSBundle loadNibNamed:@"IronLife" owner:self ];
	}
	
	// set controls to match defaults
	
    return _configurationSheet;
}

- (IBAction) doOK:(id)sender
{
	ScreenSaverDefaults *defaults = [ ScreenSaverDefaults defaultsForModuleWithName:@"com.twenty3.IronLife" ];
			
	[ defaults setBool:YES forKey:@"firstKey" ];

	[ defaults synchronize ];
  
	[ [ NSApplication sharedApplication ] endSheet:_configurationSheet ];
}

- (IBAction) doCancel:(id)sender
{
  [ [ NSApplication sharedApplication ] endSheet:_configurationSheet ];
}

@end
