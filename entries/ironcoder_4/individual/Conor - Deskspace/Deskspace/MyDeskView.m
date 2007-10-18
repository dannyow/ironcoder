
#import "MyDeskView.h"
#import "MyFile.h"
#import "MyController.h"


//Space for the header
#define HEADER_RATIO 16

//Seconds to complete the animation
#define ANIMATION_TIME 2
//Number of steps to render for the animation
#define NUMBER_OF_ANIMATION_STEPS 20


@interface MyDeskView (private)
- (void)moveToNewDirectoryForward:(BOOL)forward;  //Do transiton, tell it forward or backwards for different transitions type
- (void)drawTransition:(NSTimer *)aTimer;  //Draw the transition
- (void)disolveAndQuit;  //Animation for when launching a file or app
- (void)drawDirectoryIntoContext:(CIContext *)aContext; //Draws the current directory into a context
- (void)upADirectory; //move upwards through the directory
CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh); //For creating a bitmap context that is empty
@end



@implementation MyDeskView

- (id)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self != nil) {
		
		//set controller
		controller = [NSApp delegate];
		
		//Get the current directory files 
		currentFiles = [[controller currentPathFiles] retain];
		
		//Header drawing info		
		float titleSize = frameRect.size.height / HEADER_RATIO;
		
		titleRect = NSMakeRect(0,frameRect.size.height - titleSize *1.8 ,frameRect.size.width,titleSize*1.3);
		directoryRect = NSMakeRect(40,titleRect.origin.y - titleSize/1.5  ,frameRect.size.width - 80,titleSize/2);
			
		
		//title writing style
		NSMutableParagraphStyle *paraStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
		[paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
		[paraStyle setAlignment:NSCenterTextAlignment];
		
		titleAtributtes = [[NSMutableDictionary alloc] init];
		[titleAtributtes setObject:[NSFont boldSystemFontOfSize:titleSize] forKey:NSFontAttributeName];
		[titleAtributtes setObject:[NSColor orangeColor] forKey:NSForegroundColorAttributeName];
		[titleAtributtes setObject:paraStyle forKey:NSParagraphStyleAttributeName];
		
		//directory writing style, same as title but smaller font
		directoryAtributtes = [titleAtributtes mutableCopy];
		[directoryAtributtes setObject:[NSFont boldSystemFontOfSize:titleSize/3] forKey:NSFontAttributeName];

		
		//line under the title 
		lineUnderTitle = [[NSBezierPath bezierPath] retain];
		[lineUnderTitle setLineWidth:titleSize/20];
		[lineUnderTitle moveToPoint:NSMakePoint(20, titleRect.origin.y)];
		[lineUnderTitle lineToPoint:NSMakePoint(titleRect.size.width - 40, titleRect.origin.y)];
		
		// Pumpkin for going backwards
		pumpkinArrow = [[NSImage imageNamed:@"pumpkinArrow"] retain];
		pumpkinArrowRect = NSMakeRect(20,titleRect.origin.y +4,titleRect.size.height , titleRect.size.height);
		
	}
	return self;
}

// This dealloc is not needed, as the object exist until the end;
// but never hurts.
- (void) dealloc {
	[controller release];
	[titleAtributtes release];
	[directoryAtributtes release];
	[lineUnderTitle release];
	[pumpkinArrow release];
	[currentFiles release];
	[super dealloc];
}


//Move backwards a directory
- (void)upADirectory {
	NSString *currentPath = [controller currentPath];
	
	// Don't backup past the root
	// Nothing happens if you do, but there no need to animate it
	if (![currentPath isEqualToString:@"/"]) {
		NSString *inclosingDirectory = [currentPath stringByDeletingLastPathComponent];
		[controller setCurrentPath:inclosingDirectory];
		[self moveToNewDirectoryForward:NO];
	}
}


#pragma mark Mouse Control

