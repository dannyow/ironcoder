//
//  ETProjection.m
//  Zoner
//
//  Created by John Labovitz on 7/22/06.
//  Copyright 2006 Eureka Toolworks. All rights reserved.
//

#import "ETProjection.h"


@implementation ETProjection


+ (id)projectionWithName:(NSString *)name {
	
	return [[[[self class] alloc] initWithName:name] autorelease];
}


- (id)init {
	
	return [self initWithName:nil];
}


- (id)initWithName:(NSString *)name {
	
	if ((self = [super init]) == nil) {
		return nil;
	}
	
	//FIXME: Hack
	_largestMapSize = 6;
	
	[self setName:name];
	
	NSString *spec = [NSString stringWithFormat:@"+proj=%@", name];
	char *params[1];
	params[0] = (char *)[spec UTF8String];
	_projection = pj_init(1, params);
	
	if (!_projection) {
		
		;;NSLog(@"couldn't create projection: %@: %s", spec, pj_strerrno(pj_errno));
		return nil;
	}
		
	return self;
}


- (void)dealloc {
	
	[self setName:nil];
	
	if (_projection) {
		pj_free(_projection);
		_projection = nil;
	}
	
	[super dealloc];
}


- (NSString *)description {
	
	return [self name];
}


- (NSPoint)transformForward:(NSPoint)from
					 inRect:(NSRect)rect {
	
	LP p1;
	p1.phi = from.y * DEG_TO_RAD;
	p1.lam = from.x * DEG_TO_RAD;
	XY p2 = pj_fwd(p1, _projection);
	
	NSPoint scale = NSMakePoint(NSWidth(rect) / _largestMapSize,
								NSHeight(rect) / _largestMapSize);
	
	NSPoint to = NSMakePoint(p2.x, p2.y);
	NSPoint toScaled = NSMakePoint(to.x * scale.x, to.y * scale.y);
	
	toScaled.x += NSWidth(rect) / 2;
	toScaled.y += NSHeight(rect) / 2;
	
	//;;NSLog(@"from %@ to %@, scaled by %@ to %@", NSStringFromPoint(from), NSStringFromPoint(to), NSStringFromPoint(scale), NSStringFromPoint(toScaled));
	
	return toScaled;
}


- (NSString *)name {
	
	return [[_name retain] autorelease];
}


- (void)setName:(NSString *)name {
	
	if (name != _name) {
		
		[_name release];
		_name = [[name retain] autorelease];
	}
}


@end