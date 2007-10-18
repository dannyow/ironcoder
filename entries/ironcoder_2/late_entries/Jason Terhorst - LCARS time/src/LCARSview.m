//
//  LCARSview.m
//  lcarstime
//
//  Created by Jason Terhorst on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "LCARSview.h"


@implementation LCARSview

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        titleImage = [NSImage imageNamed:@"currenttime.jpg"];
		titleImageWhite = [NSImage imageNamed:@"currenttime_white.jpg"];
		deflectorImage = [NSImage imageNamed:@"deflector.jpg"];
		deflectorImageWhite = [NSImage imageNamed:@"deflector_white.jpg"];
		shieldImage = [NSImage imageNamed:@"shieldres.jpg"];
		shieldImageWhite = [NSImage imageNamed:@"shieldres_white.jpg"];
		warpImage = [NSImage imageNamed:@"warpfield.jpg"];
		warpImageWhite = [NSImage imageNamed:@"warpfield_white.jpg"];
		engageImage = [NSImage imageNamed:@"engage.jpg"];
		disengageImage = [NSImage imageNamed:@"disengage.jpg"];
		logoImage = [NSImage imageNamed:@"logo.png"];
		markingImage1 = [NSImage imageNamed:@"archmarking1.png"];
		markingImage2 = [NSImage imageNamed:@"archmarking2.png"];
		
		modeColor = [[NSColor colorWithDeviceRed:0.82 green:0.5	blue:0.2 alpha:1.0] retain];
		modeHighlightColor = [[NSColor colorWithDeviceRed:1.0 green:0.8 blue:0.6 alpha:1.0] retain];
		engageColor = [[NSColor colorWithCalibratedRed:0.76 green:0.34 blue:0.28 alpha:1.0] retain];
		engageHighlightColor = [[NSColor colorWithDeviceRed:1.0 green:0.4 blue:0.4 alpha:1.0] retain];
		alertColor = [[NSColor redColor] retain];
		alertHighlightColor = [[NSColor colorWithDeviceRed:1.0 green:0.2 blue:0.2 alpha:1.0] retain];
		
		deflectorButtonColor = modeColor;
		shieldButtonColor = modeColor;
		warpButtonColor = modeColor;
		engageButtonColor = engageColor;
		
		redalert = NO;
		mode = @"deflector";
		
		renderTimer = [[NSTimer scheduledTimerWithTimeInterval:0.1 
														target:self
													  selector:@selector(clock)
													  userInfo:NULL repeats:YES] retain];
		
		// time box test
		float topEdge = [self bounds].size.height;
		float rightEdge = [self bounds].size.width;
		float halfWidth = rightEdge/2;
		
		float boxSize = halfWidth-50;
		float halfHeight = topEdge/2;
		float boxBottom = halfHeight - (boxSize/2);
		
		CGRect newRect = CGRectMake(boxSize+90,boxBottom,boxSize,boxSize);
		deflectorclock = [[LCARSDeflectorClock alloc] initWithRect:(CGRect*)&newRect];
		shieldclock = [[LCARSShieldClock alloc] initWithRect:(CGRect *)&newRect];
		warpclock = [[LCARSWarpClock alloc] initWithRect:(CGRect *)&newRect];
    }
    return self;
}

- (void)clock
{
	float topEdge = [self bounds].size.height;
	float rightEdge = [self bounds].size.width;
	float halfWidth = rightEdge/2;
	
	float boxSize = halfWidth-50;
	float halfHeight = topEdge/2;
	float boxBottom = halfHeight - (boxSize/2);
	
	NSRect newRect = NSMakeRect(boxSize+90,boxBottom,boxSize,boxSize);
	[self setNeedsDisplayInRect:newRect];
}

- (void)awakeFromNib
{
	[[self window] setAcceptsMouseMovedEvents:YES];
	[self setFrame:[[[self window] contentView] bounds]];
}



