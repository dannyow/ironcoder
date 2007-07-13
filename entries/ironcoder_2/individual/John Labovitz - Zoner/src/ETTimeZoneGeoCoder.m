//
//  ETTimeZoneGeoCoder.m
//  Zoner
//
//  Created by John Labovitz on 7/22/06.
//  Copyright 2006 Eureka Toolworks. All rights reserved.
//

#import "ETTimeZoneGeoCoder.h"


@implementation ETTimeZoneGeoCoder

// from zone.tab:
//# 1.  ISO 3166 2-character country code.  See the file `iso3166.tab'.
//# 2.  Latitude and longitude of the zone's principal location
//#     in ISO 6709 sign-degrees-minutes-seconds format,
//#     either +-DDMM+-DDDMM or +-DDMMSS+-DDDMMSS,
//#     first latitude (+ is north), then longitude (+ is east).
//# 3.  Zone name used in value of TZ environment variable.
//# 4.  Comments; present if and only if the country has multiple rows.

- (id)init {
	
	if ((self = [super init]) == nil) return nil;
	
	_locations = [[NSMutableDictionary dictionary] retain];
	
	NSString *tab = [NSString stringWithContentsOfFile:@"/usr/share/zoneinfo/zone.tab"];
	NSArray *lines = [tab componentsSeparatedByString:@"\n"];
	NSEnumerator *linesEnumerator = [lines objectEnumerator];
	NSString *line;
	
	while ((line = [linesEnumerator nextObject]) != nil) {
		
		//
		// Skip comments and blank lines.
		
		if ([line hasPrefix:@"#"] || [line length] == 0) {
			continue;
		}
		
		NSArray *fields = [line componentsSeparatedByString:@"\t"];
		
		NSString *timeZoneName = [fields objectAtIndex:2];
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:timeZoneName];
		
		if (!timeZone) {
			;;NSLog(@"Couldn't find NSTimeZone for %@", timeZoneName);
			continue;
		}
		
		NSString *locationString = [fields objectAtIndex:1];
		NSPoint location;
		
		if (![self parseLocation:&location
					  fromString:locationString]) {
			;;NSLog(@"Couldn't parse location string: %@", locationString);
			continue;
		}
		
		[_locations setObject:[NSValue valueWithPoint:location]
					   forKey:timeZone];
	}
	
	return self;
}


- (void)dealloc {
	
	[_locations release];
	
	[super dealloc];
}


//# 2.  Latitude and longitude of the zone's principal location
//#     in ISO 6709 sign-degrees-minutes-seconds format,
//#     either +-DDMM+-DDDMM or +-DDMMSS+-DDDMMSS,
//#     first latitude (+ is north), then longitude (+ is east).

- (BOOL)parseLocation:(NSPoint *)location
		   fromString:(NSString *)string {
	
	NSCharacterSet *signSet = [NSCharacterSet characterSetWithCharactersInString:@"+-"];
	
	NSScanner *scanner = [NSScanner scannerWithString:string];
	
	//;;NSLog(@"scanning: %@", string);
	
	int i;
	
	for (i = 0; i < 2; i++) {
		
		NSString *signString;
		int sign = 1;
		if (![scanner scanCharactersFromSet:signSet
								 intoString:&signString]) {
			return NO;
		}
		if ([signString isEqual:@"-"]) {
			sign = -1;
		}
		//;;NSLog(@"  [%d] scanned sign: %@ => %d", i, signString, sign);

		NSString *degreesString;
		if (![scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet]
								 intoString:&degreesString]) {
			return NO;
		}

		NSString *ds = nil;
		NSString *ms = nil;
		NSString *ss = nil;
		
		switch ([degreesString length]) {
			case 4:
				ds = [degreesString substringWithRange:NSMakeRange(0, 2)];
				ms = [degreesString substringWithRange:NSMakeRange(2, 2)];
				break;
			case 5:
				ds = [degreesString substringWithRange:NSMakeRange(0, 3)];
				ms = [degreesString substringWithRange:NSMakeRange(3, 2)];
				break;
			case 6:
				ds = [degreesString substringWithRange:NSMakeRange(0, 2)];
				ms = [degreesString substringWithRange:NSMakeRange(2, 2)];
				ss = [degreesString substringWithRange:NSMakeRange(4, 2)];
				break;
			case 7:
				ds = [degreesString substringWithRange:NSMakeRange(0, 3)];
				ms = [degreesString substringWithRange:NSMakeRange(3, 2)];
				ss = [degreesString substringWithRange:NSMakeRange(5, 2)];
				break;
			default:
				break;
		}
		
		float degrees = ([ds floatValue] + ([ms floatValue] / 60.0) + ([ss floatValue] / 3600.0)) * sign;
		
		//;;NSLog(@"  [%d] scanned degrees: (%@, %@, %@) => %f", i, ds, ms, ss, degrees);
		
		if (i == 0) location->y = degrees;
		else        location->x = degrees;
	}
	
	//;;NSLog(@"%@ => %@", string, NSStringFromPoint(*location));
	
	return YES;
}


- (BOOL)getPrincipalLocationForTimeZone:(NSTimeZone *)timezone
								  point:(NSPoint *)point {
	
	//NSValue *pointValue = [_locations objectForKey:[timezone name]];
	
	NSEnumerator *zoneEnumerator = [_locations keyEnumerator];
	NSTimeZone *timeZoneInTable;
	
	while ((timeZoneInTable = [zoneEnumerator nextObject]) != nil) {
		
		//;;NSLog(@"comparing %@ to %@", [timeZoneInTable name], [timezone name]);
		
		if ([timeZoneInTable isEqualToTimeZone:timezone]) {
			
			NSValue *pointValue = [_locations objectForKey:timeZoneInTable];
			
			if (!pointValue) {
				return NO;
			}
			
			*point = [pointValue pointValue];
			return YES;
		}
	}
	
	return NO;
}


- (NSDictionary *)locations {
	
	return [[_locations retain] autorelease];
}

@end