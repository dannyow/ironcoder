#import "AppDelegate.h"

typedef struct 
{
	float red;
	float green;
	float blue;
	float alpha;
} CGColor;

#pragma mark -
#pragma mark Functions

CGContextRef MyCreatePDFContext (const CGRect *inMediaBox, CFStringRef path)
{
    CGContextRef myOutContext = NULL;    
    CFURLRef url;
	
    url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, false);
    if (url != NULL) 
	{
        myOutContext = CGPDFContextCreateWithURL(url, inMediaBox, NULL);
        CFRelease(url);
    }
    return myOutContext;
}

CGImageRef CreateCGImageFromData(NSData* data)
{
    CGImageRef imageRef = NULL;
    CGImageSourceRef sourceRef;
	
    sourceRef = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    if (sourceRef)
	{
        imageRef = CGImageSourceCreateImageAtIndex(sourceRef, 0, NULL);
        CFRelease(sourceRef);
    }
    return imageRef;
}

CGRect NSRectToCGRect(NSRect nsRect)
{
	CGRect cgRect;
	
	cgRect.origin.x = nsRect.origin.x;
	cgRect.origin.y = nsRect.origin.y;
	cgRect.size.width = nsRect.size.width;
	cgRect.size.height = nsRect.size.height;
	
	return cgRect;
}

#pragma mark -
#pragma mark Private interface

@interface AppDelegate (Private)
- (void)p_loadFeeds;
- (void)p_loadArticles;

- (void)p_drawPage;
- (void)p_drawBorderAndTitleInContext:(CGContextRef)aContext;
- (void)p_drawIronCoderBandInContext:(CGContextRef)aContext;
- (void)p_drawArticleTitle:(NSString*)aTitle inContext:(CGContextRef)aContext;
- (void)p_drawString:(NSString*)aString 
		   inContext:(CGContextRef)aContext 
			withFont:(NSString*)font
			  inRect:(NSRect)aRect 
		   withColor:(CGColor)aColor 
	 withStrokeWidth:(float)aStrokeWidth 
	  withStrokColor:(CGColor)aStrokeColor
		   withAngle:(float)anAngle;

- (NSString*)p_stringByFilteringString:(NSString*)aString;
- (NSString*)p_stringByStrippingNonAlphaNumericCharacters:(NSString*)aString;

- (NSImage*)p_randomFlickrImageBySearchStrings:(NSString*)aString;
@end

#pragma mark -
#pragma mark Public methods

@implementation AppDelegate

- (void)awakeFromNib
{
	srandom(time(NULL));
	mPageRect = NSMakeRect(0, 0, 600, 800);
	[self p_loadFeeds];
	[self p_loadArticles];
	[self p_drawPage];
	[oDrawer open];
}

- (void)dealloc
{
	[mFeeds release];
	[mArticles release];
	[super dealloc];
}

#pragma mark Accessors

- (NSArray*)feeds
{
	return mFeeds;
}

- (NSMutableArray*)articles
{
	return mArticles;
}

#pragma mark Actions

- (IBAction)chooseRandomArticle:(id)sender
{
	int index = ([mArticles count] > 0) ? random() % [mArticles count] : 0;
	[oArticlesArrayController setSelectionIndex:index];	
	[self p_drawPage];
}

- (IBAction)changeFeed:(id)sender
{
	[self p_loadArticles];
	[self p_drawPage];
}

- (IBAction)changeArticle:(id)sender
{
	[self p_drawPage];
}

- (IBAction)readArticle:(id)sender
{
	NSString *urlPath = [[[oArticlesArrayController selectedObjects] objectAtIndex:0] valueForKey:@"link"];
	NSURL *url = [NSURL URLWithString:urlPath];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)saveAs:(id)sender
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
	
	if ([savePanel runModal])
	{
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[savePanel filename]])
			[fileManager removeFileAtPath:[savePanel filename] handler:nil];
		[fileManager copyPath:mPDFPath toPath:[savePanel filename] handler:nil];
	}
}

@end

#pragma mark -
#pragma mark Private methods

@implementation AppDelegate (Private)

#pragma mark xml parsing methods

