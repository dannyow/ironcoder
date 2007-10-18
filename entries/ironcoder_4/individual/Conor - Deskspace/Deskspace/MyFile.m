//
//  MyFile.m
//  Deskspace


#import "MyFile.h"
#import "MyController.h"


@implementation MyFile

- (id)initWithPath:(NSString *)aPath {
	self = [super init];
	if (self != nil) {
	
		NSDictionary *fileAttributes = [[NSFileManager defaultManager] fileAttributesAtPath:aPath traverseLink:YES];
		
		absolutePath = [aPath retain];
		modificationDate = [[fileAttributes fileModificationDate] retain]; 
		fileSize = [fileAttributes fileSize]; //long long in bytes

		
		if ([[fileAttributes fileType] isEqualToString:NSFileTypeDirectory])
			isDirectory = YES;
		
		
		NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:absolutePath];
		icon = [[CIImage alloc] initWithBitmapImageRep:[[iconImage representations] objectAtIndex:0]];
	
	}
	return self;
}


- (void) dealloc {
	[absolutePath release];
	[modificationDate release];
	[icon release];
	[super dealloc];
}


#pragma mark Setters and Getters

- (CIImage *)icon {
	return icon;
}

- (void)setLocation:(NSPoint)aPoint {
	drawingRect.origin = aPoint;
}
- (NSPoint)location {
	return drawingRect.origin;
}

- (void)setDrawingRect:(NSRect)aRect {
	drawingRect = aRect;
}
- (NSRect)drawingRect {
	return drawingRect;
}

- (unsigned long long)fileSize {
	return fileSize;
}
- (NSDate *)modificationDate {
	return modificationDate;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"MyFile: %@", absolutePath];
}

- (NSString *)absolutePath; {
	return absolutePath;
}

- (BOOL)isDirectory {
	return isDirectory;
}


#pragma mark CIImage Operations

// Set the sepia tone to denote oldness
// Could also use the gloom CIFilter for added contrast
// Another option is a couple of CIFilter pinch to denote crumbled icon
- (void)setVintage:(float)anIntensity {
	
	CIFilter *filter = [CIFilter filterWithName:@"CISepiaTone"];
	[filter setValue:icon forKey:@"inputImage"];
	[filter setValue:[NSNumber numberWithFloat:anIntensity] forKey:@"inputIntensity"];
	[icon release];
    icon = [[filter valueForKey:@"outputImage"] retain];
	 
}


//Set the fatness of the icon to denote size
- (void)setBulge:(float)aBulge {
	
	//Need to scale image to fit width
	CIFilter *fa = [CIFilter filterWithName:@"CIAffineTransform"];
	[fa setValue:icon forKey:@"inputImage"];
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleBy:drawingRect.size.width / 128];
	[fa setValue:transform forKey:@"inputTransform"]; 
	[icon release];
    icon = [[fa valueForKey:@"outputImage"] retain];

	//Set the bulge
	CIFilter *filter = [CIFilter filterWithName:@"CIBumpDistortion"];
	[filter setValue:icon forKey:@"inputImage"];
	[filter setValue:[NSNumber numberWithFloat:drawingRect.size.width / 1.5] forKey:@"inputRadius"];  //0 to 600: 300 default
	[filter setValue:[NSNumber numberWithFloat:aBulge - 1.0] forKey:@"inputScale"]; // -1 to 1
	[filter setValue:[CIVector vectorWithX:drawingRect.size.width /2 Y:drawingRect.size.height /2] forKey:@"inputCenter"]; //150, 150 default
	[icon release];
    icon = [[filter valueForKey:@"outputImage"] retain];
	
}


#pragma mark compare

-(NSComparisonResult)fileSizeCompare:(MyFile *)aFile {
	if (fileSize > [aFile fileSize])
		return NSOrderedAscending;
	return NSOrderedDescending;
}
-(NSComparisonResult)modDateCompare:(MyFile *)aFile {
	return [modificationDate compare:[aFile modificationDate]];

}

@end
