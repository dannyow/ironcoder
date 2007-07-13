//
//  ProcessTimerView.m
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-21.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

#import "ProcessTimerView.h"

#include <stdlib.h>

#define FONT_NAME "HelveticaCYPlain"
#define FONT_SIZE 72.0f

//These are the normal width and height of a timer view. The contents of the timer view will be scaled (proportionally) to the frame size.
//Horizontally: Width of each character + 1pt between each + 1pt on each end.
//Vertically: Height of a character not including inter-character gap (72.0f) + 1pt on each side.
#define NORMAL_TIMERVIEW_WIDTH 528.0
#define NORMAL_TIMERVIEW_HEIGHT 74.0f

//Digits, d, h, and s are each 36pt.
#define TYPICAL_CHARACTER_WIDTH 36.0f
//'m' is 54pt.
#define       m_CHARACTER_WIDTH 54.0f
//'.' is 27pt.
#define  PERIOD_CHARACTER_WIDTH 27.0f
//Every character is 72pt.
#define        CHARACTER_HEIGHT 72.0f
//Gap between characters: 1pt.
#define      CHARACTER_INTERVAL 1.0f
//It was too close to deadline (< 2 hours) for me to resize everything, so I just stuck this in after deleting the .1 from the seconds to re-center it.
#define       HORIZONTAL_OFFSET ((TYPICAL_CHARACTER_WIDTH + PERIOD_CHARACTER_WIDTH) * 0.5f)

//Fudge factors for showing the text on each roll.
#define DIGIT_FUDGEFACTOR_X  2.0f
#define DIGIT_FUDGEFACTOR_Y 10.0f
#define    d_FUDGEFACTOR_X   2.0f
#define    h_FUDGEFACTOR_X   2.0f
#define    m_FUDGEFACTOR_X   4.0f
#define    s_FUDGEFACTOR_X   0.0f
#define TEXT_FUDGEFACTOR_Y  12.0f

#import "ProcessTimerErrors.h"

//The callback that draws the background gradient.
static void shadingFunction(void *refcon, const float *inData, float *outData);

@implementation ProcessTimerView

+ (void)initialize {
	[self exposeBinding:@"foregroundColor"];
	[self exposeBinding:@"backgroundColor"];
	[self exposeBinding:@"day"];
	[self exposeBinding:@"hour"];
	[self exposeBinding:@"minute"];
	[self exposeBinding:@"second"];
}

- initWithFrame:(NSRect)frame {
	if((self = [super initWithFrame:frame])) {
		colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);

		[self setForegroundColor:[NSColor colorWithCalibratedRed:( 32.0f/255.0f)
		                                                   green:(149.0f/255.0f)
		                                                    blue:( 27.0f/255.0f)
		                                                   alpha:1.0f]];
		[self setBackgroundColor:[NSColor colorWithCalibratedWhite:0.14f alpha:1.0f]];
		[self setStringValue:@"00d00h00m00s"];
	}
	return self;
}

- (void)dealloc {
	if(foregroundColor) CFRelease(foregroundColor);
	[appKitBackgroundColor release];
	if(backgroundColor) CFRelease(backgroundColor);
	if(digitsLayer)     CFRelease(digitsLayer);
	if(dLayer)          CFRelease(dLayer);
	if(hLayer)          CFRelease(hLayer);
	if(mLayer)          CFRelease(mLayer);
	if(sLayer)          CFRelease(sLayer);
	if(backgroundLayer) CFRelease(backgroundLayer);

	if(colorSpace) CFRelease(colorSpace);

	[super dealloc];
}

