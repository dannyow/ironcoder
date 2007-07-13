/*
 *  BDCView.m -- a part of BlindDogClock.app
 * 
 *  by Jeff Szuhay, Blind Dog Software, July, 2006.
 * 
 *  This code is made available for any use whatsoever without
 *  any worranty or liability, explicit or implicit. 
 *  Use at your own risk.
 *
 */

#import <ApplicationServices/ApplicationServices.h>

#import "BDCView.h"

@implementation BDCView

- (void)awakeFromNib
{
  NSRect rect;
  
  bdcInterval = DEFAULT_TIME_INTERVAL;
  bdcTimer    = [[NSTimer scheduledTimerWithTimeInterval: bdcInterval 
                                                  target: self
                                                selector: @selector(updateBDC)
                                                userInfo: NULL 
                                                 repeats: YES]
                 retain];
  
  NSRect screenFrame = [[NSScreen mainScreen]frame];
  
  side = screenFrame.size.height - 50;
  int centerX = screenFrame.size.width/2;
  int centerY = screenFrame.size.height/2;
  
  [[self window] setFrame: NSMakeRect( screenFrame.origin.x + centerX - (side/2), 
                                       screenFrame.origin.y + centerY - (side/2), 
                                       side, 
                                       side )
                  display: NO];
  
  rect = [self frame];
  
  bdcTime = [[BDCTime alloc]initWithRect: (CGRect*)&rect];
}


- (void)drawRect:(NSRect)rect 
{
  NSGraphicsContext * nsgc = [NSGraphicsContext currentContext];
  CGContextRef          gc = [nsgc graphicsPort];
  
  // comment out these two lines for a transparent background.    
#if 0
  [[NSColor blackColor] set];
  NSRectFill( NSMakeRect( 0,
                          0,
                          side,
                          side ) );
  [[NSColor orangeColor] set];
  NSFrameRectWithWidth( NSMakeRect( 0,
                                    0,
                                    side,
                                    side ),
                        6.0);
#endif  
  
  [bdcTime drawInContext:gc withRect: (CGRect*)&rect];
}


- (void) updateBDC
{
  [self setNeedsDisplayInRect: NSMakeRect( 0,
                                           0,
                                           side, 
                                           side ) ];
}

@end
