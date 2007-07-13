//
//  TLPrintView.m
//  TimeLapse
//
//  Created by Andy Kim on 7/23/06.
//  Copyright 2006 Potion Factory. All rights reserved.
//

#import "TLPrintView.h"
#import "TLDefines.h"


@implementation TLPrintView

- (id)initWithScreenshots:(NSArray*)screenshots
{
	mScreenshots = screenshots;

	// Calculate the frame
	
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
    NSRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
	rect.size = [printInfo paperSize];
	rect.size.height *= [self numberOfPages];

	[printInfo setVerticalPagination:NSClipPagination];

	return [self initWithFrame:rect];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (int)numRows
{
	NSRect rect = [self rectForPage:1];
	return (int)(rect.size.height / 140);
}

- (int)numCols
{
	NSRect rect = [self rectForPage:1];
	return (int)(rect.size.width / 200);
}

- (int)picsPerPage
{
	return [self numRows] * [self numCols];
}

- (int)numberOfPages
{
	return (int)ceil((float)[mScreenshots count] / [self picsPerPage]);
}

- (BOOL)knowsPageRange:(NSRangePointer)aRange
{
	aRange->location = 1;
	aRange->length = [self numberOfPages];
    return YES;
}

- (NSRect)rectForPage:(int)page
{
	int pageNumber = page - 1;
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	NSRect rect;
	
	rect.origin = [self frame].origin;
	rect.size = [printInfo paperSize];

	rect.origin.x += [printInfo leftMargin];
	rect.origin.y += rect.size.height * pageNumber + [printInfo topMargin];
	
	rect.size.width -= [printInfo leftMargin] + [printInfo rightMargin];
	rect.size.height -= [printInfo topMargin] + [printInfo bottomMargin];
	
	return rect;
}


- (void)drawRect:(NSRect)rect
{
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];

	NSSize papersize = [printInfo paperSize];
	
	// Draw the images
	int numRows = [self numRows];
	int numCols = [self numCols];

	int pagenum = rect.origin.y / papersize.height;
	
	int baseIndex = pagenum * numRows * numCols;
		
	for (int row = 0; row < numRows; row++)
	{
		for (int col = 0; col < numCols; col++)
		{
			int index = baseIndex + row*numCols + col;
			if (index >= [mScreenshots count]) return;
			
			id screenshot = [mScreenshots objectAtIndex:index];

			NSData *imageData = [screenshot valueForKey:@"imageData"];
														
			CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
			NSAssert(imageSource != nil, @"we have a NULL image source");

			CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			NSAssert(image != nil, @"We have a NULL image");

			float width = rect.size.width / numCols;
			float height = width / CGImageGetWidth(image) * CGImageGetHeight(image);

			// Finally draw the sucka
			CGRect drawRect = CGRectMake(NSMinX(rect) + col * width,
										 NSMaxY(rect) - (row+1) * height,
										 width - 8,
										 height - 8);
			CGContextDrawImage(ctx, drawRect, image);
			CFRelease(image);
			CFRelease(imageSource);
		}
	}
}

@end