- (void)p_loadFeeds
{
	[self willChangeValueForKey:@"feeds"];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"feeds" ofType:@"plist"];
	NSDictionary *feedsDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
	mFeeds = [[feedsDict objectForKey:@"feeds"] retain];
	[self didChangeValueForKey:@"feeds"];
	[oFeedsArrayController setSelectionIndex:0];
}

- (void)p_loadArticles
{
	if (mArticles != nil) [mArticles release]; 
	mArticles = [[NSMutableArray array] retain];

	[self willChangeValueForKey:@"articles"];
	NSString *feedURLString = [[[oFeedsArrayController selectedObjects] objectAtIndex:0] valueForKey:@"url"];
	NSURL *feedURL = [NSURL URLWithString:feedURLString];
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:feedURL options:NSXMLDocumentTidyXML error:nil];
	NSXMLElement *rss = [xmlDoc rootElement];
	NSXMLElement *channel = [[rss elementsForName:@"channel"] objectAtIndex:0];
	NSEnumerator *e = [[channel elementsForName:@"item"] objectEnumerator];
	NSXMLElement *element;
	while (element = [e nextObject])
	{
		NSString *title = [[[[element elementsForName:@"title"] objectAtIndex:0] stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString *link = [[[element elementsForName:@"link"] objectAtIndex:0] stringValue];
		[mArticles addObject:[NSDictionary dictionaryWithObjectsAndKeys:title,@"title",link,@"link",nil]];
	}
	[self didChangeValueForKey:@"articles"];
	int index = ([mArticles count] > 0) ? random() % [mArticles count] : 0;
	[oArticlesArrayController setSelectionIndex:index];
}

#pragma mark drawing methods

// it creates a pdf file in temporary folder and loads to imageview
- (void)p_drawPage
{
	[oProgressIndicator startAnimation:nil];	
	NSString *articleTitle = [[[oArticlesArrayController selectedObjects] objectAtIndex:0] valueForKey:@"title"];
	
	NSImage *image = [self p_randomFlickrImageBySearchStrings:[self p_stringByFilteringString:articleTitle]];	
	
	CGRect mediaBox = NSRectToCGRect(mPageRect);
	mPDFPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"Time.pdf"];
	CGContextRef aPDFContext = MyCreatePDFContext(&mediaBox, (CFStringRef)mPDFPath);
	// begin drawing
	CGContextBeginPage(aPDFContext, &mediaBox);
	
	CGContextDrawImage(aPDFContext,NSRectToCGRect(mPageRect),CreateCGImageFromData([image TIFFRepresentation]));
	
	[self p_drawBorderAndTitleInContext:aPDFContext];
	
	[self p_drawArticleTitle:articleTitle inContext:aPDFContext];
	
	[self p_drawIronCoderBandInContext:aPDFContext];
	
	//end drawing
	CGContextEndPage(aPDFContext);
	CGContextRelease(aPDFContext);
	
	NSImage *pdfImage = [[[NSImage alloc] initByReferencingFile:mPDFPath] autorelease];
	[oImageView setImage:pdfImage];	
	[oProgressIndicator stopAnimation:nil];
}

- (void)p_drawBorderAndTitleInContext:(CGContextRef)aContext
{
	// Draw red border
	CGContextSetRGBStrokeColor (aContext, 1, 0, 0, 1);
	float redBorderWidth = 30;
	CGContextSetLineWidth (aContext, redBorderWidth);
	NSRect redBorderRect = NSInsetRect(mPageRect, redBorderWidth/2, redBorderWidth/2 - 5);
	CGContextStrokeRect (aContext, NSRectToCGRect(redBorderRect));
	
	// Draw black border
	CGContextSetRGBStrokeColor (aContext, 0, 0, 0, 1);
	float blackBorderWidth = 3;
	CGContextSetLineWidth (aContext, blackBorderWidth);
	NSRect blackBorderRect = NSInsetRect(redBorderRect, (redBorderWidth/2)+(blackBorderWidth/2), redBorderWidth/2+(blackBorderWidth/2));
	CGContextStrokeRect (aContext, NSRectToCGRect(blackBorderRect));
	
	// Draw white border
	CGContextSetRGBStrokeColor (aContext, 1, 1, 1, 1);
	float whiteBorderWidth = 3;
	CGContextSetLineWidth (aContext, whiteBorderWidth);
	NSRect whiteBorderRect = NSInsetRect(blackBorderRect, (blackBorderWidth/2)+(whiteBorderWidth/2), (blackBorderWidth/2)+(whiteBorderWidth/2));
	CGContextStrokeRect (aContext, NSRectToCGRect(whiteBorderRect));
	
	// Draw TIME
	[self p_drawString:@"TIME"
			 inContext:aContext
			  withFont:@"Times New Roman"
				inRect:NSMakeRect(35, 600, 0, 215)
			 withColor:(CGColor){1, 0, 0, 1} 
	   withStrokeWidth:0 
		withStrokColor:(CGColor){1, 1, 1, 1}
			 withAngle:0];	
}

