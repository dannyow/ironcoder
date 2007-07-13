//
//  NoTimeView.m
//  NoTime
//
//  Created by Duncan Wilcox on 7/22/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import "NoTimeView.h"
#import "NoTimeGame.h"
#import "NoTimeLayer.h"
#import "NoTimeGuy.h"
#import "NoTimeSprite.h"

@implementation NoTimeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
        // Initialization code here.
		game = [[NoTimeGame alloc] init];
		backgroundPainter = [[NoTimeLayer alloc] initWithFile:@"background.png"];
		CGSize s = [backgroundPainter size];
		[backgroundPainter setSize:CGSizeMake((600. / s.height) * s.width, 600)];
		foregroundPainter = [[NoTimeLayer alloc] initWithFile:@"foreground.png"];
		s = [foregroundPainter size];
		[foregroundPainter setSize:CGSizeMake((600. / s.height) * s.width, 600)];
		guy = [[NoTimeGuy alloc] init];
		bonus = [[NoTimeSprite alloc] initWithFiles:[NSArray arrayWithObjects:@"iron-1.png", @"iron-2.png", @"iron-3.png", @"iron-4.png", nil]];
		ircmonster = [[NoTimeSprite alloc] initWithFiles:[NSArray arrayWithObjects:@"irc-1.png", @"irc-2.png", @"irc-3.png", nil]];
		newsmonster = [[NoTimeSprite alloc] initWithFiles:[NSArray arrayWithObjects:@"news-1.png", @"news-2.png", @"news-3.png", @"news-2.png", nil]];
		loot = [[NoTimeSprite alloc] initWithFiles:[NSArray arrayWithObjects:@"loot.png", nil]];
    }
    return self;
}

- (void)dealloc
{
	[loot release];
	[newsmonster release];
	[ircmonster release];
	[bonus release];
	[guy release];
	[foregroundPainter release];
	[backgroundPainter release];
	[refreshTimer release];
	[game stop];
	[game release];
	[super dealloc];
}

#pragma mark ---- drawing


- (void)drawInitialScreen
{
	[[NSColor blackColor] set];
	NSRectFill([self bounds]);
	NSMutableParagraphStyle *parastyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[parastyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	[parastyle setAlignment:NSCenterTextAlignment];
	[parastyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"HelveticaNeue" size:60], NSFontAttributeName,
		parastyle, NSParagraphStyleAttributeName,
		[NSColor redColor], NSForegroundColorAttributeName,
		nil];
	[@"No Time!" drawInRect:NSMakeRect(0, 250, 800, 100) withAttributes:attrs];
	
	NSDictionary *smaller = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont fontWithName:@"HelveticaNeue" size:15], NSFontAttributeName,
		parastyle, NSParagraphStyleAttributeName,
		[NSColor redColor], NSForegroundColorAttributeName,
		nil];
	[[NSString stringWithUTF8String:"IronCoder \xE2\x80\x94 July 23 2006 \xE2\x80\x94 by Duncan Wilcox"] drawInRect:NSMakeRect(0, 200, 800, 50) withAttributes:smaller];
}

- (void)drawFar
{
	id point = [game valueForKey:@"farPosition"];
	if(point)
	{
		float w = [self bounds].size.width;
		float h = [self bounds].size.height;
		NSPoint f = [point pointValue];
		CGPoint pos = CGPointMake(f.x / 100. * w, f.y / 100. * h);
		[backgroundPainter tileInRect:CGRectMake(0, 0, 8000, 600) atOffset:pos];
	}
}

- (void)drawNear
{
	id point = [game valueForKey:@"nearPosition"];
	if(point)
	{
		float w = [self bounds].size.width;
		float h = [self bounds].size.height;
		NSPoint n = [point pointValue];
		CGPoint pos = CGPointMake(n.x / 100. * w, n.y / 100. * h);
		[foregroundPainter tileInRect:CGRectMake(0, 0, 8000, 600) atOffset:pos];
	}
}

- (void)drawObjects
{
	id npoint = [game valueForKey:@"nearPosition"];
	if(npoint)
	{
		float w = [self bounds].size.width;
		float h = [self bounds].size.height;
		NSPoint n = [npoint pointValue];
		if([[game valueForKey:@"showBonus1"] boolValue])
			[bonus drawAtPoint:CGPointMake((200 + n.x) / 100. * w, 55 / 100. * h)];
		if([[game valueForKey:@"showBonus2"] boolValue])
			[bonus drawAtPoint:CGPointMake((400 + n.x) / 100. * w, 55 / 100. * h)];
		if([[game valueForKey:@"showBonus3"] boolValue])
			[bonus drawAtPoint:CGPointMake((600 + n.x) / 100. * w, 55 / 100. * h)];
		if([[game valueForKey:@"showBonus4"] boolValue])
			[bonus drawAtPoint:CGPointMake((800 + n.x) / 100. * w, 55 / 100. * h)];
		if([[game valueForKey:@"showIRCMonster"] boolValue])
			[ircmonster drawAtPoint:CGPointMake((500 + n.x) / 100. * w, 40 / 100. * h)];
		if([[game valueForKey:@"showNewsMonster"] boolValue])
			[newsmonster drawAtPoint:CGPointMake((700 + n.x) / 100. * w, 40 / 100. * h)];
		[loot drawAtPoint:CGPointMake((1010 + n.x) / 100. * w, 40 / 100. * h)];
	}
}

