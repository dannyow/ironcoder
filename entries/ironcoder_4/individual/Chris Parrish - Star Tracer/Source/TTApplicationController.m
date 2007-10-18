//
//  TTApplicationController.m
//  SpaceTime
//
//  Created by 23 on 10/27/06.
//  Copyright 2006 23. All rights reserved.
//

#import "TTApplicationController.h"
#import "TTSpaceTimeView.h"

@implementation TTApplicationController

- (id)initWithWindow:(NSWindow *)window
{
	self = [ super initWithWindow:window ];
	
	if (self != nil)
	{
		_maximumStarCount	=	300;
		_minimumStarCount	=	10;
	}
	
	return self;
}

- (void) awakeFromNib
{
	[ self setStarCount:50 ];
	[ _controlPanel setBecomesKeyOnlyIfNeeded:YES ];
}

#pragma mark Accessors

- (void) setStarCount:(unsigned int)count
{
	if ( count == _starCount )
		return;
		
	_starCount = count;

	[ _view distributeStars:count ];
}

#pragma mark Actions

- (IBAction) redistributeStars:(id)sender
{
	[ _view animateRedistribute:_starCount ];
}

- (IBAction) resetConstellation:(id)sender
{
	[ _view resetConstellation ];
}

- (IBAction) saveImage:(id)sender
{
	NSSavePanel* savePanel = [ NSSavePanel savePanel ];
	
	[ savePanel setCanCreateDirectories:YES ];
	[ savePanel setCanSelectHiddenExtension:YES ];
	[ savePanel setTitle:@"Save Constellation Image" ];
	
	NSArray* allowedTypes = [ NSArray arrayWithObjects:@"jpg", @"jpeg", nil ];
	
	[ savePanel setAllowedFileTypes:allowedTypes ];
		
	int result = [ savePanel runModalForDirectory:nil file:@"Star Tracer Image.jpg" ];
	
	if ( result != NSFileHandlingPanelOKButton )
		return;
		
	[ _view lockFocus ];
	
	NSBitmapImageRep* rep = [ [ [NSBitmapImageRep alloc] initWithFocusedViewRect:
								[ _view bounds ] ] autorelease ];
	
	[ _view unlockFocus ];

	NSDictionary* properties =
		[ NSDictionary dictionaryWithObject:[ NSNumber numberWithFloat:0.9 ]
									 forKey:NSImageCompressionFactor ];
											
	NSData* jpegData = [ rep representationUsingType:NSJPEGFileType properties:properties ];
	
	BOOL saveResult = [ jpegData writeToFile:[ savePanel filename ] atomically:NO ];

	if ( saveResult )
		return;
		
	NSAlert* errorAlert = [ NSAlert alertWithMessageText:@"Could not save file."
										   defaultButton:nil
										   alternateButton:nil
										   otherButton:nil
										   informativeTextWithFormat:nil ];
	[ errorAlert runModal ];
}



@end
