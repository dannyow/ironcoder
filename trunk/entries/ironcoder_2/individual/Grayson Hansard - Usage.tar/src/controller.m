#import "controller.h"
#import "controller+ScriptsMenu.h"

void DrawPattern(void *info, CGContextRef c)
{
	PatternInfo *pi = info;
	PatternInfo p = *pi;
	
	float ratio = p.uptime / p.highestUptime;
	float rowHeight = p.rowHeight;
	
	float h = rowHeight/2;
	float x = rowHeight/5;
	
	CGMutablePathRef pathRef = CGPathCreateMutable();
	CGPathMoveToPoint(pathRef, nil, 0.0, h);
	CGPathAddLineToPoint(pathRef, nil, x, h);
	CGPathAddLineToPoint(pathRef, nil, x*2, h + (ratio*h));
	CGPathAddLineToPoint(pathRef, nil, x*3, h - (ratio*h));
	CGPathAddLineToPoint(pathRef, nil, x*4, h);
	CGPathAddLineToPoint(pathRef, nil, x*5, h);
	CGContextAddPath(c, pathRef);
	CGContextSetRGBStrokeColor(c, 0, 0, 0, 1);
	CGContextStrokePath(c);
}

void DrawBGGradient(void *info, float const *inD, float *outD)
{
	PatternInfo *pi = info;
	PatternInfo p = *pi;
	float ratio = p.uptime / p.highestUptime;
	float c[4];
	
	if (ratio < 0.3)
	{
		c[0] = 0.; 
		c[1] = 0.; 
		c[2] = 1.0;
	}
	else if (ratio < 0.6)
	{
		c[0] = 0.;
		c[1] = 1.;
		c[2] = 0.;
	}
	else
	{
		c[0] = 1.0;
		c[1] = 0.;
		c[2] = 0.;
	}
	c[3] = 1.0;
	
	float d = inD[0];
	outD[0] = c[0];
	outD[1] = c[1];
	outD[2] = c[2];
	if (d < 0.5) outD[3] = d;
	else outD[3] = 1.0-d;	
}

@implementation controller

-(void)awakeFromNib
{
	rowHeight = 17.0;
	[self buildScriptMenu];
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(update:) userInfo:nil repeats:YES];
}

-(void)update:(NSTimer *)timer
{	
	NSTask *t = [[NSTask alloc] init];
	NSPipe *p = [NSPipe pipe];
	NSFileHandle *f = [p fileHandleForReading];
	[t setLaunchPath:@"/bin/sh"];
	NSArray *args = [userButton state] ? 
		[NSArray arrayWithObjects:[[NSBundle mainBundle] pathForResource:@"processes" ofType:@"sh"], NSUserName(), nil]:
		[NSArray arrayWithObject:[[NSBundle mainBundle] pathForResource:@"processes" ofType:@"sh"]];
	[t setArguments:args];
	[t setStandardOutput:p];
	[t launch];
	
	NSData *d = [f readDataToEndOfFile];
	NSString *s = [[[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding] autorelease];
	NSArray *processStrArray = [[[s componentsSeparatedByString:@"PID - COMMAND - UID - TIME"] objectAtIndex:1] componentsSeparatedByString:@"\n"];
	if ([processStrArray count] == 0) return;
	
	NSEnumerator *e = [[processStrArray subarrayWithRange:NSMakeRange(1, [processStrArray count]-2)] objectEnumerator];
	NSString *process = nil;
	NSMutableArray *processes = [NSMutableArray array];
	while (process = [e nextObject])
	{
		NSMutableDictionary *pd = [self parseProcess:process];
		if (pd) [processes addObject:pd];
	}
	
	// Setup text drawing attributes
	NSShadow *shadow = [NSShadow new];
	[shadow setShadowBlurRadius:3.0];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:0 alpha:1.]];
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	NSDictionary *textAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
		shadow, NSShadowAttributeName,
		[NSColor whiteColor], NSForegroundColorAttributeName,
		[NSFont boldSystemFontOfSize:16.0], NSFontAttributeName,
		nil];
	
	// Get highest uptime and draw image
	NSSortDescriptor *sd = [[[NSSortDescriptor alloc] initWithKey:@"rawTime" ascending:NO] autorelease];
	[processes sortUsingDescriptors:[NSArray arrayWithObject:sd]];
	NSTimeInterval highestUptime = [[[processes objectAtIndex:0] objectForKey:@"rawTime"] doubleValue];
	double sum = [[processes valueForKeyPath:@"@sum.rawTime"] doubleValue];
	
	e = [processes objectEnumerator];
	NSMutableDictionary *pDict = nil;
	while (pDict = [e nextObject])
	{
		double rawUptime = [[pDict objectForKey:@"rawTime"] doubleValue];
		[pDict setObject:[NSString stringWithFormat:@"%.2f%%", rawUptime/sum*100.] forKey:@"percent"];
		
		NSImage *img = [[[NSImage alloc] initWithSize:NSMakeSize(250.0, rowHeight)] autorelease];
		[img lockFocus];
		
		// Setup context ref
		CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
		CGContextSaveGState(c);
		PatternInfo info = {highestUptime, rawUptime, rowHeight};
		
		// Setup base color space
		CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(nil);
		CGContextSetFillColorSpace(c, patternSpace);
		CGColorSpaceRelease(patternSpace);
		
		// Draw background gradient
		CGFunctionCallbacks gradientCallbacks = {0, DrawBGGradient, nil};
		CGFunctionRef function = CGFunctionCreate(&info, 1, nil, 4, nil, &gradientCallbacks);
		CGShadingRef shading = CGShadingCreateAxial(CGColorSpaceCreateDeviceRGB(),
													CGPointMake(0, 0), CGPointMake(250.0, rowHeight), function, NO, NO);
		CGContextDrawShading(c, shading);
		CGShadingRelease(shading);
		
		// Setup pattern
		CGPatternCallbacks callbacks = {0, &DrawPattern, nil};
		CGPatternRef patternRef = CGPatternCreate(&info, CGRectMake(0, 0, 250.0, rowHeight), CGAffineTransformIdentity,
												 rowHeight, rowHeight, kCGPatternTilingConstantSpacing, YES, &callbacks);
		float alpha = 1.0;
		CGContextSetFillPattern(c, patternRef, &alpha);
		CGContextFillRect(c, CGRectMake(0, 0, 250.0, rowHeight));
		CGContextRestoreGState(c);
		
		NSString *drawStr = [pDict objectForKey:@"time"];
		NSSize s = [drawStr sizeWithAttributes:textAttrs];
		[drawStr drawAtPoint:NSMakePoint((250.0-s.width)/2.0, (rowHeight-s.height)/2) withAttributes:textAttrs];
		[img unlockFocus];
		[pDict setObject:img forKey:@"usage"];
	}
	
	if ([processes count]) [self setProcesses:processes];
}

