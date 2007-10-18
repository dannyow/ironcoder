//
//  LCARSShieldClock.m
//  lcarstime
//
//  Created by Jason Terhorst on 7/23/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "LCARSShieldClock.h"

#define PI 3.14159265358979323846

static inline double radians(double degrees) { return degrees * PI / 180; }

@implementation LCARSShieldClock

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
	
	//CGRect oneRect = CGRectMake(boxx,boxh-70,35,70);
	//CGRect twoRect = CGRectMake(boxx+45,boxh-70,35,70);
	//CGRect threeRect = CGRectMake(boxx+100,boxh-70,35,70);
	//CGRect fourRect = CGRectMake(boxx+145,boxh-70,35,70);
	//CGRect fiveRect = CGRectMake(boxx+200,boxh-70,35,70);
	//CGRect sixRect = CGRectMake(boxx+245,boxh-70,35,70);
	
	float hourx, houry, hourw, hourh;
	float minutex, minutey, minutew, minuteh;
	float secondx, secondy, secondw, secondh;
	
	//CGContextAddArc(context, 55, 210, 36, radians(25), radians(65), 0);
	
	//CGContextFillPath(context);
	
	float hourssingle = hour;
	if (hour < 10) {
		hourssingle = hour;
		//CGContextDrawImage(context, oneRect, cgImageZero);
	} else {
		if (hour >= 90) {
			hourssingle = hour - 90;
			//CGContextDrawImage(context, oneRect, cgImageNine);
		} else if (hour >= 80) {
			hourssingle = hour - 80;
			//CGContextDrawImage(context, oneRect, cgImageEight);
		} else if (hour >= 70) {
			hourssingle = hour - 70;
			//CGContextDrawImage(context, oneRect, cgImageSeven);
		} else if (hour >= 60) {
			hourssingle = hour - 60;
			//CGContextDrawImage(context, oneRect, cgImageSix);
		} else if (hour >= 50) {
			hourssingle = hour - 50;
			//CGContextDrawImage(context, oneRect, cgImageFive);
		} else if (hour >= 40) {
			hourssingle = hour - 40;
			//CGContextDrawImage(context, oneRect, cgImageFour);
		} else if (hour >= 30) {
			hourssingle = hour - 30;
			//CGContextDrawImage(context, oneRect, cgImageThree);
		} else if (hour >= 20) {
			hourssingle = hour - 20;
			//CGContextDrawImage(context, oneRect, cgImageTwo);
		} else if (hour >= 10) {
			hourssingle = hour - 10;
			//CGContextDrawImage(context, oneRect, cgImageOne);
		} else {
			hourssingle = hour;
			//CGContextDrawImage(context, oneRect, cgImageZero);
		}
	}
	if (hourssingle >= 9) {
		hourw = boxw * 0.9;
		hourh = boxh * 0.9;
		//CGContextDrawImage(context, twoRect, cgImageNine);
	} else if (hourssingle >= 8) {
		hourw = boxw * 0.8;
		hourh = boxh * 0.8;
		//CGContextDrawImage(context, twoRect, cgImageEight);
	} else if (hourssingle >= 7) {
		hourw = boxw * 0.7;
		hourh = boxh * 0.7;
		//CGContextDrawImage(context, twoRect, cgImageSeven);
	} else if (hourssingle >= 6) {
		hourw = boxw * 0.6;
		hourh = boxh * 0.6;
		//CGContextDrawImage(context, twoRect, cgImageSix);
	} else if (hourssingle >= 5) {
		hourw = boxw * 0.5;
		hourh = boxh * 0.5;
		//CGContextDrawImage(context, twoRect, cgImageFive);
	} else if (hourssingle >= 4) {
		hourw = boxw * 0.4;
		hourh = boxh * 0.4;
		//CGContextDrawImage(context, twoRect, cgImageFour);
	} else if (hourssingle >= 3) {
		hourw = boxw * 0.3;
		hourh = boxh * 0.3;
		//CGContextDrawImage(context, twoRect, cgImageThree);
	} else if (hourssingle >= 2) {
		hourw = boxw * 0.2;
		hourh = boxh * 0.2;
		//CGContextDrawImage(context, twoRect, cgImageTwo);
	} else if (hourssingle >= 1) {
		hourw = boxw * 0.1;
		hourh = boxh * 0.1;
		//CGContextDrawImage(context, twoRect, cgImageOne);
	} else {
		hourw = boxw * 0.0;
		hourh = boxh * 0.0;
		//CGContextDrawImage(context, twoRect, cgImageZero);
	}
	
	float minutessingle = minutes;
	if (minutes < 10) {
		minutessingle = minutes;
		//CGContextDrawImage(context, threeRect, cgImageZero);
	} else {
		if (minutes >= 90) {
			minutessingle = minutes - 90;
			//CGContextDrawImage(context, threeRect, cgImageNine);
		} else if (minutes >= 80) {
			minutessingle = minutes - 80;
			//CGContextDrawImage(context, threeRect, cgImageEight);
		} else if (minutes >= 70) {
			minutessingle = minutes - 70;
			//CGContextDrawImage(context, threeRect, cgImageSeven);
		} else if (minutes >= 60) {
			minutessingle = minutes - 60;
			//CGContextDrawImage(context, threeRect, cgImageSix);
		} else if (minutes >= 50) {
			minutessingle = minutes - 50;
			//CGContextDrawImage(context, threeRect, cgImageFive);
		} else if (minutes >= 40) {
			minutessingle = minutes - 40;
			//CGContextDrawImage(context, threeRect, cgImageFour);
		} else if (minutes >= 30) {
			minutessingle = minutes - 30;
			//CGContextDrawImage(context, threeRect, cgImageThree);
		} else if (minutes >= 20) {
			minutessingle = minutes - 20;
			//CGContextDrawImage(context, threeRect, cgImageTwo);
		} else if (minutes >= 10) {
			minutessingle = minutes - 10;
			//CGContextDrawImage(context, threeRect, cgImageOne);
		} else {
			minutessingle = minutes;
			//CGContextDrawImage(context, threeRect, cgImageZero);
		}
	}
	NSLog(@"minutessingle: %f", minutessingle);
	if (minutessingle >= 9) {
		minutew = boxw * 0.9;
		minuteh = boxh * 0.9;
		//CGContextDrawImage(context, fourRect, cgImageNine);
	} else if (minutessingle >= 8) {
		minutew = boxw * 0.8;
		minuteh = boxh * 0.8;
		//CGContextDrawImage(context, fourRect, cgImageEight);
	} else if (minutessingle >= 7) {
		minutew = boxw * 0.7;
		minuteh = boxh * 0.7;
		//CGContextDrawImage(context, fourRect, cgImageSeven);
	} else if (minutessingle >= 6) {
		minutew = boxw * 0.6;
		minuteh = boxh * 0.6;
		//CGContextDrawImage(context, fourRect, cgImageSix);
	} else if (minutessingle >= 5) {
		minutew = boxw * 0.5;
		minuteh = boxh * 0.5;
		//CGContextDrawImage(context, fourRect, cgImageFive);
	} else if (minutessingle >= 4) {
		minutew = boxw * 0.4;
		minuteh = boxh * 0.4;
		//CGContextDrawImage(context, fourRect, cgImageFour);
	} else if (minutessingle >= 3) {
		minutew = boxw * 0.3;
		minuteh = boxh * 0.3;
		//CGContextDrawImage(context, fourRect, cgImageThree);
	} else if (minutessingle >= 2) {
		minutew = boxw * 0.2;
		minuteh = boxh * 0.2;
		//CGContextDrawImage(context, fourRect, cgImageTwo);
	} else if (minutessingle >= 1) {
		minutew = boxw * 0.1;
		minuteh = boxh * 0.1;
		//CGContextDrawImage(context, fourRect, cgImageOne);
	} else {
		minutew = boxw * 0.0;
		minuteh = boxh * 0.0;
		//CGContextDrawImage(context, fourRect, cgImageZero);
	}
	
	float secondssingle = seconds;
	if (seconds < 10) {
		secondssingle = seconds;
		//CGContextDrawImage(context, fiveRect, cgImageZero);
	} else {
		if (seconds >= 90) {
			secondssingle = seconds - 90;
			//CGContextDrawImage(context, fiveRect, cgImageNine);
		} else if (seconds >= 80) {
			secondssingle = seconds - 80;
			//CGContextDrawImage(context, fiveRect, cgImageEight);
		} else if (seconds >= 70) {
			secondssingle = seconds - 70;
			//CGContextDrawImage(context, fiveRect, cgImageSeven);
		} else if (seconds >= 60) {
			secondssingle = seconds - 60;
			//CGContextDrawImage(context, fiveRect, cgImageSix);
		} else if (seconds >= 50) {
			secondssingle = seconds - 50;
			//CGContextDrawImage(context, fiveRect, cgImageFive);
		} else if (seconds >= 40) {
			secondssingle = seconds - 40;
			//CGContextDrawImage(context, fiveRect, cgImageFour);
		} else if (seconds >= 30) {
			secondssingle = seconds - 30;
			//CGContextDrawImage(context, fiveRect, cgImageThree);
		} else if (seconds >= 20) {
			secondssingle = seconds - 20;
			//CGContextDrawImage(context, fiveRect, cgImageTwo);
		} else if (seconds >= 10) {
			secondssingle = seconds - 10;
			//CGContextDrawImage(context, fiveRect, cgImageOne);
		} else {
			secondssingle = seconds;
			//CGContextDrawImage(context, fiveRect, cgImageZero);
		}
	}
	NSLog(@"minutessingle: %f", secondssingle);
	if (secondssingle >= 9) {
		secondw = boxw * 0.9;
		secondh = boxh * 0.9;
		//CGContextDrawImage(context, sixRect, cgImageNine);
	} else if (secondssingle >= 8) {
		secondw = boxw * 0.8;
		secondh = boxh * 0.8;
		//CGContextDrawImage(context, sixRect, cgImageEight);
	} else if (secondssingle >= 7) {
		secondw = boxw * 0.7;
		secondh = boxh * 0.7;
		//CGContextDrawImage(context, sixRect, cgImageSeven);
	} else if (secondssingle >= 6) {
		secondw = boxw * 0.6;
		secondh = boxh * 0.6;
		//CGContextDrawImage(context, sixRect, cgImageSix);
	} else if (secondssingle >= 5) {
		secondw = boxw * 0.5;
		secondh = boxh * 0.5;
		//CGContextDrawImage(context, sixRect, cgImageFive);
	} else if (secondssingle >= 4) {
		secondw = boxw * 0.4;
		secondh = boxh * 0.4;
		//CGContextDrawImage(context, sixRect, cgImageFour);
	} else if (secondssingle >= 3) {
		secondw = boxw * 0.3;
		secondh = boxh * 0.3;
		//CGContextDrawImage(context, sixRect, cgImageThree);
	} else if (secondssingle >= 2) {
		secondw = boxw * 0.2;
		secondh = boxh * 0.2;
		//CGContextDrawImage(context, sixRect, cgImageTwo);
	} else if (secondssingle >= 1) {
		secondw = boxw * 0.1;
		secondh = boxh * 0.1;
		//CGContextDrawImage(context, sixRect, cgImageOne);
	} else {
		secondw = boxw * 0.0;
		secondh = boxh * 0.0;
		//CGContextDrawImage(context, sixRect, cgImageZero);
	}
	
	CGContextBeginPage(context, &newRect);
	//CGContextSetRGBFillColor(context, 0.31, 0.43, 0.76, 1);
	
	hourx = boxx+10;
	houry = boxy+10;
	minutex = boxx+10;
	minutey = boxy+10;
	secondx = boxx+10;
	secondy = boxy+10;
	
	CGRect hourRect = CGRectMake(hourx, houry, hourw, hourh);
	CGRect minuteRect = CGRectMake(minutex, minutey, minutew, minuteh);
	CGRect secondRect = CGRectMake(secondx, secondy, secondw, secondh);
	
	CGContextSetRGBStrokeColor(context, 0.31, 0.43, 0.76, 1);
	CGContextAddEllipseInRect(context, hourRect);
	CGContextStrokePath(context);
	
	CGContextSetRGBStrokeColor(context, 0.59, 0.41, 0.69, 1);
	CGContextAddEllipseInRect(context, minuteRect);
	CGContextStrokePath(context);
	
	CGContextSetRGBStrokeColor(context, 0.76, 0.34, 0.28, 1);
	CGContextAddEllipseInRect(context, secondRect);
    CGContextStrokePath(context);
	
	
}

@end