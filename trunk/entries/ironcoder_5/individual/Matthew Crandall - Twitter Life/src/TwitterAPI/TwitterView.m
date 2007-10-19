//
//  TwitterView.m
//  TwitterAPI
//
//  Created by Matthew Crandall on 3/31/07.
//  Copyright 2007 MC Hot Software : http://mchotsoftware.com. All rights reserved.
//

#import "TwitterView.h"
#import "MCAnimatedText.h"
#import "MCAnimatedImage.h"

@implementation TwitterView



- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		_drawingObjects = [[NSMutableArray array] retain];
		_animator = [NSTimer scheduledTimerWithTimeInterval:1/30 target:self selector:@selector(animate:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc {
	
	[_animator invalidate];
	[_drawingObjects release];
	[super dealloc];
}

- (void)awakeFromNib {

}

- (void)animate {
	[self animate:nil];
}

- (void)fadeAll:(id)sender {

	unsigned int i;
	for (i = 0; i < [_drawingObjects count]; i++) {
		[[_drawingObjects objectAtIndex:i] setFading:YES];
	}

}

- (void)receivedResponse:(NSArray *)response {

	//NSLog([response description]);

	float buffer = 40.0f;
	float startingWidth = [self bounds].size.width;
	float startingHeight = [self bounds].size.height;

	[self fadeAll:nil];
	
	
	/*
	MCAnimatedText *test = [[[MCAnimatedText alloc] init] autorelease];
	[test setText:@"This is my test text."];
	[test setWall:NSMakePoint(100, 100)];
	MCAnimatedImage *iTest = [[[MCAnimatedImage alloc] init] autorelease];
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[[NSURL URLWithString:@"http://mchotsoftware.com/tangle/images/icon.png"] resourceDataUsingCache:YES]];
	NSImage *image = [[[NSImage alloc] initWithSize:[imageRep size]] autorelease];
	[image addRepresentation:imageRep];
	[iTest setImage:image];
	[iTest setWall:NSMakePoint(100, 200)];
	[iTest setLocation:NSMakePoint(4000, 200)];
	[_drawingObjects addObject:test];
	[_drawingObjects addObject:iTest];
	*/
	
	unsigned int i;
	float addHeight = 0;
	float delay = 0;
	
	for (i = 0; i < [response count]; i++) {
		float nameSize = 18.0;
		float textSize = 14.0;

		if (i == 0) {
			nameSize = 36.0;
			textSize = 20.0;
		}
	
		//image
		MCAnimatedImage *photo = [[[MCAnimatedImage alloc] init] autorelease];
		NSBitmapImageRep *imageRep = [[[NSBitmapImageRep alloc] initWithData:[[NSURL URLWithString:[[[response objectAtIndex:i] objectForKey:@"user"] objectForKey:@"profile_image_url"]] resourceDataUsingCache:YES]] autorelease];
		NSImage *image = [[[NSImage alloc] initWithSize:[imageRep size]] autorelease];
		[image addRepresentation:imageRep];
		[photo setImage:image];
		[photo setLocation:NSMakePoint(startingWidth + delay, startingHeight - buffer  - [image size].height - addHeight)];
		[photo setWall:NSMakePoint(buffer, startingHeight)];
	
		[image setSize:NSMakeSize(50, 50)];  //line things up to make them easier to read.
	
		if (startingHeight - buffer  - [image size].height - addHeight < 0)
			return;
		
		int hours, minutes;
		NSCalendarDate *postDate = [NSCalendarDate dateWithNaturalLanguageString:[[[response objectAtIndex:i] objectForKey:@"status"] objectForKey:@"created_at"]];
		[[NSCalendarDate date] years:NULL months:NULL days:NULL hours:&hours minutes:&minutes seconds:NULL sinceDate:postDate]; 
		//NSLog(@"hours old:%i minutes old:%i", hours, minutes);
		
		NSString *saidWhen = [NSString stringWithFormat:@"said %i hour(s) and %i minute(s) ago", hours, minutes];
		
		if (hours == 0 && minutes == 0)
			saidWhen = [NSString stringWithString:@"said just now"];
		
		
		//name
		MCAnimatedText *name = [[[MCAnimatedText alloc] init] autorelease];
		[name setText:[[[response objectAtIndex:i] objectForKey:@"user"] objectForKey:@"name"]];
		[name setSize:nameSize];
		[name setLocation:NSMakePoint(startingWidth + [image size].width + 5 + delay, startingHeight - buffer  - [name bounds].size.height - addHeight)];
		[name setWall:NSMakePoint(buffer + [image size].width + 5, startingHeight)];
		
		MCAnimatedText *said = [[[MCAnimatedText alloc] init] autorelease];
		[said setText:saidWhen];
		[said setSize:12.0];
		[said setLocation:NSMakePoint(startingWidth + [image size].width + 5 + delay + 15 + [name bounds].size.width, startingHeight - buffer  - [said bounds].size.height / 2 - [name bounds].size.height / 2  - addHeight)];
		[said setWall:NSMakePoint(buffer + [image size].width + 5 + 15 + [name bounds].size.width, startingHeight)];
		addHeight += [image size].height + 5;

		//status
		MCAnimatedText *status = [[[MCAnimatedText alloc] init] autorelease];
		[status setText:[[[response objectAtIndex:i] objectForKey:@"status"] objectForKey:@"text"]];
		[status setSize:textSize];
		[status setLocation:NSMakePoint(startingWidth + delay, startingHeight - buffer  - [status bounds].size.height - addHeight)];
		[status setWall:NSMakePoint(buffer, startingHeight)];
		
		
		if (startingHeight - buffer  - [status bounds].size.height - addHeight < 0)
			return;
		
		if (i == 0) {
			delay += 500;
			addHeight += 20.00;
			addHeight += [status bounds].size.height + 20.0;
		} else {
			[status setLocation:NSMakePoint(startingWidth + [image size].width + 5 +  delay, startingHeight - buffer  - [name bounds].size.height - addHeight + [image size].height - [status bounds].size.height)];
			[status setWall:NSMakePoint(buffer + [image size].width + 5, startingHeight)];
			if ([status bounds].size.height + [name bounds].size.height > [image size].height)
				addHeight += [status bounds].size.height + 5 - [name bounds].size.height;
			delay += 40;
		}
		
		[_drawingObjects addObject:name];
		[_drawingObjects addObject:said];
		[_drawingObjects addObject:photo];
		[_drawingObjects addObject:status];
	}

}

- (void)animate:(id)sender {
	int i;
	for (i = 0; i < [_drawingObjects count]; i++) {
		[[_drawingObjects objectAtIndex:i] animate];
	}
	
	//remove objects that have opacity 0.
	for (i = [_drawingObjects count] - 1; i >= 0; i--) {
		if ([[_drawingObjects objectAtIndex:i] opacity] < 0)
			[_drawingObjects removeObjectAtIndex:i];
	}
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
	//I'd like some kind of black to grey gradient here.  We'll go with just drawing black for now.
	[[NSColor blackColor] set];
	NSRectFill(rect);
	

	unsigned int i;
	for (i = 0; i < [_drawingObjects count]; i++) {
		if (NSIntersectsRect(rect, [[_drawingObjects objectAtIndex:i] bounds]))
			[(MCAnimatedObject *)[_drawingObjects objectAtIndex:i] draw];
	}
}

@end