- (void)purgeAllCharacterLayers {
	//Digits.
	if(digitsLayer) {
		CFRelease(digitsLayer);
		digitsLayer = NULL;
	}
	if(digitsMinutesSecondsHighLayer) {
		CFRelease(digitsMinutesSecondsHighLayer);
		digitsMinutesSecondsHighLayer = NULL;
	}
	if(digitsHoursHighLayer) {
		CFRelease(digitsHoursHighLayer);
		digitsHoursHighLayer = NULL;
	}
	if(digitsHoursLowLayer) {
		CFRelease(digitsHoursLowLayer);
		digitsHoursLowLayer = NULL;
	}

	//Letters.
	if(dLayer) {
		CFRelease(dLayer);
		dLayer = NULL;
	}
	if(hLayer) {
		CFRelease(hLayer);
		hLayer = NULL;
	}
	if(mLayer) {
		CFRelease(mLayer);
		mLayer = NULL;
	}
	if(sLayer) {
		CFRelease(sLayer);
		sLayer = NULL;
	}
}
- (void)purgeBackgroundLayer {
	if(backgroundLayer) {
		CFRelease(backgroundLayer);
		backgroundLayer = nil;
	}
}

#pragma mark Accessors

- (NSColor *)foregroundColor {
	return [NSColor colorWithColorSpace:[NSColorSpace genericRGBColorSpace]
	                         components:CGColorGetComponents(foregroundColor)
	                              count:CGColorGetNumberOfComponents(foregroundColor)];
}
- (void)setForegroundColor:(NSColor *)newForegroundColor {
	if(foregroundColor) CFRelease(foregroundColor);

	//“For example, for an RGB color space, CGColorSpaceGetNumberOfComponents returns a value of 3.” —Documentation of that function.
	//We add 1 to account for alpha.
	float *components = alloca(sizeof(float) * (CGColorSpaceGetNumberOfComponents(colorSpace) + 1U));

	if(![[newForegroundColor colorSpaceName] isEqualToString:NSCalibratedRGBColorSpace])
		newForegroundColor = [newForegroundColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[newForegroundColor getComponents:components];
	foregroundColor = CGColorCreate(colorSpace, components);

	[self purgeAllCharacterLayers];
	[self setNeedsDisplay:YES];
}

- (NSColor *)backgroundColor {
	return appKitBackgroundColor;
}
- (void)setBackgroundColor:(NSColor *)newBackgroundColor {
	if(newBackgroundColor != appKitBackgroundColor) {
		if(backgroundColor) CFRelease(backgroundColor);
		[appKitBackgroundColor release];

		//“For example, for an RGB color space, CGColorSpaceGetNumberOfComponents returns a value of 3.” —Documentation of that function.
		//We add 1 to account for alpha.
		float *components = alloca(sizeof(float) * (CGColorSpaceGetNumberOfComponents(colorSpace) + 1U));
		if(![[newBackgroundColor colorSpaceName] isEqualToString:NSCalibratedRGBColorSpace])
			newBackgroundColor = [newBackgroundColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		[newBackgroundColor getComponents:components];

		backgroundColor = CGColorCreate(colorSpace, components);
		appKitBackgroundColor = [[newBackgroundColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace] retain];

		[self purgeBackgroundLayer];
		[self setNeedsDisplay:YES];
	}
}

- (NSString *)stringValue {
	return stringValue;
}
- (BOOL)validateStringValue:(NSString **)ioStringValue error:(out NSError **)outError {
	NSString *newStringValue = *ioStringValue;

	//The string should be of the form "DDdHHhMMmSS.Ss" (uppercase characters are placeholders).
	/*DDdHHhMMmSS.Ss
	 *00000000001111
	 *01234567890123 ←Correct length: 14U
	 */
	if([newStringValue length] != 14U)
		return NO;
	if(!isdigit([newStringValue characterAtIndex:0U]))
		return NO;
	if(!isdigit([newStringValue characterAtIndex:1U]))
		return NO;
	if([newStringValue characterAtIndex:2U] != 'd')
		return NO;
	if(!isdigit([newStringValue characterAtIndex:3U]))
		return NO;
	if(!isdigit([newStringValue characterAtIndex:4U]))
		return NO;
	if([newStringValue characterAtIndex:5U] != 'h')
		return NO;
	if(!isdigit([newStringValue characterAtIndex:6U]))
		return NO;
	if(!isdigit([newStringValue characterAtIndex:7U]))
		return NO;
	if([newStringValue characterAtIndex:8U] != 'm')
		return NO;
	if(!isdigit([newStringValue characterAtIndex:9U]))
		return NO;
	if(!isdigit([newStringValue characterAtIndex:10U]))
		return NO;
	if([newStringValue characterAtIndex:11U] != '.')
		return NO;
	if(!isdigit([newStringValue characterAtIndex:12U]))
		return NO;
	if([newStringValue characterAtIndex:13U] != 's')
		return NO;

	return YES;
}
- (void)setStringValue:(NSString *)newStringValue {
	if(stringValue != newStringValue) {
	    [stringValue release];
	    stringValue = [newStringValue copy];

		//Read in the date components.
		const char *str = [stringValue UTF8String];
		days    = strtoul(str, (char **)&str, 10); ++str;
		hours   = strtoul(str, (char **)&str, 10); ++str;
		minutes = strtoul(str, (char **)&str, 10); ++str;
		fractionOfSecond = strtod(str, NULL);
		if(fractionOfSecond < 1.0f)
			seconds = 0U;
		else {
			//Implicit type-casts are FUN! This week: unsigned↔double!
			seconds = fractionOfSecond;
			fractionOfSecond -= seconds;
		}

		[self setNeedsDisplay:YES];
	}
}
//For testing.
- (IBAction)takeStringValueFrom:sender {
	[self setStringValue:[sender stringValue]];
}

- (unsigned)days {
	return days;
}
- (void)setDays:(unsigned)newDays {
	days = newDays;
	[self setNeedsDisplay:YES];
}

- (unsigned)hours {
	return hours;
}
- (void)setHours:(unsigned)newHours {
	hours = newHours;
	[self setNeedsDisplay:YES];
}

- (unsigned)minutes {
	return minutes;
}
- (void)setMinutes:(unsigned)newMinutes {
	minutes = newMinutes;
	[self setNeedsDisplay:YES];
}

- (unsigned)seconds {
	return seconds;
}
- (void)setSeconds:(unsigned)newSeconds {
	seconds = newSeconds;
	[self setNeedsDisplay:YES];
}

- (NSTimeInterval)fractionOfSecond {
	return fractionOfSecond;
}
- (void)setFractionOfSecond:(NSTimeInterval)newFractionOfSecond {
	fractionOfSecond = newFractionOfSecond;
}

#pragma mark Drawing

- (CGLayerRef)digitsLayerWithMaxDigit:(unsigned)maxDigit {
	CGLayerRef *outLayer;
	switch(maxDigit) {
		case 9U: //The plain digits layer.
			outLayer = &digitsLayer;
			break;
		case 5U: //The digits layer for the high digit of the minute and second.
			outLayer = &digitsMinutesSecondsHighLayer;
			break;
		case 2U: //The digits layer for the high digit of the hour.
			outLayer = &digitsHoursHighLayer;
			break;
		case 3U: //The digits layer for the low digit of the hour.
			outLayer = &digitsHoursLowLayer;
			break;
		default:
			NSAssert1(((maxDigit > 0U) && (maxDigit < 9U)), @"digitsLayerWithMaxDigit: called with maxDigit %u, out of bounds (1 to 9)", maxDigit);
			outLayer = NULL;
	}
	CGLayerRef layer = outLayer ? *outLayer : NULL;

	if (!layer) {
		/*The 9-digit digits layer is an 11-digit vertical ribbon:
	 	 *	0
	 	 *	1
	 	 *	2
	 	 *	3
	 	 *	4
	 	 *	5
	 	 *	6
	 	 *	7
	 	 *	8
	 	 *	9
	 	 *	0 ←This extra 0 exists to make it easy to draw the 9-0 gap.
		 *
		 *All the other digits layers work the same way.
	 	 */

		const size_t charWidth = TYPICAL_CHARACTER_WIDTH, charHeight = CHARACTER_HEIGHT + 1.0f; //Height of a character is 72. We add here the 1pt gap between numbers.
		const size_t w = charWidth, h = charHeight * (maxDigit + 2U) - 1U;
		//The point at which to show the number.
		float x = 0.0f, y = h - CHARACTER_HEIGHT; //No, not charHeight.
		x += DIGIT_FUDGEFACTOR_X; y += DIGIT_FUDGEFACTOR_Y;

		static const size_t bpc = 8; //bits per component
		const size_t bpr = 4 * w; //bytes per row
		CGContextRef context = CGBitmapContextCreate(malloc(bpr * h),
	                                                   	   w, h,
	                                                   	   bpc, bpr,
	                                                   	   colorSpace,
	                                                   	   kCGImageAlphaPremultipliedLast);
		if(context) {
			layer = CGLayerCreateWithContext(context, (struct CGSize){ w, h }, /*auxiliaryInfo*/ NULL);
			if(layer) {
				CGContextRef layerContext = CGLayerGetContext(layer);
				if(!layerContext) {
					//I suppose I should throw an error or something here…
					NSLog(@"digitsLayer (max digit: %u) has no layer context!", maxDigit);
					CFRelease(layer);
					layer = NULL;
				} else {
					CGContextSelectFont(layerContext, FONT_NAME, FONT_SIZE, kCGEncodingMacRoman);

					char ch = '0';
					for(char maxCh = ('0' + maxDigit) + 1; ch < maxCh; ++ch) {
						CGContextSetFillColorWithColor(layerContext, foregroundColor);
						CGContextShowTextAtPoint(layerContext, x, y, &ch, 1U);

						//This region of black is the gap between two numbers on the roll.
						CGContextSetGrayFillColor(layerContext, /*white*/ 0.0f, /*alpha*/ 1.0f);
						//XXX Make sure this is correct once rollover is in place
						CGContextFillRect(layerContext, (struct CGRect){ { 0.0f, y - 16.0f }, { w, 1.0f } });
						y -= charHeight;
					}
					ch = '0';
					CGContextShowTextAtPoint(layerContext, x, y, &ch, 1U);

					if(outLayer) {
						//Don't release layer — we want to keep that around.
						*outLayer = layer;
					} else {
						[(NSObject *)layer autorelease];
					}
				}
			}

			CFRelease(context);
		}
	}

	return layer;
}
- (CGLayerRef)digitsLayer {
	return [self digitsLayerWithMaxDigit:9U];
}
- (CGLayerRef)layerWithCharacter:(char)ch {
	CGLayerRef layer = NULL;
	CGLayerRef *outLayer = NULL; //Where to cache it. No pun intended in the naming of this variable.
	float fudgeFactorX = 0.0f;
	switch(ch) {
		case 'd':
			layer = dLayer;
			outLayer = &dLayer;
			fudgeFactorX = d_FUDGEFACTOR_X;
			break;

		case 'h':
			layer = hLayer;
			outLayer = &hLayer;
			fudgeFactorX = h_FUDGEFACTOR_X;
			break;

		case 'm':
			layer = mLayer;
			outLayer = &mLayer;
			fudgeFactorX = m_FUDGEFACTOR_X;
			break;

		case 's':
			layer = sLayer;
			outLayer = &sLayer;
			fudgeFactorX = s_FUDGEFACTOR_X;
			break;

		default:;
			//Fail.
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
				NSLocalizedString(@"Drawing error", /*comment*/ nil), NSLocalizedDescriptionKey,
				NSLocalizedString(@"The program tried to display a character that it doesn't know how to draw.", /*comment*/ nil), NSLocalizedFailureReasonErrorKey,
				nil];
			NSError *error = [NSError errorWithDomain:PROCESSTIMER_ERROR_DOMAIN code:unrecognizedCharacterError userInfo:userInfo];
			NSWindow *window = [self window];
			[window presentError:error
			      modalForWindow:window
			            delegate:nil
			  didPresentSelector:NULL
			         contextInfo:NULL];
			break;
	}
	if(!layer) {
		size_t w = TYPICAL_CHARACTER_WIDTH;
		if(ch == 'm')
			w = m_CHARACTER_WIDTH;
		static const size_t h = CHARACTER_HEIGHT;
		//The point at which to show the character.
		float x = 0.0f, y = 0.0f;
		x += fudgeFactorX; y += TEXT_FUDGEFACTOR_Y;

		static const size_t bpc = 8; //bits per component
		const size_t bpr = 4 * w; //bytes per row
		CGContextRef context = CGBitmapContextCreate(malloc(bpr * h),
	                                                 w, h,
	                                                 bpc, bpr,
	                                                 colorSpace,
	                                                 kCGImageAlphaPremultipliedLast);
		if(context) {
			layer = CGLayerCreateWithContext(context, (struct CGSize){ w, h }, /*auxiliaryInfo*/ NULL);
			if(layer) {
				CGContextRef layerContext = CGLayerGetContext(layer);
				if(!layerContext) {
					//I suppose I should throw an error or something here…
					NSLog(@"Character (U+04x '%c') layer has no layer context!", ch, ch);
					CFRelease(layer);
					layer = NULL;
				} else {
					CGContextSetFillColorWithColor(layerContext, foregroundColor);
					CGContextSetStrokeColorWithColor(layerContext, foregroundColor);

					CGContextSelectFont(layerContext, FONT_NAME, FONT_SIZE, kCGEncodingMacRoman);
					CGContextShowTextAtPoint(layerContext, x, y, &ch, 1U);

					if(outLayer)
						*outLayer = layer; //Don't autorelease here, because this is an ivar.
					else
						[(NSObject *)layer autorelease];
				}
			}
			//XXX Draw to layer context instead

			CFRelease(context);
		}
	}

	return layer;
}
//The letter m is wider than any other character we draw (it won't fit in the usual 36pt box). So it's done specially, with a 54pt box.
- (CGLayerRef)mLayer {
	return [self layerWithCharacter:'m'];
}
- (CGLayerRef)backgroundLayer {
	if(!backgroundLayer) {
		//This is the static background image that appears behind all of the characters (including intranumeric gaps on the numeric rolls).
		size_t w = 528.0f, h = CHARACTER_HEIGHT;
		size_t bpc = 8; //bits per component
		const size_t bpr = 4 * w; //bytes per row
		CGContextRef context = CGBitmapContextCreate(malloc(bpr * h),
	                                             	 w, h,
	                                             	 bpc, bpr,
	                                             	 colorSpace,
	                                             	 kCGImageAlphaPremultipliedLast);
		if(context) {
			backgroundLayer = CGLayerCreateWithContext(context, (struct CGSize){ w, h }, /*auxiliaryInfo*/ NULL);
			if(backgroundLayer) {
				CGContextRef layerContext = CGLayerGetContext(backgroundLayer);
				if(layerContext) {
					struct CGFunctionCallbacks callbacks = {
						.version = 0U,
						.evaluate = shadingFunction,
						.releaseInfo = NULL
					};
					CGFunctionRef shadingFunction = CGFunctionCreate(/*refcon*/ self,
		                                                 	 	 	 /*domainDimension*/ 1U,
		                                                 	 	 	 /*domain*/ NULL,
		                                                 	 	 	 /*rangeDimension*/ 3U,
		                                                 	 	 	 /*range*/ NULL,
		                                                 	 	 	 &callbacks);
					if(shadingFunction) {
						//First (so it is behind), draw a rod going through all the rolls. This is not essential, so not having it is non-fatal.
						struct CGPoint rodStart = { 0.0f, h * (2.0f / 3.0f) }; //Top.
						struct CGPoint rodEnd   = { 0.0f, h * (1.0f / 3.0f) }; //Bottom.
						CGShadingRef shading = CGShadingCreateAxial(colorSpace, 
			                                            			rodStart, rodEnd,
								                        			shadingFunction,
								                        			/*extendStart*/ false,
								                        			/*extendStart*/ false);
						if(shading) {
							CGContextDrawShading(layerContext, shading);
							CFRelease(shading);
						}
						struct CGPoint start = CGPointZero; //Bottom.
						struct CGPoint end   = { 0.0f, h }; //Top.
						shading = CGShadingCreateAxial(colorSpace, 
			                               	   	   	   start, end,
					                       	   	   	   shadingFunction,
					                       	   	   	   /*extendStart*/ false,
					                       	   	   	   /*extendStart*/ false);
						if(shading) {
							//Clip to the rectangles of each character.
							enum { numRects = 14U };
							static const struct CGSize typicalCharacterSize = { TYPICAL_CHARACTER_WIDTH, CHARACTER_HEIGHT };
							static const struct CGSize       mCharacterSize = {       m_CHARACTER_WIDTH, CHARACTER_HEIGHT };
							struct CGRect rects[numRects] = {
								//Days.
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero, typicalCharacterSize }, //d
								//Hours.
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero, typicalCharacterSize }, //h
								//Minutes.
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero,       mCharacterSize }, //m
								//Seconds.
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero, typicalCharacterSize },
								{ CGPointZero, typicalCharacterSize }, //s
							};
							rects[ 0].origin.x = HORIZONTAL_OFFSET + 1.0f;
							rects[ 1].origin.x = rects[ 0].origin.x + rects[ 0].size.width + CHARACTER_INTERVAL;
							rects[ 2].origin.x = rects[ 1].origin.x + rects[ 1].size.width + CHARACTER_INTERVAL;
							rects[ 3].origin.x = rects[ 2].origin.x + rects[ 2].size.width + CHARACTER_INTERVAL;
							rects[ 4].origin.x = rects[ 3].origin.x + rects[ 3].size.width + CHARACTER_INTERVAL;
							rects[ 5].origin.x = rects[ 4].origin.x + rects[ 4].size.width + CHARACTER_INTERVAL;
							rects[ 6].origin.x = rects[ 5].origin.x + rects[ 5].size.width + CHARACTER_INTERVAL;
							rects[ 7].origin.x = rects[ 6].origin.x + rects[ 6].size.width + CHARACTER_INTERVAL;
							rects[ 8].origin.x = rects[ 7].origin.x + rects[ 7].size.width + CHARACTER_INTERVAL;
							rects[ 9].origin.x = rects[ 8].origin.x + rects[ 8].size.width + CHARACTER_INTERVAL;
							rects[10].origin.x = rects[ 9].origin.x + rects[ 9].size.width + CHARACTER_INTERVAL;
							rects[11].origin.x = rects[10].origin.x + rects[10].size.width + CHARACTER_INTERVAL;
							rects[12].origin.x = rects[11].origin.x + rects[11].size.width + CHARACTER_INTERVAL;
							rects[13].origin.x = rects[12].origin.x + rects[12].size.width + CHARACTER_INTERVAL;
							CGContextClipToRects(layerContext, rects, numRects);

							CGContextDrawShading(layerContext, shading);
							CFRelease(shading);
						}

						CFRelease(shadingFunction);
					}
				}

				//Don't release backgroundLayer — we want to keep that around.
			}

			CFRelease(context);
		}
	}

	return backgroundLayer;
}

