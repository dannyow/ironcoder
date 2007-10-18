//
//  FESHair.h
//  Fuzzy Freddy
//
//  Created by Lucas Eckels on 7/22/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FESHair : NSObject {
   NSPoint origin;
   NSPoint dst;
   
   float age;
   float growth;
   float lifetime;
   
   CGColorRef color;
   
}

-(id)initWithOrigin:(NSPoint)aOrigin destination:(NSPoint)aDestination growth:(float)aGrowth lifetime:(float)aLifetime
              color:(CGColorRef)color;

-(void)draw:(CGContextRef)context;

-(void)age:(float)length;

-(void)shave:(NSRect)rect;

-(void)applyTonicToRegion:(NSPoint)point radius:(float)radius strength:(float)strength;

@end
