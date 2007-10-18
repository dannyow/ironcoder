#import "clockView.h"

@implementation clockView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
		
		//create timer , set to repeat every second
		timer = [[NSTimer scheduledTimerWithTimeInterval:1.0
												  target:self 
												selector:@selector(drawRect:) 
												userInfo:nil 
												 repeats:YES] retain];
	}
	return self;
}

- (void)drawRect:(NSRect)rect
{
	//Get Quartz Graphics Context
	NSGraphicsContext *nsctx = [NSGraphicsContext currentContext];
	CGContextRef context = (CGContextRef)[nsctx graphicsPort];
	
	//draw clock
	drawClock(context);
	
	//update the display
	[self setNeedsDisplay:YES];
}

void drawClock(CGContextRef context)
{
	//*********** Draw the rect ***************
	
	CGRect myRect;
	
	//Set the fill color to opaque grey.
	CGContextSetRGBFillColor(context, .76, .76, .76, 1.0);
	
	//Set up the rectangle for drawing.
	myRect.origin.x = myRect.origin.y = 0.0;
	myRect.size.width = 325.0;
	myRect.size.height = 175.0;
	
	//Draw the filled rectangle
	CGContextFillRect(context, myRect);
	
	
	//*********** Draw the lines **************

	//Draw the horizontal line
	CGPoint start, end;
	start.x = 0.0;
	start.y = 95.0;
	
	end.x = 325.0;
	end.y = 95.0;
	
	CGContextSetLineWidth(context, 3.0);
	drawStrokedLine(context, start, end);
	
	//Draw the first vertical line
	start.x = 110.0;
	start.y = 95.0;
	
	end.x = 110.0;
	end.y = 0.0;
	
	CGContextSetLineWidth(context, 3.0);
	drawStrokedLine(context, start, end);
	
	//Draw the second vertical line
	start.x = 220.0;
	start.y = 95.0;
	
	end.x = 220.0;
	end.y = 0.0;
	
	CGContextSetLineWidth(context, 3.0);
	drawStrokedLine(context, start, end);
	
	//*********** Draw the text ***************
	
	//time, date strings
	NSString *stringTime, *stringMonth, *stringDate, *stringDay;
	char *resultString, resultStringMonth;
	
	//string size
	size_t textlen;
	
	//Get correct NSCalendarDate format
	stringTime = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%1I:%M:%S %p"];
	stringMonth = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%b"];
	stringDate = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%d"];
	stringDay = [[NSCalendarDate calendarDate] descriptionWithCalendarFormat:@"%a"];
	
	//set font size
	float fontSize1 = 60, fontSize2 = 24, fontSize3 = 48;
	
	float opaqueBlack[] = {
		0.0, 0.0, 0.0, 1.0
	};
	
	//set colorspace
	CGColorSpaceRef colorSpace = NULL;
	
	//Set the fill color space.  This sets the 
	//fill painting color to opaque black.
	CGContextSetFillColorSpace(context, colorSpace);
	
	//Set the text matrix this code requires.
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	
	//Choose the font with the Postscript name "Times-Roman", at 
	//fontSize points, with the MacRoman encoding
	CGContextSelectFont(context, "Times-Roman", fontSize1, kCGEncodingMacRoman);
	
	//The default text drawing mode is fill.  
	
	//Draw the Time
	//Draw the text at (20, 100).
	resultString = [stringTime cString];
	textlen = strlen(resultString);
	CGContextShowTextAtPoint(context, 20, 120, resultString, textlen);
	
	CGContextSelectFont(context, "Times-Roman", fontSize3, kCGEncodingMacRoman);
	//Draw the Month
	
	resultString = [stringMonth cString];
	textlen = strlen(resultString);
	CGContextShowTextAtPoint(context, 20, 20, resultString, textlen);
	
	//Draw the Date
	resultString = [stringDate cString];
	textlen = strlen(resultString);
	CGContextShowTextAtPoint(context, 140, 20, resultString, textlen);
	
	//Draw the Day
	resultString = [stringDay cString];
	textlen = strlen(resultString);
	CGContextShowTextAtPoint(context, 240, 20, resultString, textlen);
	
	
	//Draw the text labels of the month, date, day
	CGContextSelectFont(context, "Times-Roman", fontSize2, kCGEncodingMacRoman);	
	CGContextShowTextAtPoint(context, 20, 70, "Month", 5);
	CGContextShowTextAtPoint(context, 140, 70, "Date", 4);
	CGContextShowTextAtPoint(context, 260, 70, "Day", 3);
	
	//Set the fill color to black
	CGContextSetFillColor(context, opaqueBlack);
	
}

void drawStrokedLine(CGContextRef context, CGPoint start, CGPoint end)
{
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, start.x, start.y);
	CGContextAddLineToPoint(context, end.x, end.y);
	CGContextDrawPath(context, kCGPathStroke);
}


@end
