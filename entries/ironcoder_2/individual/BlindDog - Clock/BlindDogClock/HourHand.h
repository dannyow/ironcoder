/*
 *  HourHand.h -- a part of BlindDogClock.app
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

@interface HourHand : NSObject 
{
  Prefs * prefs;
  
  float x1, x2, y1, y2, w, h;
    
  float widthHand;
  float lengthHand;
}

- initWithRect: (CGRect*)rect 
         prefs: (Prefs*)p
         width: (float)wHand 
        length: (float)lHand;

- (void)paint: (CGContextRef)context 
        frame: (CGRect*)contextRect 
         time: (NSCalendarDate *)d;

@end