- (void)mouseDown:(NSEvent *)event
{
	//We are in the middle of an animation ignore click
	 if (timerFiredCount != 0)
		 return;
	
	//Option held down move up a directory
	if ([event modifierFlags] & NSAlternateKeyMask) {
		return [self upADirectory];
	}
	
	//get the click location in view
	NSPoint clickLocation = [event locationInWindow];
    clickLocation = [self convertPoint:clickLocation fromView:nil];
	
//DEBUG is set in the build flags for the debug version
#ifdef DEBUG
	NSLog(@"Click: %f %f", clickLocation.x, clickLocation.y );
#endif DEBUG
	
	//If the click is in the pumpkin then go up in the directory
	if (clickLocation.x > pumpkinArrowRect.origin.x) {
		if (clickLocation.y > pumpkinArrowRect.origin.y) {
			if (clickLocation.x < pumpkinArrowRect.origin.x + pumpkinArrowRect.size.width) {
				if (clickLocation.y < pumpkinArrowRect.origin.y + pumpkinArrowRect.size.height) {
					return [self upADirectory];
				}
			}
		}
	}
	
	
	
	//Find out in which icon the click was
	NSEnumerator *imageEnumerator = [currentFiles reverseObjectEnumerator];
	MyFile *nextFile;
	clickedFile = nil;
	
	while (nextFile = [imageEnumerator nextObject]) {
		NSRect drawingNSrect = [nextFile drawingRect];
		
		if (clickLocation.x > drawingNSrect.origin.x) {
			if (clickLocation.y > drawingNSrect.origin.y) {
				if (clickLocation.x < drawingNSrect.origin.x + drawingNSrect.size.width) {
					if (clickLocation.y < drawingNSrect.origin.y + drawingNSrect.size.height) {
						//found icon clicked
						clickedFile = nextFile;
						deltaOriginFromClick.width = clickLocation.x - drawingNSrect.origin.x;
						deltaOriginFromClick.height = clickLocation.y - drawingNSrect.origin.y;
						break;
					}
				}
			}
		}
	}
	
	// There was a clicked file
	if (clickedFile != nil) {
		// Single click redisplay so that title is shown and highlight is shown
		if ([event clickCount] == 1) {
			[self display];
		}
		//Double click move into the directory if it's a directory, otherwise open file and quit program
		else if ([event clickCount] == 2) {
			NSString *pathOfFileClicked = [clickedFile absolutePath];
			
			//it's a directory move into it
			if ([clickedFile isDirectory] && ![pathOfFileClicked hasSuffix:@".app"]) {
				[controller setCurrentPath:pathOfFileClicked];
				[self moveToNewDirectoryForward:YES];
				return;
			}
			else {
				//start the open so it's open by the time we are done with the dissolve CIFilter
				[[NSWorkspace sharedWorkspace] openFile:pathOfFileClicked];
				
				//Let the controller know to bring this app forward after quiting
				NSString *anAppllication = nil;
				[[NSWorkspace  sharedWorkspace] getInfoForFile:pathOfFileClicked application:&anAppllication type:nil];
				[controller setAppToLaunch:anAppllication];
				
				//Start quirting animation
				[self disolveAndQuit];
			}
		}
	}
				
	//[super mouseDown: event];
}


//If a file was clicked then move the file with the drag 
- (void)mouseDragged:(NSEvent *)theEvent {
	
	if (clickedFile != nil) {
		NSPoint clickLocation = [theEvent locationInWindow];
		clickLocation = [self convertPoint:clickLocation fromView:nil];
		
		//The origin is that of the click minus the delta of the click from the origin
		clickLocation.x = clickLocation.x - deltaOriginFromClick.width;
		clickLocation.y = clickLocation.y - deltaOriginFromClick.height;
		mouseBeingDragged = YES;
		
		[clickedFile setLocation:clickLocation];
		[self display];
	}
	
}


//If a mouse drag is over save the location of the file moved
- (void)mouseUp:(NSEvent *)theEvent {
	
	if (mouseBeingDragged && clickedFile != nil) {
		
		[controller saveLocationForFile:clickedFile];
		clickedFile = nil;
	}
	mouseBeingDragged = NO;
}




#pragma mark Animation

//A quiting animaition using the CIDissolve filter
- (void)disolveAndQuit {
	
	//create an CIImage of the current view as the sourceImage
	[self lockFocus];
	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]] autorelease];
	[self unlockFocus];
	CIImage *sourceImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
	
	
	
	//create a CIImage all Black 
	CGRect imageExtent = [sourceImage extent];
	CGContextRef myBitmapContext = MyCreateBitmapContext (imageExtent.size.width, imageExtent.size.height);		
	CGImageRef myImage = CGBitmapContextCreateImage (myBitmapContext);
	CIImage *targetImage = [CIImage imageWithCGImage:myImage];
	CGContextRelease (myBitmapContext);
	CGImageRelease(myImage);
	
	
	//Set the filter for the transition
	transitionFilter = [[CIFilter filterWithName:@"CIDissolveTransition"] retain];
	[transitionFilter setValue:sourceImage forKey:@"inputImage"];
	[transitionFilter setValue:targetImage forKey:@"inputTargetImage"];
	
	
	//Set the BOOL for qutting and start the timer for the animation
	quitting = YES;
	[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(drawTransition:) userInfo:nil repeats:YES];
				
}