- (void)drawCharacter
{
	id point = [game valueForKey:@"characterPosition"];
	id npoint = [game valueForKey:@"nearPosition"];
	if(point && npoint)
	{
		float w = [self bounds].size.width;
		float h = [self bounds].size.height;
		NSPoint p = [point pointValue];
		NSPoint n = [npoint pointValue];
		[[NSColor blueColor] set];
		CGPoint pos = CGPointMake((p.x + n.x) / 100. * w - [guy size].width / 2, (p.y + n.y) / 100. * h - [guy size].height / 2);
		[guy setMotion:[[game valueForKey:@"motion"] intValue]];
		[guy drawAtPoint:pos];
		[game setValue:[NSNumber numberWithInt:[guy currentMotion]] forKey:@"effectiveMotion"];
	}
}

- (void)drawOver
{
}

- (void)drawText
{
	float ta = [[game valueForKey:@"textAlpha"] floatValue];
	NSString *text = [game valueForKey:@"text"];
	if(ta > 0 && text)
	{
		float a = ta > 1 ? 1 : ta;
		NSColor *col = [NSColor colorWithDeviceWhite:1 alpha:ta > 1 ? 1 : ta];
		NSMutableParagraphStyle *parastyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[parastyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
		[parastyle setAlignment:NSCenterTextAlignment];
		[parastyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont fontWithName:@"HelveticaNeue" size:30], NSFontAttributeName,
			parastyle, NSParagraphStyleAttributeName,
			col, NSForegroundColorAttributeName,
			nil];
		[text drawInRect:NSMakeRect(0, 500 - (1 - a) * 20, 800, 80) withAttributes:attrs];
	}

	id point = [game valueForKey:@"characterPosition"];
	if(point)
	{
		NSPoint p = [point pointValue];
		NSDictionary *posattr = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont fontWithName:@"HelveticaNeue" size:10], NSFontAttributeName,
			[NSColor blackColor], NSForegroundColorAttributeName,
			nil];	
		[[NSString stringWithFormat:@"pos: %d", (int)p.x] drawInRect:NSMakeRect(10, 10, 100, 20) withAttributes:posattr];
	}
	
	float countdown = [[game valueForKey:@"countdown"] floatValue];

	if(countdown > 0)
	{
		NSColor *col = [NSColor blackColor];
		if(countdown < 5)
			col = [NSColor redColor];
		NSMutableParagraphStyle *parastyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[parastyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
		[parastyle setAlignment:NSCenterTextAlignment];
		[parastyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
		NSDictionary *cdattrs = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSFont fontWithName:@"HelveticaNeue" size:30], NSFontAttributeName,
			parastyle, NSParagraphStyleAttributeName,
			col, NSForegroundColorAttributeName,
			nil];
		[[NSString stringWithFormat:@"%.2f", countdown] drawInRect:NSMakeRect(0, 10, 800, 80) withAttributes:cdattrs];
	}
}

- (void)drawRect:(NSRect)rect
{
	if([[game valueForKey:@"play"] intValue] == 0)
	{
		[self drawInitialScreen];
		return;
	}

	[self drawFar];
	[self drawNear];
	[self drawObjects];
	[self drawCharacter];
	[self drawOver];
	[self drawText];
}

- (void)refresh:(NSTimer *)t
{
	[self setNeedsDisplay:YES];
}

- (void)awakeFromNib
{
	refreshTimer = [[NSTimer scheduledTimerWithTimeInterval:1. / 60. target:self selector:@selector(refresh:) userInfo:nil repeats:YES] retain];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

#pragma mark ---- keyboard

- (NSString *)keyFromEvent:(NSEvent *)event
{
	if([event keyCode] == 123)
		return @"left";
	if([event keyCode] == 124)
		return @"right";
	if([event keyCode] == 126)
		return @"up";
	if([event keyCode] == 125)
		return @"down";
	if([[event charactersIgnoringModifiers] characterAtIndex:0] == 'f')
		return @"fire";
	if([[event characters] characterAtIndex:0] == ' ')
		return @"jump";
	return nil;
}

- (void)keyDown:(NSEvent *)event
{
	NSString *k = [self keyFromEvent:event];
	if(k)
		[game setValue:[NSNumber numberWithInt:1] forKey:k];
}

- (void)keyUp:(NSEvent *)event
{
	NSString *k = [self keyFromEvent:event];
	if(k)
		[game setValue:[NSNumber numberWithInt:0] forKey:k];
}

@end
