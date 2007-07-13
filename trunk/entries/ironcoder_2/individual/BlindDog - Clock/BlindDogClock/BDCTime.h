/*
 *  BDCTime.h -- a part of BlindDogClock.app
 * 
 *  by Jeff Szuhay, Blind Dog Software, July, 2006.
 * 
 *  This code is made available for any use whatsoever without
 *  any worranty or liability, explicit or implicit. 
 *  Use at your own risk.
 *
 */

#import <Cocoa/Cocoa.h>

#import "Prefs.h"
#import "HourHand.h"
#import "MinuteHand.h"
#import "SecondHand.h"

@interface BDCTime : NSObject
{

  HourHand   * hourHand;     // white
  MinuteHand * minuteHand;   // black
  SecondHand * secondHand;   // red
  
  Prefs * prefs;
  
  float lineR, lineG, lineB, lineA;
  int   lineWidth;
}

- initWithRect:(CGRect*) rect;

- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) rect;

@end
