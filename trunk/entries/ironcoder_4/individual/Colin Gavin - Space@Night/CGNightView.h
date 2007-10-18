//
//  CGImageGenerator.h
//  gavincolin@gmail.com
//
//  Created by Colin Gavin on 10/28/06.

#import <Cocoa/Cocoa.h>
#import "CGImageGenerator.h"
#import <QuartzCore/QuartzCore.h>
typedef struct{
	float radius;
	NSColor *color;
	BOOL on;
	NSPoint center;
}CGStar;
@interface CGNightView : NSView
{
	NSMutableArray *stars;
	CIImage *tintedMoon;
	CIImage *bluredMoon;
	CIImage *metor;
	BOOL blurMoon;
	BOOL colorizeMoon;
	float blurAmount;
}
-(void)setStars:(NSArray *)anArray;
-(void)drawMoonWithGlow:(BOOL)glow tint:(NSColor *)tint glowAmount:(float)a;
@end
