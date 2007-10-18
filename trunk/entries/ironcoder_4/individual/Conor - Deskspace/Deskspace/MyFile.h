//
//  MyFile.h
//  Deskspace


#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreImage.h>


@interface MyFile : NSObject {
	
	//All Attributes of a file
	NSDate *modificationDate;
	NSString *absolutePath;
	unsigned long long fileSize;
	BOOL isDirectory;
	CIImage *icon;  //Our main man
	NSRect drawingRect;  //Location and size to be drawn at
}


- (id)initWithPath:(NSString *)aPath;

- (CIImage *)icon;

- (void)setLocation:(NSPoint)aPoint;
- (NSPoint)location;

- (void)setDrawingRect:(NSRect)aRect;
- (NSRect)drawingRect;

- (unsigned long long)fileSize;
- (NSDate *)modificationDate;
- (NSString *)absolutePath;
- (BOOL)isDirectory;


//Apply CIFilters to the icon 
- (void)setVintage:(float)anIntensity;
- (void)setBulge:(float)aBulge;


//For sorting the files according to size and mod date
-(NSComparisonResult)fileSizeCompare:(MyFile *)aFile;
-(NSComparisonResult)modDateCompare:(MyFile *)aFile;

@end