- (void)drawToContext:(CGContextRef)context {
	CGContextSaveGState(context);
	CGContextSaveGState(context);
	//1pt up and right (to allow space for the border; see below).
	CGContextTranslateCTM(context, 1.0f, 1.0f);

	//First, draw the background.
	CGContextDrawLayerAtPoint(context, CGPointZero, [self backgroundLayer]);

	//Now draw the characters.

	//This is the point where we'll draw the layer. Note that it will be clipped to the area of the display (in effect, to the area of the roll).
	struct CGPoint   drawingPoint = { HORIZONTAL_OFFSET, 0.0f };

	//Work out how many digits (from the end) are at their maximum value (e.g. 9 for the low seconds digit, or 5 for the high seconds digit).
	//These last N digits, as well as the digit before them, are phased upward on the roll according to the current fraction of a second (thus simulating these digits rolling upward, like an odometer rolling over).
	unsigned numberOfMaximumDigits = 0U;
	//Max seconds: 59
	if((seconds % 10U) == 9) {
		++numberOfMaximumDigits; //1
		if((seconds % 10U) == 5) {
			++numberOfMaximumDigits; //2
			//Max minutes: 59
			if((minutes % 10U) == 9) {
				++numberOfMaximumDigits; //3
				if((minutes % 10U) == 5) {
					++numberOfMaximumDigits; //4
					//Max hours: 23
					if((hours % 10U) == 3) {
						++numberOfMaximumDigits; //5
						if((hours % 10U) == 2) {
							++numberOfMaximumDigits; //6
							//Max days: 99
							if((days % 10U) == 9) {
								++numberOfMaximumDigits; //7
								if((days % 10U) == 9) {
									//I REALLY hope you don't get here.
								}
							}
						}
					}
				}
			}
		}
	}

	//Create the digits layers if needed.
	float digitsLayerHeight                   = CGLayerGetSize([self digitsLayer]).height;
	float digitsMinutesSecondsHighLayerHeight = CGLayerGetSize([self digitsLayerWithMaxDigit:5U]).height;
	float digitsHoursHighLayerHeight          = CGLayerGetSize([self digitsLayerWithMaxDigit:2U]).height;
	float digitsHoursLowLayerHeight           = CGLayerGetSize([self digitsLayerWithMaxDigit:3U]).height;

	float digit = 0.0f;
	//Days.
	digit = days / 10U;
	drawingPoint.y = digitsLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	if(numberOfMaximumDigits >= 7U)
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	digit = days % 10U;
	drawingPoint.y = digitsLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	if(numberOfMaximumDigits >= 6U)
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	drawingPoint.y = 0.0f;
	CGContextDrawLayerAtPoint(context, drawingPoint, [self layerWithCharacter:'d']);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	//Hours.
	digit = hours / 10U;
	drawingPoint.y = digitsHoursHighLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	if(numberOfMaximumDigits >= 5U)
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsHoursHighLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	digit = hours % 10U;
	drawingPoint.y = digitsHoursLowLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	if(numberOfMaximumDigits >= 4U)
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsHoursLowLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	drawingPoint.y = 0.0f;
	CGContextDrawLayerAtPoint(context, drawingPoint, [self layerWithCharacter:'h']);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	//Minutes.
	digit = minutes / 10U;
	drawingPoint.y = digitsMinutesSecondsHighLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	if(numberOfMaximumDigits >= 3U)
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsMinutesSecondsHighLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	digit = minutes % 10U;
	drawingPoint.y = digitsLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	if(numberOfMaximumDigits >= 2U)
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	drawingPoint.y = 0.0f;
	CGContextDrawLayerAtPoint(context, drawingPoint, [self layerWithCharacter:'m']);
	drawingPoint.x += m_CHARACTER_WIDTH + 1.0f;
	//Seconds.
	digit = seconds / 10U;
	drawingPoint.y = digitsMinutesSecondsHighLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	if(numberOfMaximumDigits >= 1U)
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsMinutesSecondsHighLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	digit = seconds % 10U;
	drawingPoint.y = digitsLayerHeight - (CHARACTER_HEIGHT + 1.0f) * (digit + 1.0f);
	//numberOfMaximumDigits always > 0U.
		drawingPoint.y -= CHARACTER_HEIGHT * fractionOfSecond;
	drawingPoint.y = -drawingPoint.y;
	CGContextDrawLayerAtPoint(context, drawingPoint, digitsLayer);
	drawingPoint.x += TYPICAL_CHARACTER_WIDTH + 1.0f;
	drawingPoint.y = 0.0f;
	CGContextDrawLayerAtPoint(context, drawingPoint, [self layerWithCharacter:'s']);
	//No need to move right again — we're at the end of the line.

	CGContextRestoreGState(context);

	CGSize size = CGLayerGetSize(backgroundLayer);

	//Draw a border.
	//Top (shadow): 40% white.
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, size.height);
	CGContextAddLineToPoint(context, size.width, size.height);
	CGContextSetGrayStrokeColor(context, 0.4f, 1.0f);
	CGContextStrokePath(context);
	//Bottom (highlight): 60% white.
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextAddLineToPoint(context, size.width, 0.0f);
	CGContextSetGrayStrokeColor(context, 0.6f, 1.0f);
	CGContextStrokePath(context);
	//Sides: 50% white.
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, 0.0f);
	CGContextAddLineToPoint(context, 0.0f, size.height);
	CGContextMoveToPoint(context, size.width, 0.0f);
	CGContextAddLineToPoint(context, size.width, size.height);
	CGContextSetGrayStrokeColor(context, 0.5f, 1.0f);
	CGContextStrokePath(context);

	CGContextRestoreGState(context);
}

