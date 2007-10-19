//
//  LifeLikeView.m
//  LifeLike
//
//  Created by Ian Gowen on 3/31/07.
//  Copyright (c) 2007, Ian Gowen. All rights reserved.
//

#import "LifeLikeView.h"


@implementation LifeLikeView

static NSString * const lifeLikeModuleName = @"cc.gowen.lifelike";
static unsigned int currentFrame = 0;

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
		
		viewFrame = frame;
		
		/* Set up our defaults */
		ScreenSaverDefaults *defaults;
		defaults = [ScreenSaverDefaults defaultsForModuleWithName:lifeLikeModuleName];
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
			@"NO", @"survival0",
			@"NO", @"survival1",
			@"YES", @"survival2",
			@"YES", @"survival3",
			@"NO", @"survival4",
			@"NO", @"survival5",
			@"NO", @"survival6",
			@"NO", @"survival7",
			@"NO", @"survival8",
			@"NO", @"birth0",
			@"NO", @"birth1",
			@"NO", @"birth2",
			@"YES", @"birth3",
			@"NO", @"birth4",
			@"NO", @"birth5",
			@"NO", @"birth6",
			@"NO", @"birth7",
			@"NO", @"birth8",
			@"10", @"randomness",
			@"20", @"pixelSize",
			nil]];
		
		/* Make these configurable later */
		pixelSize = [defaults integerForKey:@"pixelSize"];
		speed = 15.0;
        [self setAnimationTimeInterval:1/speed];
		
    }
	
    return self;
}

/* god, this is awful. */
- (NSSet*)birthRules
{
	ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:lifeLikeModuleName];
	NSMutableSet *ret = [NSMutableSet setWithCapacity:8];
	if ([defaults boolForKey:@"birth0"]) [ret addObject:[NSNumber numberWithInt:0]];
	if ([defaults boolForKey:@"birth1"]) [ret addObject:[NSNumber numberWithInt:1]];
	if ([defaults boolForKey:@"birth2"]) [ret addObject:[NSNumber numberWithInt:2]];
	if ([defaults boolForKey:@"birth3"]) [ret addObject:[NSNumber numberWithInt:3]];
	if ([defaults boolForKey:@"birth4"]) [ret addObject:[NSNumber numberWithInt:4]];
	if ([defaults boolForKey:@"birth5"]) [ret addObject:[NSNumber numberWithInt:5]];
	if ([defaults boolForKey:@"birth6"]) [ret addObject:[NSNumber numberWithInt:6]];
	if ([defaults boolForKey:@"birth7"]) [ret addObject:[NSNumber numberWithInt:7]];
	if ([defaults boolForKey:@"birth8"]) [ret addObject:[NSNumber numberWithInt:8]];
	return ret;
}

/* this too */
- (NSSet*)survivalRules
{	
	ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:lifeLikeModuleName];
	NSMutableSet *ret = [NSMutableSet setWithCapacity:8];
	if ([defaults boolForKey:@"survival0"]) [ret addObject:[NSNumber numberWithInt:0]];
	if ([defaults boolForKey:@"survival1"]) [ret addObject:[NSNumber numberWithInt:1]];
	if ([defaults boolForKey:@"survival2"]) [ret addObject:[NSNumber numberWithInt:2]];
	if ([defaults boolForKey:@"survival3"]) [ret addObject:[NSNumber numberWithInt:3]];
	if ([defaults boolForKey:@"survival4"]) [ret addObject:[NSNumber numberWithInt:4]];
	if ([defaults boolForKey:@"survival5"]) [ret addObject:[NSNumber numberWithInt:5]];
	if ([defaults boolForKey:@"survival6"]) [ret addObject:[NSNumber numberWithInt:6]];
	if ([defaults boolForKey:@"survival7"]) [ret addObject:[NSNumber numberWithInt:7]];
	if ([defaults boolForKey:@"survival8"]) [ret addObject:[NSNumber numberWithInt:8]];
	return ret;
}

- (void)dealloc
{
	/* Get rid of both grids */
	[oldGrid release];
	[grid release];
	[super dealloc];
}

