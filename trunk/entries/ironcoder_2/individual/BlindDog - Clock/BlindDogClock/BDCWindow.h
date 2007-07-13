/*
 *  BDCWindow.h -- a part of BlindDogClock.app
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

@interface BDCWindow : NSWindow
{
    // This point is used in dragging to mark 
    // the initial click location
  NSPoint initialLocation;
}

@end
