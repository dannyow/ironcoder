/*
 *  BDCView.h -- a part of BlindDogClock.app
 * 
 *  by Jeff Szuhay, Blind Dog Software, July, 2006.
 * 
 *  This code is made available for any use whatsoever without
 *  any worranty or liability, explicit or implicit. 
 *  Use at your own risk.
 *
 */

#import <Cocoa/Cocoa.h>
#import "BDCTime.h"
#import "Prefs.h"

#define DEFAULT_TIME_INTERVAL 	 1.0
#define FRAME_TIME_INTERVAL 	   0.3
#define FRAMERATE_TIME_INTERVAL  0.2
#define NO_SECONDS_TIME_INTERVAL 1.0;

#define WINDOWED

@interface BDCView : NSView
{
  NSTimer				 * bdcTimer;
  NSTimeInterval   bdcInterval;
  
  BDCTime        * bdcTime;

  Prefs          * prefs;
  
  int              side; // we're gonna make square
}
@end
