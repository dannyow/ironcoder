//
//  DVContentView.m
//  DrunkVision
//
//  Created by Colin Barrett on 3/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DVContentView.h"

#define DV_VIEW_FONT_NAME @"Lucida Grande"
#define DV_VIEW_FONT_SIZE 48
#define DV_VIEW_FONT_COLOR [NSColor yellowColor]

#define DV_VIEW_STROKE_WIDTH 7.5
#define DV_VIEW_STROKE_COLOR [NSColor purpleColor]

#define DV_VIEW_BACKGROUND_COLOR [NSColor greenColor]

@implementation DVContentView

//This really only needs to be created once, ever.
static NSDictionary *attrs = nil;

/**
 * @brief Initalize, the NSView way.
 *
 * @param frame Our initial size and position.
 * @return An instantated object. May not be the same as the original reciever.
 */
- (id)initWithFrame:(NSRect)frame {
	//Standard NSView constructor
    self = [super initWithFrame:frame];
    if (self) {
		//Trying to compare strings to nils is bad times. Use an empty string.
		windowTitle = @"";
		appName = @"";
		_cachedTrimmedWindowTitle = @"";
		
		//Set NSBezierPath to have a larger stroke.
		[NSBezierPath setDefaultLineWidth:DV_VIEW_STROKE_WIDTH];

		
		//If we haven't set up the attrs dictionary, set it up (it would be more mysterious if it WAS set up).
		if (!attrs) {
			/*
			 * Create an attributes array to pass to NSAttributedString.
			 *   - Lucidia Grande is a font everyone has, and looks nice at 48pt
			 *   - Yellow (technically gold) is one of the Mardis Gras colors
			 */
			attrs = [[NSDictionary alloc] initWithObjectsAndKeys:
				[NSFont fontWithName:DV_VIEW_FONT_NAME size:DV_VIEW_FONT_SIZE], NSFontAttributeName, 
				DV_VIEW_FONT_COLOR, NSForegroundColorAttributeName,
				nil];
		}
	}
	//Return ourself, but remember! We may not be the same as the original reciever ;)
    return self;
}
/**
 * Clean up our memory.
 */
- (void)dealloc
{
	//Be a good citizen, release and call super's -dealloc.
	[windowTitle release];
	[appName release];
	[super dealloc];
}

/**
 * @brief Set the title of the window to be displayed
 * 
 * @param title An NSString. Not retained by the reciever. Must not be nil, use @"" instead.
 *
 * To save on releasing and re-displaying, we only copy in a new string when the *data* of the strings are the same, not
 * just when their *addresses* are. Should save us some cycles when drawing. Also, we maintain a cache of the whitespace
 * stripped window title. Again, to save cycles. The trimming is necessary because of an oddity in the Finder, where
 * the desktop has a blank, non-empty name. Possibly related to the implementation of icons on the desktop as NSWindows.
 */
