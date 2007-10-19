//
//  TwitterBugView.m
//  TwitterBug
//
//  Created by Colin Gislason on 31/03/07.
//  Copyright (c) 2007, Colin Gislason. All rights reserved.
//

#import "TwitterBugView.h"

#define IMAGE_MARGIN 5

@implementation TwitterBugView

static NSString * const TwitterBug = @"com.cgislason.TwitterBug";
static NSString * const MessageDelayPreference = @"MessageDelay";
static NSString * const MessageSizeWidthPreference = @"MessageSizeWidth";
static NSString * const MessageSizeHeightPreference = @"MessageSizeHeight";
static NSString * const MessageFontPreference = @"MessageFont";
static NSString * const FontColorPreference = @"FontColor";
static NSString * const FontSizePreference = @"FontSize";
static NSString * const ShowFriendsTimelinePreference = @"ShowFriendsTimeline";
static NSString * const UserNamePreference = @"UserName";
static NSString * const PasswordPreference = @"Password";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		ScreenSaverDefaults *defaults;
		defaults = [ScreenSaverDefaults defaultsForModuleWithName:TwitterBug];
		
		isPreviewMode = isPreview;
		
		// Register our default values
		NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor whiteColor]];
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
			@"4", MessageDelayPreference,
			@"600", MessageSizeWidthPreference,
			@"400", MessageSizeHeightPreference,
			@"Helvetica", MessageFontPreference,
			@"20", FontSizePreference,
			@"NO", ShowFriendsTimelinePreference,
			@"", UserNamePreference,
			@"", PasswordPreference,
			colorAsData, FontColorPreference,
			nil]];
		
		// Register the defaults
		[self initDefaults];
		
        [self setAnimationTimeInterval:1/frameRate];
		framesPassed = 0;
				
		messageQueue = [[TwitterQueue alloc] initAndFillShowFriendsTimeline:showFriendsTimeline 
																   userName:userName 
																   password:password];
		[messageQueue retain];
    }
    return self;
}

- (void)initDefaults
{
	ScreenSaverDefaults *defaults;
	
    defaults = [ScreenSaverDefaults defaultsForModuleWithName:TwitterBug];
	
	// Number of frames per second
	frameRate = 30.0;
	
	// Delay in seconds
	messageDelay = [defaults integerForKey:MessageDelayPreference];
	// How many frames is the message delay?
	frameDelay = frameRate * messageDelay;
	
	// rect size
	messageSize.width = [defaults floatForKey:MessageSizeWidthPreference];
	messageSize.height = [defaults floatForKey:MessageSizeHeightPreference];
	
	// Friends list
	showFriendsTimeline = [defaults boolForKey:ShowFriendsTimelinePreference];
	[userName release];
	userName = [defaults stringForKey:UserNamePreference];
	[userName retain];
	[password release];
	password = [defaults stringForKey:PasswordPreference];
	[password retain];
		
	// set up the font
	[messageFont release];
	messageFont = [defaults stringForKey:MessageFontPreference];
	[messageFont retain];
	
	NSData *colorAsData = [defaults objectForKey:FontColorPreference];	
	[fontColor release];
	fontColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
	[fontColor retain];
	
	fontSize = [defaults integerForKey:FontSizePreference];
	
	if(isPreviewMode)
	{
		fontSize = fontSize / 2;
		messageSize.width = messageSize.width / 2;
		messageSize.height = messageSize.height / 2;
	}
		
	// Set up the string attributes
	stringAttributes = [[NSMutableDictionary alloc] init];
	NSFont *font = [NSFont fontWithName:messageFont size:fontSize];	
	[stringAttributes setObject:font 
						 forKey:NSFontAttributeName];
	[stringAttributes setObject:fontColor 
						 forKey:NSForegroundColorAttributeName];	
}

- (void)dealloc
{
	NSLog(@"dealloc in TwitterQueue");
	[super dealloc];
	[messageQueue release];
	[fontColor release];
	[userName release];
	[password release];
	[stringAttributes release];
	[currentMessage release];
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
    [super drawRect:rect];
	
	// Check if the message has been up for the length of the delay
	framesPassed++;
	if(framesPassed % frameDelay == 0)
	{
		framesPassed = 0;
	
		if([messageQueue count] == 0)
		{
			[messageQueue refillQueue];
		}
		
		// get the next message
		[currentMessage release];
		currentMessage = [messageQueue nextMessage];
		messagePosition = [self randomPoint];
		[currentMessage retain];
	}
	
	// fade based on the delay
	float alpha = 1.0 - ( (float)framesPassed / (float)frameDelay );
	[self drawMessage:currentMessage withAlpha:alpha];
}

- (void)animateOneFrame
{
	[self setNeedsDisplay:TRUE];
    return;
}