- (void)p_drawIronCoderBandInContext:(CGContextRef)aContext
{	
	CGContextBeginPath(aContext);
	CGContextMoveToPoint(aContext, 350, 850);
	CGContextAddLineToPoint(aContext, 650, 650);
	CGContextClosePath(aContext);
	CGContextSetLineWidth(aContext, 50);
	CGContextSetRGBStrokeColor (aContext, 0, 0, 0, 0.8);	
	CGContextStrokePath(aContext);
	
	[self p_drawString:@"ironcoder exclusive"
			 inContext:aContext
			  withFont:@"Arial"		
				inRect:NSMakeRect(457, 780, 0, 18)
			 withColor:(CGColor){1, 1, 1, 0.8} 
	   withStrokeWidth:0 
		withStrokColor:(CGColor){1, 1, 1, 1} 
			 withAngle:5.69];
	
	[self p_drawString:@"w w w . i r o n c o d e r . o r g"
			 inContext:aContext
			  withFont:@"Arial"		
				inRect:NSMakeRect(447, 770, 0, 12)
			 withColor:(CGColor){1, 1, 1, 0.5} 
	   withStrokeWidth:0 
		withStrokColor:(CGColor){1, 1, 1, 1} 
			 withAngle:5.69];
}

- (void)p_drawArticleTitle:(NSString*)aTitle inContext:(CGContextRef)aContext
{	
	if ([aTitle length] > 43)
		aTitle = [NSString stringWithFormat:@"%@...",[aTitle substringToIndex:40]];
	[self p_drawString:aTitle
			 inContext:aContext
			  withFont:@"Arial"
				inRect:NSMakeRect(51, 49, 0, 23)
			 withColor:(CGColor){0, 0, 0, 1} 
	   withStrokeWidth:0 
		withStrokColor:(CGColor){1, 1, 1, 1}
			 withAngle:0];
	
	[self p_drawString:aTitle
			 inContext:aContext
			  withFont:@"Arial"		
				inRect:NSMakeRect(50, 50, 0, 23)
			 withColor:(CGColor){1, 1, 1, 1} 
	   withStrokeWidth:0 
		withStrokColor:(CGColor){1, 1, 1, 1} 
			 withAngle:0];
}

- (void)p_drawString:(NSString*)aString 
		   inContext:(CGContextRef)aContext 
			withFont:(NSString*)font
			  inRect:(NSRect)aRect 
		   withColor:(CGColor)aColor 
	 withStrokeWidth:(float)aStrokeWidth 
	  withStrokColor:(CGColor)aStrokeColor
		   withAngle:(float)anAngle
{
	CGContextSetRGBFillColor(aContext, aColor.red, aColor.green, aColor.blue, aColor.alpha);
	CGContextSelectFont(aContext, [font UTF8String], NSHeight(aRect), kCGEncodingMacRoman);
	CGContextSetShouldAntialias(aContext, true);
	if (aStrokeWidth > 0)
	{
		CGContextSetTextDrawingMode(aContext, kCGTextFillStroke);
		CGContextSetLineWidth(aContext, aStrokeWidth);
		CGContextSetRGBStrokeColor (aContext, aStrokeColor.red, aStrokeColor.green, aStrokeColor.blue, aStrokeColor.alpha);
	}
	else
	{
		CGContextSetTextDrawingMode(aContext, kCGTextFill);
	}
	if (anAngle > 0)
	{
		CGAffineTransform myTextTransform = CGAffineTransformMakeRotation(anAngle);
		CGContextSetTextMatrix (aContext, myTextTransform);
	}
	char *text = (char*)[aString UTF8String];
	CGContextShowTextAtPoint(aContext, aRect.origin.x, aRect.origin.y, text, strlen(text));
}