- (NSData *)dataWithPDFInsideRect:(NSRect)rect {
	NSData *data = [NSMutableData data];

	CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((CFMutableDataRef)data);
	if(consumer) {
		NSRect bounds = [self bounds];
		float scaleX = bounds.size.width  / NORMAL_TIMERVIEW_WIDTH;
		float scaleY = bounds.size.height / NORMAL_TIMERVIEW_HEIGHT;
		float scale  = scaleX < scaleY ? scaleX : scaleY;

		union {
			NSRect appKit;
			struct CGRect quartz;
		} magicRectConverter = { .appKit = rect };
		magicRectConverter.appKit.origin.x    /= scale;
		magicRectConverter.appKit.origin.y    /= scale;
		magicRectConverter.appKit.size.width  /= scale;
		magicRectConverter.appKit.size.height /= scale;
		struct CGRect mediaBox = { CGPointZero, { NORMAL_TIMERVIEW_WIDTH, NORMAL_TIMERVIEW_HEIGHT } };
		NSDictionary *auxInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSData dataWithBytes:&(magicRectConverter.quartz) length:sizeof(magicRectConverter.quartz)], kCGPDFContextCropBox, //No, not NSValue.
			nil];

		CGContextRef context = CGPDFContextCreate(consumer, &mediaBox, (CFDictionaryRef)auxInfo);
		if(context) {
			[self drawToContext:context];
			CFRelease(context);
		}

		CFRelease(consumer);
	}

	if([data length] == 0U)
		data = nil;
	else
		data = [NSData dataWithData:data];
	return data;
}
- (void)drawRect:(NSRect)rect {
	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];

	union {
		NSRect appKit;
		struct CGRect quartz;
	} magicRectConverter = { .appKit = rect };
	CGContextClipToRect(context, magicRectConverter.quartz);

	NSRect bounds = [self bounds];
	float scaleX = bounds.size.width  / NORMAL_TIMERVIEW_WIDTH;
	float scaleY = bounds.size.height / NORMAL_TIMERVIEW_HEIGHT;
	float scale  = scaleX < scaleY ? scaleX : scaleY;
	CGContextScaleCTM(context, scale, scale);

	[self drawToContext:context];
}

@end

#include <math.h>

static void shadingFunction(void *refcon, const float *inData, float *outData) {
	ProcessTimerView *self = (ProcessTimerView *)refcon;
	NSColor *color = [[self backgroundColor] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	float hue, saturation, brightness, alpha;
	[color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	//This will be applied to the computed brightness to get it to match up with the color the user selected.
	float delta = brightness - 0.15f;
	if(delta >= 0.6f) //Don't let it go TOO high.
		delta = 0.6f;

	float position = *(float *)inData;
	if(position < 0.6f) {
		brightness = log1p(position);
	} else {
		brightness = pow(position, position - 1.0f) - 0.9f;
	}
	brightness += delta;

	color = [[NSColor colorWithCalibratedHue:hue saturation:saturation brightness:brightness alpha:alpha] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	[color getComponents:outData];
}
