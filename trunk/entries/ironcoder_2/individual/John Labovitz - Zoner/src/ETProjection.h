//
//  ETProjection.h
//  Zoner
//
//  Created by John Labovitz on 7/22/06.
//  Copyright 2006 Eureka Toolworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include <lib_proj.h>


@interface ETProjection : NSObject {

	float _largestMapSize;
	NSString *_name;
	PJ *_projection;
}

+ (id)projectionWithName:(NSString *)name;

- (id)initWithName:(NSString *)name;

- (NSPoint)transformForward:(NSPoint)from
					 inRect:(NSRect)rect;

- (NSString *)name;
- (void)setName:(NSString *)name;

@end