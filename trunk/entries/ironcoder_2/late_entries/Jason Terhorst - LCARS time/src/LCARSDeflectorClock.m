//
//  LCARSDeflectorClock.m
//  lcarstime
//
//  Created by Jason Terhorst on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "LCARSDeflectorClock.h"

#define PI 3.14159265358979323846

static inline double radians(double degrees) { return degrees * PI / 180; }

@implementation LCARSDeflectorClock

- initWithRect:(CGRect*) rect  {
    self = [super init];
	
    w = rect->size.width;
    h = rect->size.height;
    
    x = rand() % (int)w;
    y = 110 + (rand() % 10);
    
   // increment = 10; //rand() % 60;
  //  increment = increment * .01;
    //increment += 4.5f;
    //NSLog(@"[%f, %f] [%f, %f] %f", x, y, w, h, increment);
    
    {
        NSCalendarDate *date = [NSCalendarDate calendarDate];
       
		hour = [date hourOfDay];
		minutes = [date minuteOfHour];
		seconds = [date secondOfMinute];
		
    }
    
    return self;
}

- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) boxrect {
	
	
	NSCalendarDate *date = [NSCalendarDate calendarDate];
	
	hour = [date hourOfDay];
	minutes = [date minuteOfHour];
	seconds = [date secondOfMinute];
    //[self drawHorzClock:context withRect:rect];
    //[sun paint:context frame:rect];
    //[self drawClouds:context withRect:rect];
    //CGMutablePathRef path;
	CGContextSetLineWidth(context, 5.0);
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1.0);
	CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1.0);
	float boxw,boxh,boxx,boxy;
	boxw = boxrect->size.width;
	boxh = boxrect->size.height;
	boxx = boxrect->origin.x;
	boxy = boxrect->origin.y;
	CGRect newRect = CGRectMake(boxx,boxy,boxw,boxh);
	
	CGRect oneRect = CGRectMake(boxx,boxh-70,35,70);
	CGRect twoRect = CGRectMake(boxx+45,boxh-70,35,70);
	CGRect threeRect = CGRectMake(boxx+100,boxh-70,35,70);
	CGRect fourRect = CGRectMake(boxx+145,boxh-70,35,70);
	CGRect fiveRect = CGRectMake(boxx+200,boxh-70,35,70);
	CGRect sixRect = CGRectMake(boxx+245,boxh-70,35,70);

	CGContextBeginPage(context, &newRect);
	CGContextSetRGBFillColor(context, 0.31, 0.43, 0.76, 1);
    CGContextSetRGBStrokeColor(context, 0.31, 0.43, 0.76, 1);
	
	//CGContextAddArc(context, 55, 210, 36, radians(25), radians(65), 0);
	CGContextAddEllipseInRect(context, newRect);
    //CGContextStrokePath(context);
	//CGContextFillPath(context);
	
	NSImage* imageZero = [NSImage imageNamed:@"0.jpg"];
	NSData* cocoaDataZero = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageZero representations]];
	CFDataRef carbonDataZero = (CFDataRef)cocoaDataZero;
	CGImageSourceRef imageSourceRefZero = CGImageSourceCreateWithData(carbonDataZero, NULL);
	CGImageRef cgImageZero = CGImageSourceCreateImageAtIndex(imageSourceRefZero, 0, NULL);
	
	NSImage* imageOne = [NSImage imageNamed:@"1.jpg"];
	NSData* cocoaDataOne = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageOne representations]];
	CFDataRef carbonDataOne = (CFDataRef)cocoaDataOne;
	CGImageSourceRef imageSourceRefOne = CGImageSourceCreateWithData(carbonDataOne, NULL);
	CGImageRef cgImageOne = CGImageSourceCreateImageAtIndex(imageSourceRefOne, 0, NULL);
	
	NSImage* imageTwo = [NSImage imageNamed:@"2.jpg"];
	NSData* cocoaDataTwo = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageTwo representations]];
	CFDataRef carbonDataTwo = (CFDataRef)cocoaDataTwo;
	CGImageSourceRef imageSourceRefTwo = CGImageSourceCreateWithData(carbonDataTwo, NULL);
	CGImageRef cgImageTwo = CGImageSourceCreateImageAtIndex(imageSourceRefTwo, 0, NULL);
	
	NSImage* imageThree = [NSImage imageNamed:@"3.jpg"];
	NSData* cocoaDataThree = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageThree representations]];
	CFDataRef carbonDataThree = (CFDataRef)cocoaDataThree;
	CGImageSourceRef imageSourceRefThree = CGImageSourceCreateWithData(carbonDataThree, NULL);
	CGImageRef cgImageThree = CGImageSourceCreateImageAtIndex(imageSourceRefThree, 0, NULL);
	
	NSImage* imageFour = [NSImage imageNamed:@"4.jpg"];
	NSData* cocoaDataFour = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageFour representations]];
	CFDataRef carbonDataFour = (CFDataRef)cocoaDataFour;
	CGImageSourceRef imageSourceRefFour = CGImageSourceCreateWithData(carbonDataFour, NULL);
	CGImageRef cgImageFour = CGImageSourceCreateImageAtIndex(imageSourceRefFour, 0, NULL);
	
	NSImage* imageFive = [NSImage imageNamed:@"5.jpg"];
	NSData* cocoaDataFive = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageFive representations]];
	CFDataRef carbonDataFive = (CFDataRef)cocoaDataFive;
	CGImageSourceRef imageSourceRefFive = CGImageSourceCreateWithData(carbonDataFive, NULL);
	CGImageRef cgImageFive = CGImageSourceCreateImageAtIndex(imageSourceRefFive, 0, NULL);
	
	NSImage* imageSix = [NSImage imageNamed:@"6.jpg"];
	NSData* cocoaDataSix = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageSix representations]];
	CFDataRef carbonDataSix = (CFDataRef)cocoaDataSix;
	CGImageSourceRef imageSourceRefSix = CGImageSourceCreateWithData(carbonDataSix, NULL);
	CGImageRef cgImageSix = CGImageSourceCreateImageAtIndex(imageSourceRefSix, 0, NULL);
	
	NSImage* imageSeven = [NSImage imageNamed:@"7.jpg"];
	NSData* cocoaDataSeven = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageSeven representations]];
	CFDataRef carbonDataSeven = (CFDataRef)cocoaDataSeven;
	CGImageSourceRef imageSourceRefSeven = CGImageSourceCreateWithData(carbonDataSeven, NULL);
	CGImageRef cgImageSeven = CGImageSourceCreateImageAtIndex(imageSourceRefSeven, 0, NULL);
	
	NSImage* imageEight = [NSImage imageNamed:@"8.jpg"];
	NSData* cocoaDataEight = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageEight representations]];
	CFDataRef carbonDataEight = (CFDataRef)cocoaDataEight;
	CGImageSourceRef imageSourceRefEight = CGImageSourceCreateWithData(carbonDataEight, NULL);
	CGImageRef cgImageEight = CGImageSourceCreateImageAtIndex(imageSourceRefEight, 0, NULL);
	
	NSImage* imageNine = [NSImage imageNamed:@"9.jpg"];
	NSData* cocoaDataNine = [NSBitmapImageRep TIFFRepresentationOfImageRepsInArray: [imageNine representations]];
	CFDataRef carbonDataNine = (CFDataRef)cocoaDataNine;
	CGImageSourceRef imageSourceRefNine = CGImageSourceCreateWithData(carbonDataNine, NULL);
	CGImageRef cgImageNine = CGImageSourceCreateImageAtIndex(imageSourceRefNine, 0, NULL);
	
	float hourssingle = hour;
	if (hour < 10) {
		hourssingle = hour;
		CGContextDrawImage(context, oneRect, cgImageZero);
	} else {
		if (hour >= 90) {
			hourssingle = hour - 90;
			CGContextDrawImage(context, oneRect, cgImageNine);
		} else if (hour >= 80) {
			hourssingle = hour - 80;
			CGContextDrawImage(context, oneRect, cgImageEight);
		} else if (hour >= 70) {
			hourssingle = hour - 70;
			CGContextDrawImage(context, oneRect, cgImageSeven);
		} else if (hour >= 60) {
			hourssingle = hour - 60;
			CGContextDrawImage(context, oneRect, cgImageSix);
		} else if (hour >= 50) {
			hourssingle = hour - 50;
			CGContextDrawImage(context, oneRect, cgImageFive);
		} else if (hour >= 40) {
			hourssingle = hour - 40;
			CGContextDrawImage(context, oneRect, cgImageFour);
		} else if (hour >= 30) {
			hourssingle = hour - 30;
			CGContextDrawImage(context, oneRect, cgImageThree);
		} else if (hour >= 20) {
			hourssingle = hour - 20;
			CGContextDrawImage(context, oneRect, cgImageTwo);
		} else if (hour >= 10) {
			hourssingle = hour - 10;
			CGContextDrawImage(context, oneRect, cgImageOne);
		} else {
			hourssingle = hour;
			CGContextDrawImage(context, oneRect, cgImageZero);
		}
	}
	if (hourssingle >= 9) {
		CGContextDrawImage(context, twoRect, cgImageNine);
	} else if (hourssingle >= 8) {
		CGContextDrawImage(context, twoRect, cgImageEight);
	} else if (hourssingle >= 7) {
		CGContextDrawImage(context, twoRect, cgImageSeven);
	} else if (hourssingle >= 6) {
		CGContextDrawImage(context, twoRect, cgImageSix);
	} else if (hourssingle >= 5) {
		CGContextDrawImage(context, twoRect, cgImageFive);
	} else if (hourssingle >= 4) {
		CGContextDrawImage(context, twoRect, cgImageFour);
	} else if (hourssingle >= 3) {
		CGContextDrawImage(context, twoRect, cgImageThree);
	} else if (hourssingle >= 2) {
		CGContextDrawImage(context, twoRect, cgImageTwo);
	} else if (hourssingle >= 1) {
		CGContextDrawImage(context, twoRect, cgImageOne);
	} else {
		CGContextDrawImage(context, twoRect, cgImageZero);
	}
	
	float minutessingle = minutes;
	if (minutes < 10) {
		minutessingle = minutes;
		CGContextDrawImage(context, threeRect, cgImageZero);
	} else {
		if (minutes >= 90) {
			minutessingle = minutes - 90;
			CGContextDrawImage(context, threeRect, cgImageNine);
		} else if (minutes >= 80) {
			minutessingle = minutes - 80;
			CGContextDrawImage(context, threeRect, cgImageEight);
		} else if (minutes >= 70) {
			minutessingle = minutes - 70;
			CGContextDrawImage(context, threeRect, cgImageSeven);
		} else if (minutes >= 60) {
			minutessingle = minutes - 60;
			CGContextDrawImage(context, threeRect, cgImageSix);
		} else if (minutes >= 50) {
			minutessingle = minutes - 50;
			CGContextDrawImage(context, threeRect, cgImageFive);
		} else if (minutes >= 40) {
			minutessingle = minutes - 40;
			CGContextDrawImage(context, threeRect, cgImageFour);
		} else if (minutes >= 30) {
			minutessingle = minutes - 30;
			CGContextDrawImage(context, threeRect, cgImageThree);
		} else if (minutes >= 20) {
			minutessingle = minutes - 20;
			CGContextDrawImage(context, threeRect, cgImageTwo);
		} else if (minutes >= 10) {
			minutessingle = minutes - 10;
			CGContextDrawImage(context, threeRect, cgImageOne);
		} else {
			minutessingle = minutes;
			CGContextDrawImage(context, threeRect, cgImageZero);
		}
	}
	NSLog(@"minutessingle: %f", minutessingle);
	if (minutessingle >= 9) {
		CGContextDrawImage(context, fourRect, cgImageNine);
	} else if (minutessingle >= 8) {
		CGContextDrawImage(context, fourRect, cgImageEight);
	} else if (minutessingle >= 7) {
		CGContextDrawImage(context, fourRect, cgImageSeven);
	} else if (minutessingle >= 6) {
		CGContextDrawImage(context, fourRect, cgImageSix);
	} else if (minutessingle >= 5) {
		CGContextDrawImage(context, fourRect, cgImageFive);
	} else if (minutessingle >= 4) {
		CGContextDrawImage(context, fourRect, cgImageFour);
	} else if (minutessingle >= 3) {
		CGContextDrawImage(context, fourRect, cgImageThree);
	} else if (minutessingle >= 2) {
		CGContextDrawImage(context, fourRect, cgImageTwo);
	} else if (minutessingle >= 1) {
		CGContextDrawImage(context, fourRect, cgImageOne);
	} else {
		CGContextDrawImage(context, fourRect, cgImageZero);
	}
	
	float secondssingle = seconds;
	if (seconds < 10) {
		secondssingle = seconds;
		CGContextDrawImage(context, fiveRect, cgImageZero);
	} else {
		if (seconds >= 90) {
			secondssingle = seconds - 90;
			CGContextDrawImage(context, fiveRect, cgImageNine);
		} else if (seconds >= 80) {
			secondssingle = seconds - 80;
			CGContextDrawImage(context, fiveRect, cgImageEight);
		} else if (seconds >= 70) {
			secondssingle = seconds - 70;
			CGContextDrawImage(context, fiveRect, cgImageSeven);
		} else if (seconds >= 60) {
			secondssingle = seconds - 60;
			CGContextDrawImage(context, fiveRect, cgImageSix);
		} else if (seconds >= 50) {
			secondssingle = seconds - 50;
			CGContextDrawImage(context, fiveRect, cgImageFive);
		} else if (seconds >= 40) {
			secondssingle = seconds - 40;
			CGContextDrawImage(context, fiveRect, cgImageFour);
		} else if (seconds >= 30) {
			secondssingle = seconds - 30;
			CGContextDrawImage(context, fiveRect, cgImageThree);
		} else if (seconds >= 20) {
			secondssingle = seconds - 20;
			CGContextDrawImage(context, fiveRect, cgImageTwo);
		} else if (seconds >= 10) {
			secondssingle = seconds - 10;
			CGContextDrawImage(context, fiveRect, cgImageOne);
		} else {
			secondssingle = seconds;
			CGContextDrawImage(context, fiveRect, cgImageZero);
		}
	}
	NSLog(@"minutessingle: %f", secondssingle);
	if (secondssingle >= 9) {
		CGContextDrawImage(context, sixRect, cgImageNine);
	} else if (secondssingle >= 8) {
		CGContextDrawImage(context, sixRect, cgImageEight);
	} else if (secondssingle >= 7) {
		CGContextDrawImage(context, sixRect, cgImageSeven);
	} else if (secondssingle >= 6) {
		CGContextDrawImage(context, sixRect, cgImageSix);
	} else if (secondssingle >= 5) {
		CGContextDrawImage(context, sixRect, cgImageFive);
	} else if (secondssingle >= 4) {
		CGContextDrawImage(context, sixRect, cgImageFour);
	} else if (secondssingle >= 3) {
		CGContextDrawImage(context, sixRect, cgImageThree);
	} else if (secondssingle >= 2) {
		CGContextDrawImage(context, sixRect, cgImageTwo);
	} else if (secondssingle >= 1) {
		CGContextDrawImage(context, sixRect, cgImageOne);
	} else {
		CGContextDrawImage(context, sixRect, cgImageZero);
	}
	
	
	
	//CGContextDrawImage(context, sixRect, cgImageFive);
	
	CGImageRelease(cgImageZero);
	CGImageRelease(cgImageOne);
	CGImageRelease(cgImageTwo);
	CGImageRelease(cgImageThree);
	CGImageRelease(cgImageFour);
	CGImageRelease(cgImageFive);
	CGImageRelease(cgImageSix);
	CGImageRelease(cgImageSeven);
	CGImageRelease(cgImageEight);
	CGImageRelease(cgImageNine);
	
}

@end
