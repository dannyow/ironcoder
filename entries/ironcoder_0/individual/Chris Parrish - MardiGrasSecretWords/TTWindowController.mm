/**************************************************************************************
 * Copyright (c) 2006 RogueSheep Incorporated. All rights reserved.
 *
 * $File: //RogueSheep/CompanyDocs/XCodeTemplates/Cocoa/Objective-C NSWindowController subclass.pbfiletemplate/class.mm $
 * $Revision: #1 $
 * $Author: raezor $
 * $Date: 2005/06/23 $
 *
 * Created by 23 on 3/5/06.
 *
 * Description:
 *
 **************************************************************************************/

#import "TTWindowController.h"

#import <Carbon/Carbon.h>

@implementation TTWindowController

- (void)awakeFromNib
{
	GetMouse( &fLastMousePoint );
	
	fSystemWideElementRef	=	AXUIElementCreateSystemWide();
	fCurrentElementRef		=	NULL;

	//----- establish our secret words
	
	fSecretWordArray = [ [ NSArray arrayWithObjects:@"Mardi Gras",
		                                          @"Fat Tuesday",
												  @"New Orleans",
												  @"ironcoder",
												  @"Lint",
												  @"Bourbon St.",
												  @"Ash Wednesday",
											      @"Bouef Gras",
												  @"Courir Du Mardi Gras",
		                                          @"Doubloon",
		                                          @"King Cake",
		                                          @"Krewe",
		                                          @"Lundi Gras",
												  @"Maskers",
		                                          @"Rex",
												  @"Zulu",
		                                          @"Beads",
												  nil ] retain ];
	
	[ self doTimerUpdate ];
}

- (void) dealloc
{
	if ( fSystemWideElementRef )
	{
		CFRelease( fSystemWideElementRef );
	}
	
	if ( fCurrentElementRef )
	{
		CFRelease( fCurrentElementRef );
	}
	
	[ fSecretWordArray dealloc ];
	
	[ super dealloc ];
}



- (void) doTimerUpdate
{
	[ self updateCurrentUIElement ];
	
	[ NSTimer scheduledTimerWithTimeInterval:0.1
									  target:self
									selector:@selector(doTimerUpdate)
									userInfo:nil
									 repeats:NO ];

}

- (void) updateCurrentUIElement
{
	Point	currentMousePoint;
	
	GetMouse( &currentMousePoint );
	
	if ( ( currentMousePoint.h == fLastMousePoint.h ) && ( currentMousePoint.h == fLastMousePoint.h ) )
	{
		return;
	}
	
	fLastMousePoint = currentMousePoint;
	
	AXUIElementRef mouseElementRef	=	NULL;
	
	AXUIElementCopyElementAtPosition
		(
			fSystemWideElementRef,
			currentMousePoint.h,
			currentMousePoint.v,
			&mouseElementRef
		 );
	
	if ( !mouseElementRef )
	{
		return;
	}
	
	[ self setCurrentUIElement:mouseElementRef ];
}

- (void) setCurrentUIElement:(AXUIElementRef)newUIElement
{
	if ( fCurrentElementRef && CFEqual( fCurrentElementRef, newUIElement ) )
	{
		return;
	}
	
	if ( fCurrentElementRef )
		CFRelease( fCurrentElementRef );
	
	fCurrentElementRef = newUIElement; 
		// don't have to retain because it was created by a copy
	
	[ self updateUI ];
}

- (void) updateUI
{		
	[ fStatusTextField setStringValue:@"" ];
		
	NSString* secretString;
	
	if ( ( secretString = [ self currentElementContainsSecret ] ) != NULL )
	{
		[ fStatusTextField setStringValue:secretString ];
		
		NSBeep();
	}
}


- (NSString*) currentElementContainsSecret
{
	//----- title
	
	NSString*		titleString		=	NULL;
	
	AXUIElementCopyAttributeValue( fCurrentElementRef, kAXTitleAttribute, (CFTypeRef*)&titleString);
	
	if ( titleString && [ self stringContainsSecret:titleString ] )
	{
		NSString* secretString	=	[ self stringContainsSecret:titleString ];
	
		[ titleString release ];
		
		return secretString;
	} 
	
	//----- value
	
	CFTypeRef value;
	
	AXUIElementCopyAttributeValue( fCurrentElementRef, kAXValueAttribute, &value );
	
	if ( value && CFGetTypeID( value ) == CFStringGetTypeID() )
	{
		NSString* secretString	=	[ self stringContainsSecret:(NSString*)value ];
		
		CFRelease( value );
		
		return secretString;
	}
		
	return NULL;
}

- (NSString*) stringContainsSecret:(NSString*)string
{
	NSEnumerator*	secretEnumerator	= [ fSecretWordArray objectEnumerator ];
	NSString*		currentSecret		= NULL;
	NSRange			resultRange;
	
	while ( currentSecret = [ secretEnumerator nextObject ] )
	{
		resultRange = [ string rangeOfString:currentSecret options:NSCaseInsensitiveSearch ];
		
		if ( resultRange.location != NSNotFound )
		{
			return currentSecret;
		}
	}
	
	return NULL;
}

@end