//Animate moving to a new directory
// The forwad property BOOL you know what animation to use
- (void)moveToNewDirectoryForward:(BOOL)forward {
	
	//Get the new icons for the new directory
	[currentFiles release];
	currentFiles = [[controller currentPathFiles] retain];
	
	
	//create an CIImage of the current view as the sourceImage
	[self lockFocus];
	NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:[self frame]] autorelease];
	[self unlockFocus];
	CIImage *sourceImage = [[CIImage alloc] initWithBitmapImageRep:bitmap];
	
	
	//Create a vector of the soucce image we are going to need it as input to the CIFilter for extent
	// We also need the CGRect in creating the bitmap of the next screen
	CGRect imageExtent = [sourceImage extent];
	CIVector *extent = [CIVector vectorWithX: 0  Y: 0  Z: imageExtent.size.width  W: imageExtent.size.height];
	
	
	
	
	
	//create a CIImage of the next directory as the targetImage
	CGContextRef myBitmapContext = MyCreateBitmapContext (imageExtent.size.width, imageExtent.size.height);
	CIContext *context = [CIContext contextWithCGContext:myBitmapContext options:nil];
	
	[self drawDirectoryIntoContext:context];
	
	CGImageRef myImage = CGBitmapContextCreateImage (myBitmapContext);
	CIImage *targetImage = [CIImage imageWithCGImage:myImage];
	CGContextRelease (myBitmapContext);
	CGImageRelease(myImage);
	
	
	//CIImage of shading for the transition
	NSURL *url = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"Shading" ofType: @"tiff"]];
	CIImage *shadingImage = [CIImage imageWithContentsOfURL: url];
	
	//If moving forward use the Ripple CIImage filter 
	if (forward) {
		transitionFilter = [[CIFilter filterWithName:@"CIRippleTransition"] retain];
		
		NSRect locationOfIcon = [clickedFile drawingRect];
		[transitionFilter setValue:[NSNumber numberWithFloat:60] forKey:@"inputWidth"];  //0 to 600: 300 default
		[transitionFilter setValue:[NSNumber numberWithFloat:50.0] forKey:@"inputScale"]; // -1 to 1
		[transitionFilter setValue:[CIVector vectorWithX:locationOfIcon.origin.x + (locationOfIcon.size.width /2) Y:locationOfIcon.origin.y + (locationOfIcon.size.height /2)] forKey:@"inputCenter"]; //150, 150 default
		[transitionFilter setValue:shadingImage forKey:@"inputShadingImage"];
		
	}
	else {
		
		//Moving up the directory use the CopyMachine CIFilter
		
		transitionFilter = [[CIFilter filterWithName:@"CICopyMachineTransition"] retain];
		[transitionFilter setDefaults];
		
		//In a yellow-orange for halloween
		[transitionFilter setValue:[CIColor  colorWithRed:212.0/255.0 green:123.0/255.0 blue:7.0/255.0] forKey:@"inputColor"]; 
		
		//Other values of the filter we are not going to use
		/*
		[transitionFilter setValue:[NSNumber numberWithFloat:2] forKey:@"inputOpacity"];  //0 to 3:  default: 1.3
		[transitionFilter setValue:[NSNumber numberWithFloat:100] forKey:@"inputWidth"]; // 0.1 to 500 default: 200
		 [transitionFilter setValue:[NSNumber numberWithFloat:1.5] forKey:@"inputAngle"]; // 0 to 6.28 default: 0
		 */

	}
	
	
	//Set the images needed for the filter
	[transitionFilter setValue:sourceImage forKey:@"inputImage"];
	[transitionFilter setValue:targetImage forKey:@"inputTargetImage"];
	[transitionFilter setValue:extent forKey:@"inputExtent"];
	
	
	//Start the timer for the animation
	[NSTimer scheduledTimerWithTimeInterval:ANIMATION_TIME/NUMBER_OF_ANIMATION_STEPS target:self selector:@selector(drawTransition:) userInfo:nil repeats:YES];
				
}


