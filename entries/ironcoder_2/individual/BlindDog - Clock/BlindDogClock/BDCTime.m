/*
 *  BDCTime.m -- a part of BlindDogClock.app
 * 
 *  by Jeff Szuhay, Blind Dog Software, July, 2006.
 * 
 *  This code is made available for any use whatsoever without
 *  any worranty or liability, explicit or implicit. 
 *  Use at your own risk.
 *
 */

#import "BDCTime.h"
#import "trig_utils.h"


// ccgus (praise him from whom all wisdom flow):
//   yes, yes, I know I'm not dealloc'ing anything anywhere... 
//   it's supposed to be sloppy!

@implementation BDCTime

- initWithRect:(CGRect*) rect 
{
  self = [super init];
    
  if (self)
  {
    prefs = [[Prefs alloc] init];
     
    
    lineWidth = rect->size.width / [prefs lineFraction];
    
    hourHand   = [[HourHand alloc]   initWithRect: rect 
                                            prefs: prefs
                                            width: lineWidth*1.5 
                                           length: rect->size.width*0.25 ];
    minuteHand = [[MinuteHand alloc] initWithRect: rect 
                                            prefs: prefs
                                            width: lineWidth*0.5
                                           length: rect->size.width*0.5 - lineWidth ];
    secondHand = [[SecondHand alloc] initWithRect: rect 
                                            prefs: prefs
                                            width: lineWidth*0.0625 
                                           length: rect->size.width*0.5 ];
    
    // non-transparent background      
// we don't need no stinkin' background
//
//    [[prefs backgroundColor] getRed:&backgroundR green:&backgroundG blue:&backgroundB alpha:&backgroundA];
        
      [[prefs lineColor] getRed:&lineR green:&lineG blue:&lineB alpha:&lineA];
        
  }
  else
  {
    NSLog(@"uh oh! -- could not make self ...");
  }
     
  return self;
}

- (void) drawMajorHashes:(CGContextRef)context withRect:(CGRect*) rect 
{
  float x1,x2;    
  float y1,y2;
  float angle   = 0.0;
  float radians = 0.0;
  
  int radius    = rect->size.width / 2;
  int center    = radius;
  int length    = 0;
  if( [prefs showBezel] ) 
    length    = 2*lineWidth;
  else
    length    = 1.5*lineWidth;

  
  if ([prefs showMajorHashes])
  {
    int i = 0;
    for ( i=0 ; i < 4 ; i++ )
    {
      angle   = i*90.0;
      radians = degreesToRadians( angle );
      x1 = center + (radius-length) * cos( radians );
      y1 = center + (radius-length) * sin( radians );
      
      x2 = center + radius * cos( radians );
      y2 = center + radius * sin( radians );
      
        // draw line from (x1,y1) to (x2,y2)
      CGContextMoveToPoint(    context , x1 , y1 );
      CGContextAddLineToPoint( context , x2 , y2 );
      CGContextStrokePath(     context );
    }
  }
}

- (void) drawMinorHashes:(CGContextRef)context withRect:(CGRect*) rect 
{
  float x1,x2;    
  float y1,y2;
  float angle   = 0.0;
  float radians = 0.0;
  
  int radius    = rect->size.width / 2;
  int center    = radius;
  int length    = 0;
  if( [prefs showBezel] ) 
    length    = 1.5*lineWidth;
  else
    length    = lineWidth;


  if ([prefs showMinorHashes])
  {
    int i = 0;
    for (i=0 ; i < 12 ; i++ )
    {
      if( i%3 == 0 ) continue; // skip major hashes
      
      angle = i*30.0;
      radians = degreesToRadians( angle );
      x1 = center + (radius-length) * cos( radians );
      y1 = center + (radius-length) * sin( radians );
      
      x2 = center + radius * cos( radians );
      y2 = center + radius * sin( radians );
      
        // draw line from (x1,y1) to (x2,y2)
      CGContextMoveToPoint(    context , x1 , y1 );
      CGContextAddLineToPoint( context , x2 , y2 );
      CGContextStrokePath(     context );
    }
  }
}


- (void) drawBlindDogClockFace: (CGContextRef)context 
                      withRect: (CGRect*)contextRect 
{
  CGContextSetLineWidth( context , lineWidth );
//  CGContextSetRGBStrokeColor( context , lineR , lineG , lineB , lineA );
  CGContextSetRGBStrokeColor( context , lineR , lineG , lineB ,  [prefs translucency] );

  if( [prefs showBezel] )
  {
    float center = contextRect->size.width / 2.0;
    float radius = center - (lineWidth/2.0);
    
    CGContextBeginPath(  context );
    CGContextAddArc(     context , center , center , radius , 0, 2*M_PI, 0);
    CGContextClosePath(  context );
    CGContextStrokePath( context );
  }

  [self drawMajorHashes:context withRect:contextRect];
  [self drawMinorHashes:context withRect:contextRect];

}


- (void) drawBlindDogClockHotSpot: (CGContextRef)context 
                         withRect: (CGRect*)contextRect 
{
  CGContextSetRGBStrokeColor( context , lineR , lineG , lineB , lineA );
  
  float center = contextRect->size.width / 2.0;
  float radius = lineWidth/2.0;
    
  CGContextBeginPath(  context );
  CGContextAddArc(     context , center , center , radius , 0, 2*M_PI, 0);
  CGContextClosePath(  context );
  CGContextStrokePath( context );
}


- (void) clear: (CGContextRef) context  withRect:(CGRect*) contextRect 
{
    // make a black background.
  CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
  
    // make a non-black background
  //CGContextSetRGBFillColor(context, backgroundR, backgroundG, backgroundB, 1.0);  
  CGContextFillRect(context,*contextRect);
}


- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) rect
{
  
  NSCalendarDate *d;
  
  d = [NSCalendarDate calendarDate];
  
  [self drawBlindDogClockFace:context withRect:rect];
  
  [hourHand   paint:context frame:rect time:d];
  [minuteHand paint:context frame:rect time:d];

  if( [prefs showSeconds] )
  {
    [secondHand paint:context frame:rect time:d];
  }
  
  [self drawBlindDogClockHotSpot:context withRect:rect];
}


@end
