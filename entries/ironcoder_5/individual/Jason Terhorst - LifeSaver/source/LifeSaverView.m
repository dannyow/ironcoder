//
//  LifeSaverView.m
//  LifeSaver
//
//  Created by Jason Terhorst on 3/30/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import "LifeSaverView.h"


@implementation LifeSaverView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
		
		lotsOfCandy = [[NSMutableArray alloc] init];
		
		// too much candy rots your teeth. don't eat it too often...
		candyTimer = [[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(createAnotherRandomLifeSaver:) userInfo:nil repeats:YES] retain];
		
		NSBundle *bundle;
		NSString *path;
		
		bundle = [NSBundle bundleForClass: [self class]];
		path = [bundle pathForResource: @"masterhand"  ofType: @"png"];
		handImage = [[NSImage alloc] initWithContentsOfFile: path];

    }
    return self;
}

- (void)startAnimation
{
	[[self window] setAcceptsMouseMovedEvents:YES];
	
    [super startAnimation];
}

- (void)createAnotherRandomLifeSaver:(NSTimer *)timer
{
	if ([lotsOfCandy count] > 100) {
		lotsOfCandy = [[NSMutableArray alloc] init];
	}
	
	
	NSPoint randomPoint = SSRandomPointForSizeWithinRect(NSMakeSize(91,75),[self bounds]);
	
	int tester = randomPoint.x;
	
	NSString * newColor;
	if (tester % 3 == 0) {
		newColor = @"green";
	} else if (tester % 2 == 0) {
		newColor = @"red";
	} else {
		newColor = @"purple";
	}
	
	Lifesaver * newCandy = [[Lifesaver alloc] init];
	[newCandy setXPos:randomPoint.x];
	[newCandy setYPos:randomPoint.y];
	[newCandy setZPos:[self bounds].size.height];
	[newCandy setColor:newColor];
	[newCandy setCaptured:NO];
	
	[lotsOfCandy addObject:newCandy];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor darkGrayColor] set];
	[NSBezierPath fillRect:rect];
	
	NSRect imageRect = NSMakeRect(0,0,[handImage size].width,[handImage size].height);
	if (handImage) {
		[handImage drawInRect:cursorRect fromRect:imageRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	if ([lotsOfCandy count] > 0) {
		int x, count = [lotsOfCandy count];
		for (x=0;x<count;x++) {
			[[lotsOfCandy objectAtIndex:x] drawInView:self];
		}
	}
	
	NSRect counterRect = NSMakeRect(10,10,200,60);
	NSFont * counterFont = [NSFont fontWithName:@"Trebuchet MS" size:45];
	NSAttributedString * counter = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d/%d",captureCounter, [lotsOfCandy count]] attributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:counterFont,[NSColor whiteColor],nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName,NSForegroundColorAttributeName,nil]]];
	[counter drawInRect:counterRect];
	
}

- (void)animateOneFrame
{
	captureCounter = 0;
	if ([lotsOfCandy count] > 0) {
		int x, count = [lotsOfCandy count];
		for (x=0;x<count;x++) {
			
			float xpos = [[lotsOfCandy objectAtIndex:x] xpos];
			float ypos = [[lotsOfCandy objectAtIndex:x] ypos];
			float zpos = [[lotsOfCandy objectAtIndex:x] zpos];
			
			NSRect spriteRect = NSMakeRect(xpos,ypos+zpos,91,75);
			if (NSIntersectsRect(spriteRect,cursorRect)) {
				if (![[lotsOfCandy objectAtIndex:x] captured]) {
					NSPoint randomPoint = SSRandomPointForSizeWithinRect(NSMakeSize(91,75),cursorRect);
					
					[[lotsOfCandy objectAtIndex:x] setXPos:randomPoint.x];
					[[lotsOfCandy objectAtIndex:x] setYPos:randomPoint.y];
					[[lotsOfCandy objectAtIndex:x] setZPos:0];
				} else {
					captureCounter++;
				}
				
				[[lotsOfCandy objectAtIndex:x] setCaptured:YES];
				
				
			}
			
			
			
			
			
			if (![[lotsOfCandy objectAtIndex:x] captured]) {
				float zposition = [[lotsOfCandy objectAtIndex:x] zpos];
				if (zposition > -[self bounds].size.height)
					zposition -= 10;
				else
					zposition = [self bounds].size.height;
				[[lotsOfCandy objectAtIndex:x] setZPos:zposition];
			}
			
		}
		
	}
	
	
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

- (void)mouseMoved:(NSEvent *)theEvent
{
	//NSLog(@"mouse");
	NSPoint mousePoint = [theEvent locationInWindow];
	cursorRect = NSMakeRect(mousePoint.x,mousePoint.y,200,200);
	
	int x, count = [lotsOfCandy count];
	for (x=0;x<count;x++) {
		
		float xpos = [[lotsOfCandy objectAtIndex:x] xpos];
		float ypos = [[lotsOfCandy objectAtIndex:x] ypos];
		
		if ([[lotsOfCandy objectAtIndex:x] captured])
		{
			if (xpos+[theEvent deltaX] > 0 && xpos+[theEvent deltaX] < [self bounds].size.width) {
				[[lotsOfCandy objectAtIndex:x] setXPos:xpos+[theEvent deltaX]];
			}
			if (ypos-[theEvent deltaY] > 0 && ypos-[theEvent deltaY] < [self bounds].size.height) {
				[[lotsOfCandy objectAtIndex:x] setYPos:ypos-[theEvent deltaY]];
			}
			
			[[lotsOfCandy objectAtIndex:x] setZPos:0];
		}
		
		if ([theEvent deltaY] > 100) {
			
			if ([[lotsOfCandy objectAtIndex:x] captured]) {
				[[lotsOfCandy objectAtIndex:x] setXPos:xpos-[theEvent deltaX]];
				[[lotsOfCandy objectAtIndex:x] setYPos:ypos+[theEvent deltaY]];
				[[lotsOfCandy objectAtIndex:x] setZPos:0];
			}
			
			[[lotsOfCandy objectAtIndex:x] setCaptured:NO];
			
		}
		
	}
	//[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	//NSBeep();
}

- (void)mouseDown:(NSEvent *)theEvent
{
	//NSBeep();
}

@end
