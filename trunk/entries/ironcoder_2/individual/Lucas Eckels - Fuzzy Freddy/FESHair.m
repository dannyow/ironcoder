//
//  FESHair.m
//  Fuzzy Freddy
//
//  Created by Lucas Eckels on 7/22/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "FESHair.h"
#import "FESFuzzyConstants.h"

@implementation FESHair

-(id)initWithOrigin:(NSPoint)aOrigin destination:(NSPoint)aDestination growth:(float)aGrowth lifetime:(float)aLifetime color:(CGColorRef)aColor;
{
   if (self = [self init])
   {
      dst = aDestination;
      origin = aOrigin;
      age = 0;
      growth = aGrowth;
      color = CGColorRetain(aColor);
   }
   
   return self;
}

-(void)dealloc;
{
   CGColorRelease(color);
   [super dealloc];
}

-(void)draw:(CGContextRef)context;
{
   CGContextBeginPath(context);
   CGContextSetStrokeColorWithColor(context,color);
   CGContextMoveToPoint(context,origin.x,origin.y);
   CGContextSetLineCap(context,kCGLineCapRound);
   if (age < STUBBLE_LIMIT)
   {  
      CGContextSetLineWidth(context,age);
      CGContextAddLineToPoint(context, origin.x, origin.y);
      CGContextStrokePath(context);
   }
   else
   {
      CGContextSetLineWidth(context, STUBBLE_LIMIT);
      
      float length = age - STUBBLE_LIMIT;
      CGPoint p1 = CGPointMake(origin.x + dst.x * length, origin.y + dst.y * length);
      CGPoint p2 = CGPointMake(origin.x + dst.x * length, origin.y + dst.y * length - length);
      CGContextAddQuadCurveToPoint(context,p1.x,p1.y,p2.x,p2.y);
      CGContextStrokePath(context);
   }


}

-(void)age:(float)length;
{
   age += length * growth;
   if (age < 0)
   {
      age = 0;
      growth = 0;
   }
   
   if (USE_DEATH)
   {
      if ((rand() % 100 * lifetime) < DEATH_PROBABILITY)
      {
         age = 0;
      }
   }
}

-(void)shave:(NSRect)rect;
{
   if (NSPointInRect(origin, rect))
   {
      age = 0;
   }
}

-(void)applyTonicToRegion:(NSPoint)point radius:(float)radius strength:(float)strength;
{
  
   if (hypot(point.x - origin.x, point.y - origin.y) < radius)
   {
      growth += strength;
   }
}

@end
