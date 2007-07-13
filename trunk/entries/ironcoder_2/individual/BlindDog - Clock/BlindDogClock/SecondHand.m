/*
 *  Secondhand.m -- a part of BlindDogClock.app
 * 
 *  by Jeff Szuhay, Blind Dog Software, July, 2006.
 * 
 *  This code is made available for any use whatsoever without
 *  any worranty or liability, explicit or implicit. 
 *  Use at your own risk.
 *
 */

#import "SecondHand.h"
#import "trig_utils.h"


@implementation SecondHand

- initWithRect: (CGRect*)rect 
         prefs: (Prefs*)p
         width: (float)wHand 
        length: (float)lHand;
{
  self = [super init];
        
  prefs = p;
  widthHand  = wHand;
  lengthHand = lHand;
  
  w = rect->size.width;
  h = rect->size.height;
    
  x1 = w/2.0;
  y1 = h/2.0;
  x2 = x1;
  y2 = h;
  
  return self;
}

- (void)paint: (CGContextRef)context 
        frame: (CGRect*)contextRect  
         time: (NSCalendarDate *)d 
{
//  int  tm_hour;
//  int  tm_min;
  int  tm_sec;
//  int  dayOfYear, dayOfWeek;

  float angle;
  float radians;
  
  CGContextSaveGState(context);

  CGContextSetRGBFillColor  (context, 1, 1, 0, 1);
  CGContextSetRGBStrokeColor(context, 1, 1, 0, 1);
      
  CGContextSetLineWidth(context, widthHand);
  CGContextSetRGBStrokeColor( context , 1.0 , 0.1 , 0.1 , [prefs translucency] );

  //tm_hour   = [d hourOfDay];
//  tm_min    = [d minuteOfHour];
  tm_sec    = [d secondOfMinute];
  //dayOfWeek = [d dayOfWeek];
  //dayOfYear = [d dayOfYear];	
  
    // 1) calculate angle of "base hour"
    // 2) add 15 min increments to hour movement
    // 3) draw it.

  angle = 90.0 - (tm_sec * 6.0);                  /* 1 */
  
  radians = degreesToRadians( angle );            /* 2 */
  
  x2 = x1 + lengthHand * cos( radians );
  y2 = y1 + lengthHand * sin( radians );
  
  CGContextMoveToPoint(    context , x1 , y1 );   /* 3 */
  CGContextAddLineToPoint( context , x2 , y2 );
  CGContextStrokePath(     context );
  
  
  CGContextRestoreGState(context);
}

- (void)move 
{

}


@end