- (void)mouseMoved:(NSEvent *)event
{
	
	if (redalert) {
		deflectorButtonColor = alertColor;
		shieldButtonColor = alertColor;
		warpButtonColor = alertColor;
		engageButtonColor = alertColor;
	} else {
		deflectorButtonColor = modeColor;
		shieldButtonColor = modeColor;
		warpButtonColor = modeColor;
		engageButtonColor = engageColor;
	}
	
	//NSLog(@"mouse moved");	
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	NSRect mouseRect = NSMakeRect(p.x,p.y,1,1);
	if (NSIntersectsRect(mouseRect,engageRect)) {
		[[NSCursor pointingHandCursor] set];
		engageButtonColor = engageHighlightColor;
	} else if (NSIntersectsRect(mouseRect,deflectorRect)) {
		[[NSCursor pointingHandCursor] set];
		deflectorButtonColor = modeHighlightColor;
	} else if (NSIntersectsRect(mouseRect,shieldRect)) {
		[[NSCursor pointingHandCursor] set];
		shieldButtonColor = modeHighlightColor;
	} else if (NSIntersectsRect(mouseRect,warpRect)) {
		[[NSCursor pointingHandCursor] set];
		warpButtonColor = modeHighlightColor;
	} else {
		[[NSCursor arrowCursor] set];
	}
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
	//NSLog(@"mouse down");
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	NSRect mouseRect = NSMakeRect(p.x,p.y,1,1);
	if (NSIntersectsRect(mouseRect,engageRect)) {
		if (redalert) {
			redalert = NO;
		} else {
			redalert = YES;
		}
	} else if (NSIntersectsRect(mouseRect,deflectorRect)) {
		mode = @"deflector";
	} else if (NSIntersectsRect(mouseRect,shieldRect)) {
		mode = @"shield";
	} else if (NSIntersectsRect(mouseRect,warpRect)) {
		mode = @"warp";
	}
	
	//NSLog(mode);
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (void)drawRect:(NSRect)rect {
    
	[[NSColor blackColor] set];
	[NSBezierPath fillRect:rect];
	
	float topEdge = [self bounds].size.height;
	float rightEdge = [self bounds].size.width;
	float halfWidth = rightEdge/2;
	
	archPath = [NSBezierPath bezierPath];
	[archPath moveToPoint:NSMakePoint(200,topEdge-70)];
	[archPath lineToPoint:NSMakePoint(halfWidth,topEdge-70)];
	[archPath curveToPoint:NSMakePoint(halfWidth+30, topEdge-130) 
			 controlPoint1:NSMakePoint(halfWidth+30, topEdge-70) 
			 controlPoint2:NSMakePoint(halfWidth+30, topEdge-70)];
	[archPath lineToPoint:NSMakePoint(halfWidth+30, topEdge-190)];
	[archPath lineToPoint:NSMakePoint(halfWidth+20, topEdge-190)];
	[archPath lineToPoint:NSMakePoint(halfWidth+20, topEdge-190)];
	[archPath curveToPoint:NSMakePoint(halfWidth,topEdge-170)
			 controlPoint1:NSMakePoint(halfWidth+20,topEdge-170)
			 controlPoint2:NSMakePoint(halfWidth+20,topEdge-170)];
	[archPath lineToPoint:NSMakePoint(200,topEdge-170)];
	[archPath closePath];
	
	if (redalert) {
		[alertColor set];
	} else {
		[[NSColor colorWithCalibratedRed:0.59 green:0.41 blue:0.69 alpha:1.0] set];
	}
	
	[archPath stroke];
	[archPath fill];
	
	if (redalert) {
		[alertColor set];
	} else {
		[[NSColor colorWithCalibratedRed:0.8 green:0.49 blue:0.72 alpha:1.0] set];
	}
	
	[NSBezierPath fillRect:NSMakeRect(10,topEdge-170,180,100)];
	
	if (redalert) {
		[alertColor set];
	} else {
		[[NSColor colorWithCalibratedRed:0.76 green:0.34 blue:0.28 alpha:1.0] set];
	}
	
	[NSBezierPath fillRect:NSMakeRect(halfWidth+20,10,10,topEdge-210)];
	
	
	NSBezierPath * bookendLeft = [NSBezierPath bezierPath];
	[bookendLeft moveToPoint:NSMakePoint(50,topEdge-10)];
	[bookendLeft lineToPoint:NSMakePoint(50,topEdge-50)];
	[bookendLeft lineToPoint:NSMakePoint(30,topEdge-50)];
	[bookendLeft curveToPoint:NSMakePoint(10,topEdge-30)
			 controlPoint1:NSMakePoint(10,topEdge-50)
			 controlPoint2:NSMakePoint(10,topEdge-50)];
	[bookendLeft curveToPoint:NSMakePoint(30,topEdge-10)
			 controlPoint1:NSMakePoint(10,topEdge-10)
			 controlPoint2:NSMakePoint(10,topEdge-10)];
	[bookendLeft closePath];
	
	if (redalert) {
		[alertColor set];
	} else {
		[[NSColor colorWithDeviceRed:0.82 green:0.5 blue:0.2 alpha:1.0] set];
	}
	
	[bookendLeft stroke];
	[bookendLeft fill];
	
	NSBezierPath * bookendRight = [NSBezierPath bezierPath];
	[bookendRight moveToPoint:NSMakePoint(rightEdge-50,topEdge-10)];
	[bookendRight lineToPoint:NSMakePoint(rightEdge-50,topEdge-50)];
	[bookendRight lineToPoint:NSMakePoint(rightEdge-30,topEdge-50)];
	[bookendRight curveToPoint:NSMakePoint(rightEdge-10,topEdge-30)
				controlPoint1:NSMakePoint(rightEdge-10,topEdge-50)
				controlPoint2:NSMakePoint(rightEdge-10,topEdge-50)];
	[bookendRight curveToPoint:NSMakePoint(rightEdge-30,topEdge-10)
				controlPoint1:NSMakePoint(rightEdge-10,topEdge-10)
				controlPoint2:NSMakePoint(rightEdge-10,topEdge-10)];
	[bookendRight closePath];
	[bookendRight stroke];
	[bookendRight fill];
	
	// the "bar" at the top
	[NSBezierPath fillRect:NSMakeRect(399,topEdge-50,rightEdge-459,40)];
	
	// the "engage" button at the bottom
	[engageButtonColor set];
	
	if (redalert) {
		[NSBezierPath fillRect:NSMakeRect(halfWidth+40,10,halfWidth-354,70)];
	} else {
		[NSBezierPath fillRect:NSMakeRect(halfWidth+40,10,halfWidth-265,70)];
	}
	engageRect = NSMakeRect(halfWidth+40,10,halfWidth-50,70);
	//[NSBezierPath fillRect:engageRect];
	
	
	// the left deflector button
	NSBezierPath * button1 = [NSBezierPath bezierPath];
	[button1 moveToPoint:NSMakePoint(50,topEdge-200)];
	[button1 lineToPoint:NSMakePoint(50,topEdge-270)];
	[button1 lineToPoint:NSMakePoint(30,topEdge-270)];
	[button1 curveToPoint:NSMakePoint(10,topEdge-250)
				controlPoint1:NSMakePoint(10,topEdge-270)
				controlPoint2:NSMakePoint(10,topEdge-270)];
	[button1 lineToPoint:NSMakePoint(10,topEdge-220)];
	[button1 curveToPoint:NSMakePoint(30,topEdge-200)
				controlPoint1:NSMakePoint(10,topEdge-200)
				controlPoint2:NSMakePoint(10,topEdge-200)];
	[button1 closePath];
	
	[deflectorButtonColor set];

	[button1 stroke];
	[button1 fill];
	[NSBezierPath fillRect:NSMakeRect(447,topEdge-270,halfWidth-447,70)];
	
	deflectorRect = NSMakeRect(10,topEdge-270,halfWidth-10,70);
	//[NSBezierPath fillRect:deflectorRect];
	
	
	// the left shield button
	NSBezierPath * button2 = [NSBezierPath bezierPath];
	[button2 moveToPoint:NSMakePoint(50,topEdge-280)];
	[button2 lineToPoint:NSMakePoint(50,topEdge-350)];
	[button2 lineToPoint:NSMakePoint(30,topEdge-350)];
	[button2 curveToPoint:NSMakePoint(10,topEdge-330)
				controlPoint1:NSMakePoint(10,topEdge-350)
				controlPoint2:NSMakePoint(10,topEdge-350)];
	[button2 lineToPoint:NSMakePoint(10,topEdge-300)];
	[button2 curveToPoint:NSMakePoint(30,topEdge-280)
				controlPoint1:NSMakePoint(10,topEdge-280)
				controlPoint2:NSMakePoint(10,topEdge-280)];
	[button2 closePath];
	
	[shieldButtonColor set];
	
	[button2 stroke];
	[button2 fill];
	[NSBezierPath fillRect:NSMakeRect(453,topEdge-350,halfWidth-453,70)];
	
	shieldRect = NSMakeRect(10,topEdge-350,halfWidth-10,70);
	//[NSBezierPath fillRect:shieldRect];
	
	
	// the left warp button
	NSBezierPath * button3 = [NSBezierPath bezierPath];
	[button3 moveToPoint:NSMakePoint(50,topEdge-360)];
	[button3 lineToPoint:NSMakePoint(50,topEdge-430)];
	[button3 lineToPoint:NSMakePoint(30,topEdge-430)];
	[button3 curveToPoint:NSMakePoint(10,topEdge-410)
				controlPoint1:NSMakePoint(10,topEdge-430)
				controlPoint2:NSMakePoint(10,topEdge-430)];
	[button3 lineToPoint:NSMakePoint(10,topEdge-380)];
	[button3 curveToPoint:NSMakePoint(30,topEdge-360)
				controlPoint1:NSMakePoint(10,topEdge-360)
				controlPoint2:NSMakePoint(10,topEdge-360)];
	[button3 closePath];
	
	[warpButtonColor set];
	
	[button3 stroke];
	[button3 fill];
	[NSBezierPath fillRect:NSMakeRect(472,topEdge-430,halfWidth-472,70)];
	
	warpRect = NSMakeRect(10,topEdge-430,halfWidth-10,70);
	//[NSBezierPath fillRect:warpRect];
	
	
	// bottom box
	[[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1.0] set];
	[NSBezierPath fillRect:NSMakeRect(10,62,halfWidth-10,topEdge-502)];
	
	
	// logo bar
	NSBezierPath * logoBar = [NSBezierPath bezierPath];
	[logoBar moveToPoint:NSMakePoint(50,50)];
	[logoBar lineToPoint:NSMakePoint(50,10)];
	[logoBar lineToPoint:NSMakePoint(30,10)];
	[logoBar curveToPoint:NSMakePoint(10,30)
				controlPoint1:NSMakePoint(10,10)
				controlPoint2:NSMakePoint(10,10)];
	[logoBar curveToPoint:NSMakePoint(30,50)
				controlPoint1:NSMakePoint(10,50)
				controlPoint2:NSMakePoint(10,50)];
	[logoBar closePath];
	[[NSColor darkGrayColor] set];
	[logoBar stroke];
	[logoBar fill];
	[NSBezierPath fillRect:NSMakeRect(110,10,halfWidth-110,40)];
	
	
	
	// tags
	//[[NSColor purpleColor] set];
	
	// title
	//[NSBezierPath fillRect:NSMakeRect(60,topEdge-50,329,40)];
	if (titleImage) {
		[titleImage drawInRect:NSMakeRect(60,topEdge-50,329,40)
					  fromRect:NSMakeRect(0,0,329,40)
					 operation:NSCompositeSourceOver
					  fraction:1.0];
	}
	
	// deflector
	//[NSBezierPath fillRect:NSMakeRect(60,topEdge-270,377,70)];
	if (deflectorImage) {
		[deflectorImage drawInRect:NSMakeRect(60,topEdge-270,377,70)
						  fromRect:NSMakeRect(0,0,377,70)
						 operation:NSCompositeSourceOver
						  fraction:1.0];
	}
	
	// shield
	//[NSBezierPath fillRect:NSMakeRect(60,topEdge-350,383,70)];
	if (shieldImage) {
		[shieldImage drawInRect:NSMakeRect(60,topEdge-350,383,70)
					   fromRect:NSMakeRect(0,0,383,70)
					  operation:NSCompositeSourceOver
					   fraction:1.0];
	}
	
	// warp
	//[NSBezierPath fillRect:NSMakeRect(60,topEdge-430,402,70)];
	if (warpImage) {
		[warpImage drawInRect:NSMakeRect(60,topEdge-430,402,70)
					 fromRect:NSMakeRect(0,0,402,70)
					operation:NSCompositeSourceOver
					 fraction:1.0];
	}
	
	// engage
	//[NSBezierPath fillRect:NSMakeRect(rightEdge-215,10,205,70)];
	if (redalert) {
		if (disengageImage) {
			[disengageImage drawInRect:NSMakeRect(rightEdge-304,10,294,70)
							  fromRect:NSMakeRect(0,0,294,70)
							 operation:NSCompositeSourceOver
							  fraction:1.0];
		}
	} else {
		if (engageImage) {
			[engageImage drawInRect:NSMakeRect(rightEdge-215,10,205,70)
						   fromRect:NSMakeRect(0,0,205,70)
						  operation:NSCompositeSourceOver
						   fraction:1.0];
		}
	}
	 
	
	// logo
	//[NSBezierPath fillRect:NSMakeRect(60,10,40,40)];
	if (logoImage) {
		[logoImage drawInRect:NSMakeRect(60,10,40,40)
					 fromRect:NSMakeRect(0,0,40,40)
					operation:NSCompositeSourceOver
					 fraction:1.0];
	}
	
	if (markingImage1) {
		[markingImage1 drawInRect:NSMakeRect(110,topEdge-170,70,100)
						 fromRect:NSMakeRect(0,0,70,100)
						operation:NSCompositeSourceOver
						 fraction:1.0];
	}
	if (markingImage2) {
		[markingImage2 drawInRect:NSMakeRect(210,topEdge-170,70,100)
						 fromRect:NSMakeRect(0,0,70,100)
						operation:NSCompositeSourceOver
						 fraction:1.0];
	}
	
	
	// time box test
	float boxSize = halfWidth-50;
	float halfHeight = topEdge/2;
	float boxBottom = halfHeight - (boxSize/2);
	//[NSBezierPath fillRect:NSMakeRect(boxSize+90,boxBottom,boxSize,boxSize)];
	NSRect newRect = NSMakeRect(boxSize+90,boxBottom,boxSize,boxSize);
	
	NSGraphicsContext *nsgc = [NSGraphicsContext currentContext];
    CGContextRef gc = [nsgc graphicsPort];
	
	if ([mode isEqualToString:@"deflector"]) {
		[deflectorclock drawInContext:gc withRect:(CGRect*)&newRect];
	} else if ([mode isEqualToString:@"shield"]) {
		[shieldclock drawInContext:gc withRect:(CGRect*)&newRect];
	} else if ([mode isEqualToString:@"warp"]) {
		[warpclock drawInContext:gc withRect:(CGRect*)&newRect];
	}
	
}

@end
