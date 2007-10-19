//
//  Life_Screen_SaverView.m
//  Life Screen Saver
//
//  Created by Mark Christian on 31/03/07.
//  Copyright (c) 2007, ShinyPlasticBag. All rights reserved.
//

#import "Life_Screen_SaverView.h"

@implementation Life_Screen_SaverView

#pragma mark -
#pragma mark Events

- (void)reloadTimerTick
{
	[self loadRandomPattern];
}

#pragma mark -
#pragma mark Pattern functions

- (void)initPatterns
{
	NSString *filename = [[[NSBundle bundleWithIdentifier:@"com.shinyplasticbag.LifeScreenSaver"] resourcePath] stringByAppendingPathComponent:@"patterns.plist"];
	patterns = [[NSDictionary alloc] initWithContentsOfFile:filename];
	NSLog(@"Loaded %d patterns from %@", [patterns count], filename);
}

- (void)loadPattern:(NSString *)patternName
{
	//	Clear the screen
	firstDraw = YES;
	[life clear];
	
	//	Get pattern
	NSArray *pattern = [patterns objectForKey:patternName];
	if (pattern == nil) {
		NSLog(@"No pattern called %@", patternName);
		return;
	}
	NSLog(@"%@ = %@", patternName, pattern);
	
	//	Choose random origin
	srandom((unsigned long)[[NSDate date] timeIntervalSinceReferenceDate]);
	int oX, oY;
	oX = random() % [life boardWidth];
	oY = random() % [life boardHeight];
	
	//	Iterate through pattern
	CFIndex i;
	for(i = 0; i < [pattern count]; i++) {
		NSString *coords = [pattern objectAtIndex:i];
		NSRange range = [coords rangeOfString:@","];
		if (range.location == NSNotFound)
			continue;
		
		//	Get coordinates
		NSString *coordX = [coords substringToIndex:range.location];
		NSString *coordY = [coords substringFromIndex:(range.location + range.length)];
		int x = ([coordX intValue] + oX) % [life boardWidth];
		int y = ([coordY intValue] + oY) % [life boardHeight];
		[life setStateForCellAtX:x Y:y alive:YES];
	}
}

- (void)loadRandomPattern
{
	srandom((unsigned long)[[NSDate date] timeIntervalSinceReferenceDate]);
	int patternNum = random() % [patterns count];
	int i = 0;
	NSEnumerator *e = [patterns keyEnumerator];
	NSString *key;
	while (key = (NSString *)[e nextObject]) {
		if (i++ == patternNum) {
			[self loadPattern:key];
			break;
		}
	}
}

- (NSDictionary *)patterns
{
	return patterns;
}

#pragma mark -
#pragma mark Screen saver methods
- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
		
		//	Initialize
		aliveColor = [NSColor whiteColor];
		deadColor = [NSColor blackColor];
		firstDraw = YES;
		NSLog(@"Frame size is %d x %d", (int)frame.size.width, (int)frame.size.height);
		int cellSize = (frame.size.width / 32);
		life = [[MCLifeBoard alloc] initWithWidth:(frame.size.width / cellSize) andHeight:(frame.size.height / cellSize) andCellSize:cellSize];
		
		//	Initialize and load patterns
		[self initPatterns];
		[self loadRandomPattern];
    }
    return self;
}

- (void)startAnimation
{
	reloadTimer = [[NSTimer scheduledTimerWithTimeInterval:RELOAD_TIMER_INTERVAL target:self selector:@selector(reloadTimerTick) userInfo:nil repeats:YES] retain];
	[self setNeedsDisplay:YES];
    [super startAnimation];
}

- (void)stopAnimation
{
	[reloadTimer release];
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	if (firstDraw) {		
		//	Fill background
		[[NSColor blackColor] set];
		NSRectFill([self frame]);
		firstDraw = NO;
	} else {
		//	Draw cached image
		[cacheImage drawAtPoint:NSMakePoint(0, 0)];
		[cacheImage dealloc];
	}
	
	//	Advance to the next generation
	[life step];
	
	//	Variables
	NSRect curCell;
	CFIndex i;
	
	//	Draw changed cells
	for(i = 0; i < [[life diff] count]; i++) {
		//	Get cell
		NSPoint p = [(NSValue *)[[life diff] objectAtIndex:i] pointValue];
		
		//	Get state
		if ([life stateForCell:p]) {
			[aliveColor set];
		} else {
			[deadColor set];
		}
		
		//	Draw
		curCell = NSMakeRect([life cellSize] * p.x, [life cellSize] * p.y, [life cellSize] - 1, [life cellSize] - 1);
		NSRectFill(curCell);
	}
	
	//	Copy to cache
	cacheImage = [[NSBitmapImageRep alloc] initWithFocusedViewRect:rect];
}

- (void)animateOneFrame
{
	[self setNeedsDisplay:YES];
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