- (void)setWindowTitle:(NSString *)title
{
	if (![windowTitle isEqualToString:title]) {
		[windowTitle release];
		windowTitle = [title copy];
		_cachedTrimmedWindowTitle = [windowTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[self setNeedsDisplay:YES];
	}
}

/**
 * @brief Set the name of the app to be displayed
 * 
 * @param title An NSString. Not retained by the reciever. Must not be nil, use @"" instead.
 *
 * To save on releasing and re-displaying, we only copy in a new string when the *data* of the strings are the same, not
 * just when their *addresses* are. Should save us some cycles when drawing.
 */

- (void)setAppName:(NSString *)name
{
	if (![appName isEqualToString:name]) {
		[appName release];
		appName = [name copy];
		[self setNeedsDisplay:YES];
	}
}

/**
 * @brief Draw our content
 *
 * @param rect The rectangular area, origined bottom-left, to draw in.
 *
 * This is where we make the moneys. The app name and window title are drawn, as is the cool green and purple box!
 * Yay Mardi Gras!
 */
- (void)drawRect:(NSRect)rect
{	
	//Prepare a string to give to NSAttribuedString
	NSString *formattedString = appName;
	if (![_cachedTrimmedWindowTitle isEqualToString:@""]) {
		formattedString = [NSString stringWithFormat:@"%@ - %@", appName, windowTitle];
	}
	//We can't display a 0x0 window, or it will disappear, so make sure there's actually something to display
	if([formattedString length] > 0) { 
		//Create the attributed string with our static attrs dictionary.
		NSAttributedString *text = [[NSAttributedString alloc] initWithString:formattedString attributes:attrs];
		//The radius of our rounded corner is 1/2th the height (meaning the diameter equals the height, thus the end caps are circular)
		float radius = [text size].height*0.5;
		//Create a rect at the right place (we need to translate upwards so the stroke doesn't get clipped, and we also
		//need to add the widths of the endcaps in.
		NSRect expandedRect = (NSRect){{DV_VIEW_STROKE_WIDTH, DV_VIEW_STROKE_WIDTH}, {[text size].width+radius*2, [text size].height}};
		
		//This is an algorithm I ganked from Growl. It creates a rectangle with rounded corners inside expandedRect.
		float minX = NSMinX(expandedRect);
		float minY = NSMinY(expandedRect);
		float maxX = NSMaxX(expandedRect);
		float maxY = NSMaxY(expandedRect);
		float midX = NSMidX(expandedRect);
		float midY = NSMidY(expandedRect);
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path moveToPoint:(NSPoint){maxX, midY}];
		[path appendBezierPathWithArcFromPoint:(NSPoint){maxX, maxY} toPoint:(NSPoint){midX, maxY} radius:radius]; 
		[path appendBezierPathWithArcFromPoint:(NSPoint){minX, maxY} toPoint:(NSPoint){minX, midY} radius:radius]; 
		[path appendBezierPathWithArcFromPoint:(NSPoint){minX, minY} toPoint:(NSPoint){midX, minY} radius:radius]; 
		[path appendBezierPathWithArcFromPoint:(NSPoint){maxX, minY} toPoint:(NSPoint){maxX, midY} radius:radius]; 
		[path closePath];
		
		//Now we an draw the cool green and purple box
		[DV_VIEW_BACKGROUND_COLOR set];
		[path fill];
		[DV_VIEW_STROKE_COLOR set];
		[path stroke];
		
		//Draw the yellow/gold text on top of the box, making sure to translate up and shift over for the stroke and endcap
		[text drawAtPoint:(NSPoint){DV_VIEW_STROKE_WIDTH + radius, DV_VIEW_STROKE_WIDTH}];
							 
		//Get rid of this, we don't need it anymore.
		[text release];
	}
}

/**
 * @brief The view calculates how much room it will need to display its content
 *
 * This method has quite a bit of duplication, and it's called rather often. I'd like for there to be more caching here,
 * but there just wasn't enough time. It didn't seem to impact performance too much on my system.
 */
- (NSSize)requestedSize
{
	//Prepare a string to give to NSAttribuedString
	NSString *formattedString = appName;
	if (![_cachedTrimmedWindowTitle isEqualToString:@""]) {
		formattedString = [NSString stringWithFormat:@"%@ - %@", appName, windowTitle];
	}
	
	//Create the attributed string with our static attrs dictionary.
	NSAttributedString *text = [[NSAttributedString alloc] initWithString:formattedString attributes:attrs];
	NSSize textBounds = [text size];

	//The radius of our semi-circular endcaps is half of the height
	float radius = [text size].height*0.5;
	
	//If you love something, let if go
	[text release];
	
	//Add once for each side that is stroked (top, bottom, left, right), and once for each end cap
	return (NSSize){textBounds.width + DV_VIEW_STROKE_WIDTH*2 + radius*2, 
					textBounds.height + DV_VIEW_STROKE_WIDTH*2};
}

/**
 * We don't want DV to detect itself. That's too weird.
 */
- (BOOL)accessibilityIsIgnored
{
	return YES;
}

@end