- (void)drawTransition:(NSTimer *)aTimer {
	
	//Animation is over destroy all objects not needed
	if (timerFiredCount > NUMBER_OF_ANIMATION_STEPS) {
		[aTimer invalidate];
		[transitionFilter release];
		transitionFilter = nil;
		timerFiredCount = 0;
		
		//We are in the dissolve and quit animation, so quit
		if (quitting)
			[NSApp terminate:self];
		
		//[self setNeedsDisplay:YES];
	}
	else {
		timerFiredCount++;
		[self display];
		
	}
}




#pragma mark Drawing



- (void)drawRect:(NSRect)rect
{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	CIContext *context = [[NSGraphicsContext currentContext] CIContext];

	// Draw the header
	// Only draw if the program is not doing the quiting disolve
	if (!quitting) {
		
		//Draw a yellow line at the top to mark a header space for the name of the clicked file
		 [[NSColor yellowColor] set];
		 [lineUnderTitle stroke];

		 //Write out the current file path under the line
		 [[NSColor yellowColor] set];
		 [[controller currentPath] drawInRect:directoryRect withAttributes:directoryAtributtes];
		 
		 
		 //Draw the pumpking image to left
		 NSRect imageSize = {0,0,0,0};
		 imageSize.size = [pumpkinArrow size];
		 [pumpkinArrow drawInRect:pumpkinArrowRect fromRect:imageSize operation:NSCompositeCopy fraction:1.0];
	}

	
	//Draw a transition 
	if (timerFiredCount > 0) {
		
		//Animation time moves from 0 to 1 so devide q by the number of animation steps to know what time to ask for
		[transitionFilter setValue:[NSNumber numberWithFloat:(float)timerFiredCount * 1/NUMBER_OF_ANIMATION_STEPS] forKey:@"inputTime"];  //0 to 1
		CIImage *transitionImage = [[transitionFilter valueForKey:@"outputImage"] retain];

		NSRect drawingNSrect = [self bounds];
		CGRect  drawingRect = CGRectMake(NSMinX(drawingNSrect), NSMinY(drawingNSrect), NSWidth(drawingNSrect), NSHeight(drawingNSrect));
		
		[context  drawImage:transitionImage inRect:drawingRect fromRect:[transitionImage extent]];
		
		timerFiredCount++;
		
	}
	else {
		//If there is a click file draw the name of the file to the header
		 if (clickedFile != nil) {
			 
			 [[[clickedFile absolutePath] lastPathComponent] drawInRect:titleRect withAttributes:titleAtributtes];
		 }
		 
		//Draw the current directory into the current context
		[self drawDirectoryIntoContext:context];
	}
	
	[pool release];
}


-(void)drawDirectoryIntoContext:(CIContext *)aContext  {
	
	NSEnumerator *imageEnumerator = [currentFiles objectEnumerator];
	MyFile *nextFile;
	
	while (nextFile = [imageEnumerator nextObject]) {
		
		CIImage *imageToDraw = [nextFile icon]; 
		
		if (imageToDraw) {
			
			NSRect drawingNSrect = [nextFile drawingRect];
			
			// the file was the last clicked file
			// Do edge work on the selection to highlight
			if (nextFile == clickedFile) {
				
				CIFilter *filter = [CIFilter filterWithName:@"CIEdges"];
				[filter setValue:imageToDraw forKey:@"inputImage"];
				[filter setValue:[NSNumber numberWithFloat:4.0] forKey:@"inputIntensity"];
				imageToDraw = [filter valueForKey:@"outputImage"];
			}
			
			
			CGRect  drawingRect = CGRectMake(NSMinX(drawingNSrect), NSMinY(drawingNSrect), NSWidth(drawingNSrect), NSHeight(drawingNSrect));
			
			[aContext  drawImage:imageToDraw inRect:drawingRect fromRect:[imageToDraw extent]];
			
		}
	}	
}



- (void)setUpGState {
	[super setUpGState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
}


// Copied straight from the Apple documentaion about drawing
// file:///Developer/ADC%20Reference%20Library/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_context/chapter_3_section_4.html
CGContextRef MyCreateBitmapContext (int pixelsWide, int pixelsHigh) 
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
	
    bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
	bitmapData = malloc( bitmapByteCount );
	if (bitmapData == NULL) 
	{
		fprintf (stderr, "Memory not allocated!");
		return NULL;
	}
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast);
	if (context== NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
		return NULL;
	}
	CGColorSpaceRelease( colorSpace );
	
	return context;
}



@end
