//
//  TwitterLifeView.m
//  TwitterLife
//
//  Created by Matthew Crandall on 4/1/07.
//  Copyright (c) 2007, MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import "TwitterLifeView.h"
#import "TwitterView.h"
#import "MCTwitter.h"
#import "ConfigPanel.h"

@implementation TwitterLifeView

static NSString * const mySaver = @"com.matthewcrandall.TwitterLife";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		ScreenSaverDefaults *defaults;
		defaults = [ScreenSaverDefaults defaultsForModuleWithName:mySaver];
				
		// Register our default values
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:0], @"dataset", [NSNumber numberWithInt:15], @"updates", @"dummy@mchotsoftware.com", @"username", @"ironcoder", @"password", nil]];
	
		_tView = [[TwitterView alloc] initWithFrame:frame];
		[self addSubview:_tView];
		[_tView setFrame:[self bounds]];
		_panel = [[ConfigPanel alloc] init];

		int delay = [defaults integerForKey:@"updates"];
		_timer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(updateData) userInfo:nil repeats:YES];
		
		[self performSelector:@selector(updateData) withObject:nil afterDelay:0.2];
        [self setAnimationTimeInterval:1/30.0];
    }
    return self;
}

- (void)dealloc {
	[_timer invalidate];
	[_panel release];
	[_tView release];
	[super dealloc];
}

- (void)updateData {

	ScreenSaverDefaults *defaults;
	TwitterRemoteCall rc = MCTwitter_publicTimeline;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:mySaver];
	int dataset = [defaults integerForKey:@"dataset"];
	
	if (dataset == 0)
		dataset = SSRandomIntBetween(1, 4);
	
	switch (dataset) {
		case 1:
			rc = MCTwitter_publicTimeline;
			break;
		case 2:
			rc = MCTwitter_friendsTimeline;
			break;
		case 3:
			rc = MCTwitter_friends;
			break;
		case 4:
			rc = MCTwitter_followers;
			break;
		default:
			rc = MCTwitter_publicTimeline;
			break;
	}

	MCTwitter *callingObject = [[MCTwitter alloc] initWithLogin:[defaults stringForKey:@"username"] password:[defaults stringForKey:@"password"] forCall:rc];
	[callingObject setDelegate:self];
	[callingObject request];


}

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
    //[_tView drawRect:rect];
}

- (void)animateOneFrame
{
	[_tView animate];
    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    return [_panel panel];;
}


- (void)twitter:(MCTwitter *)twitter didReceiveResponse:(NSArray *)response {
	NSLog([response description]);
	[_tView receivedResponse:response];
}


@end