- (void)startAnimation
{
    [super startAnimation];
	
	currentFrame = 0;
	birthConditions = [[self birthRules] retain];
	sustainConditions = [[self survivalRules] retain];
	
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:lifeLikeModuleName];
	pixelSize = [defaults integerForKey:@"pixelSize"];
	
	/* allocate the grid */
	grid = [[IG2DArray alloc] initWithWidth:viewFrame.size.width/pixelSize height:viewFrame.size.height/pixelSize];
	oldGrid = [[IG2DArray alloc] initWithWidth:viewFrame.size.width/pixelSize height:viewFrame.size.height/pixelSize];	
	
	/* Initialize the grid with randomly colored, randomly chosen cells */
	int i,j;
	for (i = 0; i < [grid height]; i++)
	{
		for (j = 0; j < [grid width]; j++)
		{
			if (SSRandomIntBetween(0,4) == 1)
				[grid replaceObjectAtRow:i column:j withObject:[NSColor colorWithCalibratedRed:SSRandomIntBetween(0,1) 
																							green:SSRandomIntBetween(0,1)
																							 blue:SSRandomIntBetween(0,1) 
																							alpha:1.0]];
		}
	}
	[self setNeedsDisplay:YES];

}

- (void)stopAnimation
{
    [super stopAnimation];
	[birthConditions release];
	[sustainConditions release];
	birthConditions = nil;
	sustainConditions = nil;
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
	int i,j;
	/* Redraw cells that have changed since the last generation */
	for (i = 0; i < [grid height]; i++)
	{
		for (j = 0; j < [grid width]; j++)
		{
			id color = [grid objectAtRow:i column:j];
			id color2 = [oldGrid objectAtRow:i column:j];
			if ((color != nil && color2 == nil) || (color != nil && color2 != nil)){
				[color set];
				[[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(j*pixelSize,i*pixelSize,pixelSize,pixelSize)] fill];
			}

		}
	}
}

/* Run one step of the automaton */
/* This is not optimized at all, and is incredibly slow */
- (void)nextGeneration
{
	int i,j;
	IG2DArray *newGrid = oldGrid;
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:lifeLikeModuleName];
	for (i = 0; i < [grid height]; i++)
	{
		for (j = 0; j < [grid width]; j++)
		{
			NSNumber* neighbors = [grid neighborsAtRow:i column:j];
			id color;
			// If the square is full, check sustain conditions
			if (color = [grid objectAtRow:i column:j]) {
				if ([sustainConditions containsObject:neighbors]) {
					[newGrid replaceObjectAtRow:i column:j withObject:color];
				} else [newGrid replaceObjectAtRow:i column:j withObject:nil];
			} else {
				// Check birth conditions
				if ([birthConditions containsObject:neighbors]) {
					// Get average color of parents
					float r = 0.0,g = 0.0,b = 0.0,c = 1.0;
					// If there are no neighbors, pick a random color
					if ([neighbors intValue] == 0) {
						r = SSRandomIntBetween(0,1);
						g = SSRandomIntBetween(0,1);
						b = SSRandomIntBetween(0,1);
					} else {
						NSArray* parents = [grid getNeighborsAtRow:i column:j];
						NSColor* next;
						NSEnumerator *parentEnum = [parents objectEnumerator];
						while (next = [parentEnum nextObject])
						{
							r += [next redComponent];
							g += [next greenComponent];
							b += [next blueComponent];
						}
						c = [parents count];
					}
						
					[newGrid replaceObjectAtRow:i column:j withObject:[NSColor colorWithCalibratedRed:r/c
																								green:g/c
																								 blue:b/c 
																								alpha:1.0]];
				} else [newGrid replaceObjectAtRow:i column:j withObject:nil];
			}
		}
	}
	/* Insert random cells */
	if (currentFrame % 10 == 0) {
		for (i = 0; i < [defaults integerForKey:@"randomness"]; i++) {
			int x,y;
			x = SSRandomIntBetween(0,[grid width]);
			y = SSRandomIntBetween(0,[grid height]);
			[newGrid replaceObjectAtRow:y column:x withObject:[NSColor colorWithCalibratedRed:SSRandomIntBetween(0,1) 
																						green:SSRandomIntBetween(0,1)
																						 blue:SSRandomIntBetween(0,1) 
																						alpha:1.0]];
		}
		currentFrame = 0;
	}
	/* swap new and old */
	oldGrid = grid;
	grid = newGrid;
}

