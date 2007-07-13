/*
 *  Prefs.m -- a part of BlindDogClock.app
 * 
 *  by Jeff Szuhay, Blind Dog Software, July, 2006.
 * 
 *  This code is made available for any use whatsoever without
 *  any worranty or liability, explicit or implicit. 
 *  Use at your own risk.
 *
 */

#import "Prefs.h"


@implementation Prefs

-init
{
    self = [super init];
    
    //defaults 		= [[ScreenSaverDefaults defaultsForModuleWithName:@"BlindDogClock"] retain];
    
    _defaults 		= [NSUserDefaults standardUserDefaults];
    
    showBezel       = [self loadBool:_defaults key:@"showBezel"          withDefault:FALSE];
    showMajorHashes = [self loadBool:_defaults key:@"showMajorHashes"    withDefault:TRUE];
    showMinorHashes = [self loadBool:_defaults key:@"showMinorHashes"    withDefault:TRUE];
    showSeconds     = [self loadBool:_defaults key:@"showSeconds"        withDefault:TRUE];

    translucency    = [self loadFloat:_defaults key:@"translucency"      withDefault:0.333f];
    
    showPulse       = [self loadBool:_defaults  key:@"showPulse"         withDefault:TRUE];
    
    lineFraction    = [self loadInt:_defaults   key:@"lineFraction"      withDefault:25];
    lineColor       = [self loadColor:_defaults key:@"lineColor"         withDefault:[NSColor darkGrayColor]];
    backgroundColor = [self loadColor:_defaults key:@"backgroundColor"   withDefault:[NSColor blackColor]];
    
      // we use this guy.
    [backgroundColor retain];
    [lineColor       retain];
    
    
    weatherZip      = [self loadString:_defaults key:@"weatherZip"   withDefault:@"15139"];
    
    return self;
}


- (float) loadFloat:(NSUserDefaults*)defaults key:(NSString*)key withDefault:(float) b  
{
    NSNumber *n = [defaults objectForKey:key];
    
    if (n != NULL)
        b = [n floatValue];
        
    return b;
}


- (BOOL) loadBool:(NSUserDefaults*)defaults key:(NSString*)key withDefault:(BOOL) b  
{
    NSNumber *n = [defaults objectForKey:key];
    
    if (n != NULL)
        b = [n intValue];
        
    return b;
}
- (int) loadInt:(NSUserDefaults*)defaults key:(NSString*)key withDefault:(int) b  {
    
    NSNumber *n = [defaults objectForKey:key];
    
    if (n != NULL)
        b = [n intValue];
    
    return b;
}


- (NSString*) loadString:(NSUserDefaults*)defaults key:(NSString*)key withDefault:(NSString*) b  
{
    NSString *n = [defaults objectForKey:key];
    
    if (n != NULL)
        b = n;
    
    return b;
}

- (NSColor*) loadColor:(NSUserDefaults*)defaults key:(NSString*)key withDefault:(NSColor*) b  
{
    NSData *colorAsData;
    
    colorAsData = [defaults objectForKey:key];
    
    if (colorAsData)
        b = [NSUnarchiver unarchiveObjectWithData:colorAsData];
    
    // make everything rgb
    b = [b colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"];
    
    return b;
}


- (BOOL)showBezel 
{
  return showBezel == 1;
}

- (void) setShowBezel:(BOOL)i 
{
  showBezel = i ? 1 : 0;
  
  [_defaults setObject:[NSNumber numberWithInt:showBezel] forKey:@"showBezel"];
}


- (BOOL)showMajorHashes 
{
  return showMajorHashes == 1;
}

- (void) setShowMajorHashes:(BOOL)i 
{
  showMajorHashes = i ? 1 : 0;
  
  [_defaults setObject:[NSNumber numberWithInt:showMajorHashes] forKey:@"showMajorHashes"];
}


- (BOOL)showMinorHashes 
{
    return showMinorHashes == 1;
}

- (void) setShowMinorHashes:(BOOL)i 
{
    showMinorHashes = i ? 1 : 0;
    
    [_defaults setObject:[NSNumber numberWithInt:showMinorHashes] forKey:@"showMinorHashes"];
}


- (BOOL)showSeconds 
{
    return showSeconds == 1;
}

- (void) setShowSeconds:(BOOL)i 
{
    showSeconds = i ? 1 : 0;
        
    [_defaults setObject:[NSNumber numberWithInt:showSeconds] forKey:@"showSeconds"];
}


- (BOOL)showPulse 
{
    return showPulse == 1;
}

- (void) setShowPulse:(BOOL)i 
{
    showPulse = i ? 1 : 0;
    
    [_defaults setObject:[NSNumber numberWithInt:showPulse] forKey:@"showPulse"];
}


- (float)translucency 
{
    return translucency;
}

- (void)setTranslucency:(float)f 
{
  translucency = f;

  [_defaults setObject:[NSNumber numberWithFloat:translucency] forKey:@"translucency"];
}

- (int)lineFraction
{
  return lineFraction;
}

- (void)setLineFraction:(int)i
{
  lineFraction = i;

  [_defaults setObject:[NSNumber numberWithInt:lineFraction] forKey:@"lineFraction"];
}

- (NSColor*)lineColor
{
  return lineColor;
}

- (void)setLineColor:(NSColor*)c 
{
  NSData *colorAsData;
  lineColor = c;
    
  colorAsData = [NSArchiver archivedDataWithRootObject:lineColor];
    
  [_defaults setObject:colorAsData forKey:@"lineColor"];
}


- (NSColor*)backgroundColor 
{
    return backgroundColor;
}

- (void)setBackgroundColor:(NSColor*)c 
{
    NSData *colorAsData;
    backgroundColor = c;
    
    colorAsData = [NSArchiver archivedDataWithRootObject:backgroundColor];
    
    [_defaults setObject:colorAsData forKey:@"backgroundColor"];
}


- (NSString*)weatherZip 
{
    return weatherZip;
}
- (void)setWeatherZip:(NSString*)s 
{
    weatherZip = s;
    
    [_defaults setObject:weatherZip forKey:@"weatherZip"];
}


@end
