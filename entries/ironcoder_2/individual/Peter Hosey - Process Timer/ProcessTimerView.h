//
//  ProcessTimerView.h
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-21.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

@interface ProcessTimerView : NSView {
	NSColor *appKitBackgroundColor; //Just a cache.
	CGColorRef foregroundColor, backgroundColor;
	//Digits layers: 0…9, 0…5 (as in 59, the highest possible min or sec), 0…2, 0…3 (23 being the highest possible hour).
	//Each of these has an extra 0 at the end to allow a wraparound effect.
	CGLayerRef digitsLayer, digitsMinutesSecondsHighLayer, digitsHoursHighLayer, digitsHoursLowLayer;
	CGLayerRef dLayer, hLayer, mLayer, sLayer;
	CGLayerRef backgroundLayer;
	CGColorSpaceRef colorSpace;

	NSString *stringValue;
	unsigned days, hours, minutes, seconds;
	NSTimeInterval fractionOfSecond;
}

#pragma mark Accessors

- (NSColor *)foregroundColor;
- (void)setForegroundColor:(NSColor *)newForegroundColor;

- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)newBackgroundColor;

//This should be a string of the form "DDdHHhMMmSS.Ss" (uppercase characters are placeholders).
- (NSString *)stringValue;
- (void)setStringValue:(NSString *)newStringValue;
//For testing.
- (IBAction)takeStringValueFrom:sender;

- (unsigned) days;
- (void) setDays:(unsigned)newDays;

- (unsigned) hours;
- (void) setHours:(unsigned)newHours;

- (unsigned) minutes;
- (void) setMinutes:(unsigned)newMinutes;

- (unsigned) seconds;
- (void) setSeconds:(unsigned)newSeconds;

- (NSTimeInterval) fractionOfSecond;
- (void) setFractionOfSecond:(NSTimeInterval)newFractionOfSecond;

#pragma mark Drawing

- (void)drawToContext:(CGContextRef)context;

@end
