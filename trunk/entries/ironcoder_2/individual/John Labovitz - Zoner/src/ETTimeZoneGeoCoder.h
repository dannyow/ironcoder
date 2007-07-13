//
//  ETTimeZoneGeoCoder.h
//  Zoner
//
//  Created by John Labovitz on 7/22/06.
//  Copyright 2006 Eureka Toolworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ETTimeZoneGeoCoder : NSObject {
	
	NSMutableDictionary *_locations;
}

- (BOOL)getPrincipalLocationForTimeZone:(NSTimeZone *)timezone
								  point:(NSPoint *)point;

- (BOOL)parseLocation:(NSPoint *)location
		   fromString:(NSString *)string;

- (NSDictionary *)locations;

@end