- (void)drawMessage:(TwitterMessage*)drawMessage withAlpha:(float)alpha
{
	// Get the image url
	NSImage *twitterImage;
	NSURL *twitterImageURL;
	twitterImageURL = [[drawMessage user] profileImageURL];
	twitterImage = [[NSImage alloc] initWithContentsOfURL:twitterImageURL];
	
	// Position the image
	NSSize twitterImageSize = [twitterImage size];
	int imageMargin = twitterImageSize.width + IMAGE_MARGIN;
	NSRect messageRect = [self textRectWithMargin:imageMargin];
	
	// Choose the place to draw the image
	NSRect drawingRect;
	drawingRect.origin = messagePosition;
	drawingRect.size = twitterImageSize;
	// And the size of the image
	NSRect imageRect;
	imageRect.origin = NSZeroPoint;
	imageRect.size = twitterImageSize;
	
	// Draw the image
	[twitterImage drawInRect:drawingRect fromRect:imageRect operation:NSCompositeSourceOver fraction:alpha];
	
	// Move the text over beside the image
	
	
	// Draw the text
	[stringAttributes setObject:[fontColor colorWithAlphaComponent:alpha]
						 forKey:NSForegroundColorAttributeName];
	
	NSString *curMessage = [[drawMessage user] screenName];
	curMessage = [curMessage stringByAppendingString:@" says:\n"];	
	curMessage = [curMessage stringByAppendingString:[drawMessage text]];
	
	[curMessage drawInRect:messageRect withAttributes:stringAttributes];
	
	[twitterImage release];
	
}

- (NSRect)textRectWithMargin:(float)margin
{
	NSRect textRect;
	NSSize size;
	
	size.width = messageSize.width - margin;
	size.height = messageSize.height;
	
	textRect.origin = messagePosition;
	textRect.origin.x = textRect.origin.x + margin;
	textRect.size = size;
	
	return textRect;
}

- (NSPoint)randomPoint
{
	NSRect bounds = [self bounds];
	NSPoint randomPoint;
	randomPoint.x = SSRandomIntBetween(0,bounds.size.width - messageSize.width);
	randomPoint.y = SSRandomIntBetween(0,bounds.size.height - messageSize.height);
	return randomPoint;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

- (NSWindow *)configureSheet
{
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:TwitterBug];
	
	if (!configSheet)
	{
		if (![NSBundle loadNibNamed:@"Preferences" owner:self]) 
		{
			NSLog( @"Failed to load configure sheet." );
		}
	}	
	
	// set the defaults
	[messageDelayOption setIntValue:[defaults integerForKey:MessageDelayPreference]];
	[messageSizeWidthOption setFloatValue:[defaults floatForKey:MessageSizeWidthPreference]];
	[messageSizeHeightOption setFloatValue:[defaults floatForKey:MessageSizeHeightPreference]];
	[messageFontOption setStringValue:[defaults objectForKey:MessageFontPreference]];
	[fontSizeOption setIntValue:[defaults integerForKey:FontSizePreference]];
	[showFriendsTimelineOption setState:[defaults boolForKey:ShowFriendsTimelinePreference]];
	[userNameOption setStringValue:[defaults objectForKey:UserNamePreference]];
	[passwordOption setStringValue:[defaults objectForKey:PasswordPreference]];
	
	// Color needs to be unarchived
	NSData *colorAsData = [defaults objectForKey:FontColorPreference];
	[fontColorOption setColor:[NSKeyedUnarchiver unarchiveObjectWithData:colorAsData]];
		
	return configSheet;
}

- (IBAction) okClick: (id)sender
{
	
	// Save the settings to disk
	ScreenSaverDefaults *defaults;
	defaults = [ScreenSaverDefaults defaultsForModuleWithName:TwitterBug];
	
	// Save the defaults
	[defaults setInteger:[messageDelayOption intValue]
				  forKey:MessageDelayPreference];
	[defaults setFloat:[messageSizeWidthOption floatValue]
				  forKey:MessageSizeWidthPreference];
	[defaults setFloat:[messageSizeHeightOption floatValue]
				  forKey:MessageSizeHeightPreference];	
	[defaults setObject:[messageFontOption stringValue]
				 forKey:MessageFontPreference];
	[defaults setInteger:[fontSizeOption intValue]
				  forKey:FontSizePreference];
	[defaults setBool:[showFriendsTimelineOption state]
			   forKey:ShowFriendsTimelinePreference];
	[defaults setObject:[userNameOption stringValue]
				 forKey:UserNamePreference];
	[defaults setObject:[passwordOption stringValue] 
				 forKey:PasswordPreference];
	
	// Now do the color differently, need to archive it
	NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:[fontColorOption color]];
	[defaults setObject:colorAsData forKey:FontColorPreference];
	
	[defaults synchronize];
	
	[self initDefaults];
	
	// Now refill the queue
	[messageQueue removeAllObjects];
	[messageQueue refillQueue];
		
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction) cancelClick: (id)sender
{
	// Close the sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}

@end
