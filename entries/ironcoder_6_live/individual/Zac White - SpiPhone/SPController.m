#import "SPController.h"

#define PORT 9138
#define IMAGE_PATH [@"~/Library/Application Support/SpiPhone" stringByExpandingTildeInPath]

@implementation SPController

- (void)awakeFromNib{
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
		
	[statusItem setHighlightMode:YES];
	[statusItem setToolTip:@"SpiPhone"];
	[statusItem setMenu:menu];
	[statusItem setEnabled:YES];
	[statusItem setImage:[NSImage imageNamed:@"iphone.tif"]];
	[statusItem setAlternateImage:[NSImage imageNamed:@"iphone.tif"]];
	
	template = [[SPTemplate alloc] init];
	
	[template setIndex:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]]];
	[template setImageTemplate:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_template" ofType:@"html"]]];
	[template setImagePage:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image_page" ofType:@"html"]]];
	
	if(![[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"updateTime"])
		[[[NSUserDefaultsController sharedUserDefaultsController] values] setValue:[NSNumber numberWithFloat:300.] forKey:@"updateTime"];
	
	if(![[NSFileManager defaultManager] fileExistsAtPath:IMAGE_PATH]){
		[[NSFileManager defaultManager] createDirectoryAtPath:IMAGE_PATH attributes:nil];
	}
	
	[self _startWebServer];
	[self _startPictureTaking];
}

- (IBAction)takePicture:(id)sender
{
	[self _runPictureUtility:nil];
}

- (void)_runPictureUtility:(NSTimer *)timer{
	NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];
    NSData *inData;
    NSString *tempString;
	
	NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"isightcapture" ofType:@""]];
    
	NSArray *arguments;
	
	NSString *filename = [[NSDate date] descriptionWithCalendarFormat:@"%m%d%y-%H.%M.%S" timeZone:nil locale:nil];
	
    arguments = [NSArray arrayWithObjects: @"-w", @"320", @"-h", @"240", [IMAGE_PATH stringByAppendingPathComponent:[filename stringByAppendingString:@".jpg"]], nil];
	
	[task setArguments:arguments];
	
    [task setStandardOutput:newPipe];
    [task launch];
    inData = [readHandle readDataToEndOfFile];
    tempString = [[NSString alloc] initWithData:inData encoding:NSASCIIStringEncoding];
    [task release];

}

- (void)_startWebServer{
	[self setServer:[[[SimpleHTTPServer alloc] initWithTCPPort:PORT
                                                      delegate:self] autorelease]];
}

- (void)setServer:(SimpleHTTPServer *)sv
{
    [server autorelease];
    server = [sv retain];
}
- (SimpleHTTPServer *)server { return server; }

#pragma mark -
#pragma mark Delegate stuff

- (void)processURL:(NSURL *)path connection:(SimpleHTTPConnection *)connection
{
	NSLog(@"Got a request for: %@", path);
	if([[path path] isEqualToString:@"/"]){
		//SPTemplate *template = [[SPTemplate alloc] initWithPathToTemplateFiles:[[[NSBundle mainBundle] path] stringByAppendingPathComponent:@"/Contents/Resources/"]];
		[server replyWithData:[[template buildPageWithImagesAtPath:IMAGE_PATH] dataUsingEncoding:NSASCIIStringEncoding] MIMEType:@"text/html"];
	}
	
	//handle the favicon.
	if([[[path path] lastPathComponent] isEqualToString:@"favicon.ico"]){
		[server replyWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iphonebig" ofType:@"tif"]] MIMEType:@"image/tif"];
	}
	
	//then we are using an internal resource.
	if([[path path] rangeOfString:@"resource"].location != NSNotFound){
		NSRange range = NSMakeRange(0, [[[path path] lastPathComponent] rangeOfString:@"."].location);
		
		NSString *imagePath = [[NSBundle mainBundle] pathForResource:[[[path path] lastPathComponent] substringWithRange:range] ofType:[[path path] pathExtension]];
		
		[server replyWithData:[NSData dataWithContentsOfFile:imagePath] MIMEType:[@"image/" stringByAppendingString:[[path path] pathExtension]]];
	}
	
	//build the page for displaying an image.
	if([[[path path] pathExtension] isEqualToString:@"html"] || [[[path path] pathExtension] isEqualToString:@"css"]){
		NSRange range = NSMakeRange(0, [[[path path] lastPathComponent] rangeOfString:@"." options:NSBackwardsSearch].location);
		[server replyWithData:[[template buildImagePageWithImage:[[[path path] lastPathComponent] substringWithRange:range]] dataUsingEncoding:NSASCIIStringEncoding] MIMEType:[@"text/" stringByAppendingString:[[path path] pathExtension]]];
	}
		
	[server replyWithData:[NSData dataWithContentsOfFile:[IMAGE_PATH stringByAppendingString:[path path]]] MIMEType:[@"image/" stringByAppendingString:[[path path] pathExtension]]];
}

- (void)stopProcessing
{
    NSLog(@"STOP");
}

- (void)_startPictureTaking{
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"updateTime"] floatValue] target:self selector:@selector(_runPictureUtility:) userInfo:nil repeats:YES];
	[timer fire];
}

@end