-(NSMutableDictionary *)parseProcess:(NSString *)process
{
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithObjects:[process componentsSeparatedByString:@" - "] forKeys:[NSArray arrayWithObjects:@"pid", @"command", @"uid", @"time", nil]];
	
	NSString *name = [[d objectForKey:@"command"] lastPathComponent];
	[d setObject:name forKey:@"name"];
	NSImage *img = nil;
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	if ([ws fullPathForApplication:name])
		img = [ws iconForFile:[ws fullPathForApplication:name]];
	else img = [ws iconForFile:@"/bin/sh"];
	[img setScalesWhenResized:YES];
	[img setSize:NSMakeSize(rowHeight, rowHeight)];
	[d setObject:img forKey:@"icon"];
	
	NSString *s = [d objectForKey:@"time"];
	NSRange hr = [s rangeOfString:@"h"];
	NSRange mr = [s rangeOfString:@"m"];
	NSRange sr = [s rangeOfString:@"s"];

	double rawTime = 0.;
	int loc = 0;

	if (hr.location != NSNotFound) 
	{
		rawTime = [[s substringToIndex:hr.location] doubleValue] * 60 * 60;
		loc = hr.location+1;
	}
	
	if (mr.location != NSNotFound)
	{
		rawTime += [[s substringWithRange:NSMakeRange(loc, mr.location-loc)] doubleValue] * 60;
		loc = mr.location+1;
	}
	
	if (sr.location != NSNotFound)
		rawTime += [[s substringWithRange:NSMakeRange(loc, sr.location-loc)] doubleValue] * 60;
	
	[d setObject:[NSNumber numberWithDouble:rawTime] forKey:@"rawTime"];
	
	return d;
}

-(NSArray *)processes { return _processes; }
-(void)setProcesses:(NSArray *)processes
{
	if (!processes || (processes == _processes)) return;
	[_processes release];
	_processes = [processes retain];
}

-(IBAction)changeSize:(id)sender
{
	rowHeight = [sender doubleValue];
	[tableView setRowHeight:rowHeight];
	NSTableColumn *c = [tableView tableColumnWithIdentifier:@"icon"];
	[c setMaxWidth:rowHeight];
	[c setMinWidth:rowHeight];
	[c setWidth:rowHeight];
}

@end