- (void)animateOneFrame
{
	[self nextGeneration];
	[self setNeedsDisplay:YES];
	currentFrame++;

    return;
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{

	
	if (!configSheet) {
		if (![NSBundle loadNibNamed:@"ConfigureSheet" owner:self]) { NSLog(@"Couldn't load configure sheet."); }
	}
	ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:lifeLikeModuleName];
	
	[survival0 setState:[defaults boolForKey:@"survival0"]];
	[survival1 setState:[defaults boolForKey:@"survival1"]];
	[survival2 setState:[defaults boolForKey:@"survival2"]];
	[survival3 setState:[defaults boolForKey:@"survival3"]];
	[survival4 setState:[defaults boolForKey:@"survival4"]];
	[survival5 setState:[defaults boolForKey:@"survival5"]];
	[survival6 setState:[defaults boolForKey:@"survival6"]];
	[survival7 setState:[defaults boolForKey:@"survival7"]];
	[survival8 setState:[defaults boolForKey:@"survival8"]];
	[birth0 setState:[defaults boolForKey:@"birth0"]];
	[birth1 setState:[defaults boolForKey:@"birth1"]];
	[birth2 setState:[defaults boolForKey:@"birth2"]];
	[birth3 setState:[defaults boolForKey:@"birth3"]];
	[birth4 setState:[defaults boolForKey:@"birth4"]];
	[birth5 setState:[defaults boolForKey:@"birth5"]];
	[birth6 setState:[defaults boolForKey:@"birth6"]];
	[birth7 setState:[defaults boolForKey:@"birth7"]];
	[birth8 setState:[defaults boolForKey:@"birth8"]];	
	[randomness setIntValue:[defaults integerForKey:@"randomness"]];
	[randomnessField setIntValue:[defaults integerForKey:@"randomness"]];
	[pixelSizeSlider setIntValue:[defaults integerForKey:@"pixelSize"]];

	return configSheet;
}

- (IBAction)cancelClick:(id)sender
{
	[[NSApplication sharedApplication] endSheet:configSheet];
}

- (IBAction) okClick:(id)sender
{
	// Save options
	ScreenSaverDefaults* defaults = [ScreenSaverDefaults defaultsForModuleWithName:lifeLikeModuleName];
	[defaults setBool:[survival0 state] forKey:@"survival0"];
	[defaults setBool:[survival1 state] forKey:@"survival1"];
	[defaults setBool:[survival2 state] forKey:@"survival2"];
	[defaults setBool:[survival3 state] forKey:@"survival3"];
	[defaults setBool:[survival4 state] forKey:@"survival4"];
	[defaults setBool:[survival5 state] forKey:@"survival5"];
	[defaults setBool:[survival6 state] forKey:@"survival6"];
	[defaults setBool:[survival7 state] forKey:@"survival7"];
	[defaults setBool:[survival8 state] forKey:@"survival8"];
	[defaults setBool:[birth0 state] forKey:@"birth0"];
	[defaults setBool:[birth1 state] forKey:@"birth1"];
	[defaults setBool:[birth2 state] forKey:@"birth2"];
	[defaults setBool:[birth3 state] forKey:@"birth3"];
	[defaults setBool:[birth4 state] forKey:@"birth4"];
	[defaults setBool:[birth5 state] forKey:@"birth5"];
	[defaults setBool:[birth6 state] forKey:@"birth6"];
	[defaults setBool:[birth7 state] forKey:@"birth7"];
	[defaults setBool:[birth8 state] forKey:@"birth8"];
	[defaults setInteger:[randomness intValue] forKey:@"randomness"];
	[defaults setInteger:[pixelSizeSlider intValue] forKey:@"pixelSize"];
	// Close sheet
	[[NSApplication sharedApplication] endSheet:configSheet];
}

@end
