/*
 *  Prefs.h -- a part of BlindDogClock.app
 * 
 *  by Jeff Szuhay, Blind Dog Software, July, 2006.
 * 
 *  This code is made available for any use whatsoever without
 *  any worranty or liability, explicit or implicit. 
 *  Use at your own risk.
 *
 */

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaverDefaults.h>

@interface Prefs : NSObject
{
  NSUserDefaults * _defaults;

  int showBezel;
  int showMajorHashes;
  int showMinorHashes;
  int showSeconds;
  int showPulse;

  float translucency;

  int lineFraction;     // line width will be rect.width / lineFraction
                        // this should be between 20..100 (smaller=thick lines)
  NSColor * lineColor;
  NSColor * backgroundColor;

  NSString * weatherZip;
}

- (BOOL)showBezel;
- (void)setShowBezel:(BOOL)i;

- (BOOL)showMajorHashes;
- (void)setShowMajorHashes:(BOOL)i;

- (BOOL)showMinorHashes;
- (void)setShowMinorHashes:(BOOL)i;

- (BOOL)showSeconds;
- (void)setShowSeconds:(BOOL)i;

- (BOOL)showPulse;
- (void)setShowPulse:(BOOL)i;

- (float)translucency;
- (void)setTranslucency:(float)f;

- (int)lineFraction;
- (void)setLineFraction:(int)i;

- (NSColor*)lineColor;
- (void)setLineColor:(NSColor*)c;

- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)c;

- (NSString*)weatherZip;
- (void)setWeatherZip:(NSString*)s;

- (BOOL)      loadBool:  (NSUserDefaults*)defaults key:(NSString*)key withDefault:(BOOL) b ;
- (int)       loadInt:   (NSUserDefaults*)defaults key:(NSString*)key withDefault:(int) b;
- (float)     loadFloat: (NSUserDefaults*)defaults key:(NSString*)key withDefault:(float) b;
- (NSColor*)  loadColor: (NSUserDefaults*)defaults key:(NSString*)key withDefault:(NSColor*) b;
- (NSString*) loadString:(NSUserDefaults*)defaults key:(NSString*)key withDefault:(NSString*) b ;

@end