#pragma mark String methods

- (NSString*)p_stringByFilteringString:(NSString*)aString
{
	NSMutableString *input = [aString mutableCopy];
	[input replaceOccurrencesOfString:@"'s " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0,[aString length])];
	
	NSMutableArray *output = [NSMutableArray array];
	NSArray *particles = [NSArray arrayWithObjects:
		@"for", @"and", @"nor", @"but", @"or", @"yet", @"so", @"of",
		@"a", @"an", @"the", @"this", @"that", @"these", @"those",
		@"her", @"his", @"its", @"my", @"our", @"their", @"your",
		@"all", @"few", @"many", @"several", @"some", @"every",
		@"what", @"where", @"when", @"who", @"how", @"why",
		@"is", @"are", @"am", @"at", @"in", @"timecom",
		nil];
	NSString *filteredString = [self p_stringByStrippingNonAlphaNumericCharacters:input];
	NSEnumerator *e = [[filteredString componentsSeparatedByString:@" "] objectEnumerator];
	NSString *word;
	while (word = [e nextObject])
	{
		if ([particles containsObject:[word lowercaseString]] == NO)
			[output addObject:word];
	}
	return [output componentsJoinedByString:@"+"];
}

- (NSString*)p_stringByStrippingNonAlphaNumericCharacters:(NSString*)aString
{
	NSString *output = @"";
	int i;
	for (i = 0; i < [aString length]; i++)
	{
		char character = [aString characterAtIndex:i];
		if ((character >= 'A' && character <= 'z') || (character >= '0' && character <= '9') || (character == ' '))
			output = [NSString stringWithFormat:@"%@%c",output,character];
	}
	return output;
}

#pragma mark Flickr method

// recursively search from flickr by removing last word on every empty search result
- (NSImage*)p_randomFlickrImageBySearchStrings:(NSString*)aString
{
	// This is when none of the search words return result =)
	if ([aString length] == 0)
		aString = @"macsb";
	
	NSString *flickrURLString = [NSString stringWithFormat:@"http://flickr.com/search/?q=%@&m=text",aString];
	NSURL *flickrURL = [NSURL URLWithString:flickrURLString];
	if (flickrURL == nil) return nil;
	
	NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:flickrURL options:NSXMLDocumentTidyHTML error:nil];
	if (xmlDoc == nil) return nil;
	
	NSArray *itemNodes = [[xmlDoc rootElement] nodesForXPath:@"/html[1]/body[1]/div[2]/table[1]/tr" error:nil];
	
	int index = ([itemNodes count] > 0) ? random() % [itemNodes count] : 0;
	NSString *xpath = [NSString stringWithFormat:@"/html[1]/body[1]/div[2]/table[1]/tr[%d]/td[1]/a[1]/img[1]",index+1];
	NSArray *nodes = [[xmlDoc rootElement] nodesForXPath:xpath error:nil];
	
	if ([nodes count] == 0)
	{
		NSMutableArray *stringComponents = [[aString componentsSeparatedByString:@"+"] mutableCopy];
		[stringComponents removeLastObject];
		return [self p_randomFlickrImageBySearchStrings:[stringComponents componentsJoinedByString:@"+"]];
	}
	else
	{
		NSXMLElement *imgElement = [nodes objectAtIndex:0];
		NSXMLNode *srcNode = [imgElement attributeForName:@"src"];
		NSString *imageURLString = [srcNode stringValue];
		NSString *largeImageURLString = [imageURLString stringByDeletingPathExtension];
		largeImageURLString = [largeImageURLString substringToIndex:[largeImageURLString length]-2];
		largeImageURLString = [NSString stringWithFormat:@"%@.%@",largeImageURLString,[imageURLString pathExtension]];
		NSURL *imageURL = [NSURL URLWithString:largeImageURLString];
		NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
		if (image == nil)
		{
			imageURL = [NSURL URLWithString:imageURLString];
			image = [[NSImage alloc] initWithContentsOfURL:imageURL];			
		}
		return [image autorelease];
	}
}

#pragma mark delegate method

- (void)windowWillClose:(NSNotification *)aNotification
{
	[NSApp terminate:nil];
}

@end