//
//  T3MouseLapseController.m
//  MouseLapse
//
//  Created by 23 on 7/22/06.
//  Copyright 2006 23. All rights reserved.
//

#import "T3MouseLapseController.h"
#import "T3MouseLapseView.h"

@interface T3MouseLapseController( PrivateMethods )

- (void) installTimer:(float)updateInterval;
- (void) timerUpdate:(NSTimer*)theTimer;

@end

#pragma mark -

@implementation T3MouseLapseController

- (id) init
{
	self = [ super init ];
	
	if (self != nil)
	{
	
		// Preferences defaults
		
		NSMutableDictionary *dictionary = [ NSMutableDictionary dictionary ];
		
		[ dictionary setObject:[ NSNumber numberWithFloat:100.0 ] forKey:@"UpdateInterval" ];
		[ dictionary setObject:[ NSNumber numberWithInt:100 ] forKey:@"NumberOfMarkers" ];

		NSUserDefaultsController* sharedDefaults = [ NSUserDefaultsController sharedUserDefaultsController ];
		
		[ sharedDefaults setInitialValues:dictionary ];
	
		[ sharedDefaults addObserver:self forKeyPath:@"values.NumberOfMarkers" options:nil context:nil ];	
		[ sharedDefaults addObserver:self forKeyPath:@"values.UpdateInterval" options:nil context:nil ];	

	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
					    change:(NSDictionary *)change
					   context:(void *)context
{

	NSDictionary* values = [ [ NSUserDefaultsController sharedUserDefaultsController ] values ];

	if ( [ keyPath isEqualToString:@"values.NumberOfMarkers" ] )
	{
		int count = [ [ values valueForKey:@"NumberOfMarkers" ] intValue ];
		[ fMainView setNumberOfMarkers:(int)count ];
	}
	
	if ( [ keyPath isEqualToString:@"values.UpdateInterval" ] )
	{
		float interval = [ [ values valueForKey:@"UpdateInterval" ] floatValue ];
		[ self installTimer: ( 1e-1 / interval ) ];
	}	
}									


- (void) awakeFromNib
{
	// Grab current preferences
	
	NSDictionary *values	= [ [ NSUserDefaultsController sharedUserDefaultsController ] values ];		
	float updateInterval	= [ [ values valueForKey:@"UpdateInterval" ] floatValue ];
	int numberOfMarkers	=	[ [ values valueForKey:@"NumberOfMarkers" ] intValue ];
	
	[ fMainView setNumberOfMarkers:numberOfMarkers ];
	
	[ self installTimer:( 1e-1/ updateInterval ) ];	
}

- (void) dealloc
{
	[ fTimer invalidate ];
	[ fTimer release ];
	
	[super dealloc];
}


#pragma mark -

@end

@implementation T3MouseLapseController( PrivateMethods )

- (void) installTimer:(float)updateInterval
{

	if ( fTimer )
	{
		[ fTimer invalidate ];
		[ fTimer release ];
	}
	
	fTimer = [ [ NSTimer scheduledTimerWithTimeInterval:updateInterval
												 target:self
						                       selector:@selector( timerUpdate: )
											   userInfo:nil
						                        repeats:YES ] retain ];
	
}


- (void) timerUpdate:(NSTimer*)theTimer
{
	NSPoint currentMouse = [ NSEvent mouseLocation ];
	
	[ fMainView updateWithMousePosition:currentMouse ];
}

@end


