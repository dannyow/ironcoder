#import "ETZonerView.h"
#import "GeometryAdditions.h"


@interface ETZonerView(PrivateAPI)

- (void)drawShapeFile:(SHPHandle)shapeFile
			inContext:(CGContextRef)context;

- (void)drawLocationsInContext:(CGContextRef)context;

- (void)drawCurrentLocationInContext:(CGContextRef)context;

- (void)redrawMap;

- (void)setupTrackingRects;

@end



@implementation ETZonerView


- (id)initWithFrame:(NSRect)frameRect {
	
	if ((self = [super initWithFrame:frameRect]) != nil) {
		
		NSString *path = [[NSBundle mainBundle] pathForResource:@"world"
														 ofType:@"shp"
													inDirectory:@"shapefiles/world1"];
		
		if (path == nil) {
			[NSException raise:@"BadMapFile"
						format:@"Map file not found in bundle!"];
		}
		
		_shapeFile = SHPOpen([path UTF8String], "rb");
		
		if (!_shapeFile) {
			
			[NSException raise:@"BadMapFile"
						format:@"Can't read map file in bundle!"];
		}		
		
		[self setProjection:[ETProjection projectionWithName:@"adams_wsI"]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(frameOrBoundsDidChange:)
													 name:NSViewFrameDidChangeNotification
												   object:self];
	}
	
	return self;
}


- (void)dealloc {
	
	[self setProjection:nil];
	
	CGLayerRelease(_mapLayer);
	CGLayerRelease(_locationsLayer);
	
	if (_shapeFile) {
		SHPClose(_shapeFile);
		_shapeFile = nil;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}


- (ETProjection *)projection {
	
	return [[_projection retain] autorelease];
}


- (void)setProjection:(ETProjection *)projection {
	
	if (projection != _projection) {
		
		[_projection release];
		_projection = [projection retain];
		
		[self redrawMap];
		[self setNeedsDisplay:TRUE];
	}	
}


- (void)setLocations:(NSDictionary *)locations {
	
	if (locations != _locations) {
		
		[_locations release];
		_locations = [locations retain];
		
		[self redrawMap];
		[self setNeedsDisplay:TRUE];
	}	
}


- (NSTimeZone *)currentLocation {
	
	return [[_currentLocation retain] autorelease];
}


- (void)setCurrentLocation:(NSTimeZone *)location {

	if (location != _currentLocation) {
		
		[_currentLocation release];
		_currentLocation = [location retain];
		
		//FIXME: Should only invalidate a rect here
		[self setNeedsDisplay:YES];
	}
}


- (void)redrawMap {
	
	CGLayerRelease(_mapLayer);
	CGLayerRelease(_locationsLayer);

	CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	
	_mapLayer = CGLayerCreateWithContext(context, NSRectToCGRect([self frame]).size, NULL);
		
	[self drawShapeFile:_shapeFile
			  inContext:CGLayerGetContext(_mapLayer)];
	
	_locationsLayer = CGLayerCreateWithContext(context, NSRectToCGRect([self frame]).size, NULL);

	[self drawLocationsInContext:CGLayerGetContext(_locationsLayer)];
	
	[self setupTrackingRects];
}


- (void)setupTrackingRects {

	if (_trackingRectTags) {
		
		NSTrackingRectTag *tagTable = (NSTrackingRectTag *)[_trackingRectTags bytes];
		int numTags = [_trackingRectTags length] / sizeof(NSTrackingRectTag);
		
		int i;
		
		for (i = 0; i < numTags; i++) {
			
			[self removeTrackingRect:tagTable[i]];
		}
		
		[_trackingRectTags release];
		_trackingRectTags = nil;
	}
	
	//
	// Now add them again.
	
	int numTags = [_locations count];
	NSTrackingRectTag *tagTable = (NSTrackingRectTag *)malloc(numTags * sizeof(NSTrackingRectTag));
	_trackingRectTags = [[NSData dataWithBytesNoCopy:tagTable 
											  length:numTags * sizeof(NSTrackingRectTag)] retain];
	NSTrackingRectTag *tagsPtr = tagTable;
	
	NSEnumerator *locationEnumerator = [_locations keyEnumerator];
	NSTimeZone *location;
	
	while ((location = [locationEnumerator nextObject]) != nil) {
		
		NSPoint point = [_projection transformForward:[[_locations objectForKey:location] pointValue]
											   inRect:[self frame]];
		
		NSRect rect = NSMakeRect(point.x - 2.5, point.y - 2.5, 5, 5);

		NSTrackingRectTag tag = [self addTrackingRect:rect
												owner:self
											 userData:location
										 assumeInside:NO];
		
		*tagsPtr++ = tag;
	}
}


- (void)mouseEntered:(NSEvent *)event {
	
	[self setCurrentLocation:(NSTimeZone *)[event userData]];
}


- (void)mouseExited:(NSEvent *)event {
	
	[self setCurrentLocation:nil];
}


- (void)drawShapeFile:(SHPHandle)shapeFile
			inContext:(CGContextRef)context {
	
	int numEntities;
	int shapeType;
	double minBound[4];
	double maxBound[4];
	
	// see http://shapelib.maptools.org/shp_api.html
	
	SHPGetInfo(shapeFile, &numEntities, &shapeType, minBound, maxBound);
	
	//
	// Turn off anti-aliasing, since it causes crashes. :-(
	
	CGContextSetShouldAntialias(context, NO);
	
	CGContextSetRGBFillColor(context, 0, 1, 0, 1.0);
	CGContextSetLineWidth(context, 1);
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
	
	int i;
	
	for (i = 0; i < numEntities; i++) {
		
		SHPObject *shape = SHPReadObject(shapeFile, i);

		//;;NSLog(@"shape %d: type = %d, nParts = %d", i, shape->nSHPType, shape->nParts);
		
		if (shape->nSHPType != SHPT_POLYGON) {

			[NSException raise:@"BadMapFile"
						format:@"Map file contained non-polygon shape"];
		}
		
		int v;
		
		if (shape->nParts == 0
			|| shape->nParts == 1) {
			
			CGContextBeginPath(context);
			
			for (v = 0; v < shape->nVertices; v++) {
				
				NSPoint pt = [[self projection] transformForward:NSMakePoint(shape->padfX[v], shape->padfY[v])
														  inRect:[self frame]];
				
				if (v == 0)
					CGContextMoveToPoint(context, pt.x, pt.y);
				else
					CGContextAddLineToPoint(context, pt.x, pt.y);
				//;;NSLog(@"drawing @ pt %@", NSStringFromPoint(pt));
			}
			
			CGContextClosePath(context);
			
			CGContextFillPath(context);
			CGContextStrokePath(context);		

		} else if (1) {
			
			int p;
			
			for (p = 0; p < shape->nParts; p++) {
				
				//;;NSLog(@"  part %d: type = %d, start = %d", p, shape->panPartType[p], shape->panPartStart[p]);
			
				if (shape->panPartType[p] != SHPT_POLYGON) {
					
					[NSException raise:@"BadMapFile"
								format:@"Map file contained non-polygon part"];
				}
								
				CGContextBeginPath(context);
				
				int last;
				if (p == shape->nParts - 1) {
					last = shape->nVertices;
				} else {
					last = shape->panPartStart[p+1];
				}
				
				int numPoints = last - shape->panPartStart[p];
				
				if (numPoints < 1) {
					[NSException raise:@"BadMapFile"
								format:@"Map contained empty part"];
				}

				CGPoint *points = malloc(numPoints * sizeof(CGPoint));
				CGPoint *cgpt = points;
				
				for (v = shape->panPartStart[p]; v < last; v++) {
					
					NSPoint pt = [[self projection] transformForward:NSMakePoint(shape->padfX[v], shape->padfY[v])
															  inRect:[self frame]];

					if (pt.x != INFINITY && pt.x != NAN && 
						pt.y != INFINITY && pt.y != NAN) {
						
						cgpt->x = pt.x;
						cgpt->y = pt.y;
						cgpt++;
					}
				}

				CGContextAddLines(context, points, cgpt - points);
				
				free(points);
				
				CGContextClosePath(context);
				
				CGContextFillPath(context);
				CGContextStrokePath(context);
			}
		}
		
	}
}


//- (void)drawText:(NSString *)text
//		 inFrame:(NSRect)frame
//		 context:(CGContextRef)context {
//	
//	CGContextSelectFont(context, "Times-Bold", 18, kCGEncodingMacRoman);
//
//	CGContextSetRGBFillColor(context, 0, 1, 0, .5);
//	CGContextSetRGBStrokeColor(context, 0, 0, 1, 1);
//	NSData *textData = [text dataUsingEncoding:NSMacOSRomanStringEncoding];
//	CGContextShowTextAtPoint(context, 0, 0, (char *)[textData bytes], [textData length]);
//}


- (void)drawLocation:(NSTimeZone *)location
			 atPoint:(CGPoint)point
		   inContext:(CGContextRef)context {
	
	CGContextBeginPath(context);
	
	float radius = 2.5;
	CGRect rect = CGRectMake(point.x - radius, point.y - radius, radius * 2, radius * 2);
	CGContextAddEllipseInRect(context, rect);
	
	CGContextClosePath(context);
	
	CGContextSetRGBFillColor(context, 1, 0, 0, 1.0);		
	CGContextFillPath(context);
}


- (void)drawClock:(NSTimeZone *)location
		  atPoint:(CGPoint)point
		inContext:(CGContextRef)context {
	
	NSCalendarDate *date = [NSCalendarDate calendarDate];
	[date setTimeZone:location];

	CGContextSaveGState(context);
	
	float radius = 25;
	float clockOffset = 50;
	CGPoint clockPoint = CGPointMake(point.x, point.y + clockOffset);

	CGContextSetLineCap(context, kCGLineCapRound);
	
	//
	// Draw the spotlight that rises above the location point.
	
	CGContextSetRGBFillColor(context, 1, 1, 1, 0.7);

	CGContextBeginPath(context);
	CGContextMoveToPoint(context, point.x, point.y);
	CGContextAddLineToPoint(context, point.x - radius/2, clockPoint.y);
	CGContextAddLineToPoint(context, point.x + radius/2, clockPoint.y);
	CGContextClosePath(context);	
	CGContextFillPath(context);

	//
	// The whole clock face will be shadowed, but we don't want the parts to have their own shadows.
	
	CGContextSetShadow(context, CGSizeMake(3, -3), 5);

	CGContextBeginTransparencyLayer(context, NULL);

	//
	// Draw the clock background.
		
	CGContextSetRGBFillColor(context, 1, 1, 1, 1.0);	
	
	CGContextBeginPath(context);
	CGRect rect = CGRectMake(clockPoint.x - radius, clockPoint.y - radius, radius * 2, radius * 2);
	CGContextAddEllipseInRect(context, rect);
	CGContextClosePath(context);
	CGContextFillPath(context);
	CGContextStrokePath(context);
	
	//
	// Draw the clock face -- hour, then minute.
	
	CGContextSetLineWidth(context, 3);
	CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);

	int i;
	
	for (i = 0; i < 2; i++) {
		
		int n;
		int range;
		float r;
		
		switch (i) {
			case 0:
				n = [date hourOfDay] % 12;
				range = 12;
				r = radius * 0.50;
				break;
			case 1:
				n = [date minuteOfHour];
				range = 60;
				r = radius * 0.80;
				break;
			default:
				break;
		}

		float angle = 90.0 + 360.0 - (((float)n / (float)range) * 360.0);
		angle = fmodf(angle, 360);
		
		CGPoint direction = CGPointMake(cos(angle * DEG_TO_RAD),
										sin(angle * DEG_TO_RAD));
		
		CGPoint p1 = CGPointMake(clockPoint.x + (-1.0 * direction.x),
								 clockPoint.y + (-1.0 * direction.y));
		
		CGPoint p2 = CGPointMake(clockPoint.x + (r * direction.x),
								 clockPoint.y + (r * direction.y));
		
		CGContextBeginPath(context);
		CGContextMoveToPoint(context, p1.x, p1.y);
		CGContextAddLineToPoint(context, p2.x, p2.y);
		CGContextClosePath(context);	
		CGContextStrokePath(context);		
	}
	
	CGContextEndTransparencyLayer(context);
	
	CGContextRestoreGState(context);
}


- (void)drawLocationsInContext:(CGContextRef)context {
	
	NSEnumerator *locationEnumerator = [_locations keyEnumerator];
	NSTimeZone *location;
	
	while ((location = [locationEnumerator nextObject]) != nil) {
		
		CGPoint point = NSPointToCGPoint([_projection transformForward:[[_locations objectForKey:location] pointValue]
																inRect:[self frame]]);
		
		[self drawLocation:location
				   atPoint:point
				 inContext:context];
	}
}


- (void)drawCurrentLocationInContext:(CGContextRef)context {
	
	if (_currentLocation) {
		
		CGPoint point = NSPointToCGPoint([_projection transformForward:[[_locations objectForKey:_currentLocation] pointValue]
																inRect:[self frame]]);
		
		[self drawClock:_currentLocation
				atPoint:point
			  inContext:context];		
	}
}


- (void)drawRect:(NSRect)rect {
	
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
	
	CGContextSetRGBFillColor(context, 0, 0, 1, 1.0);
	CGContextAddRect(context, NSRectToCGRect([self bounds]));
	CGContextFillPath(context);
	
	CGContextDrawLayerAtPoint(context, CGPointMake(0, 0), _mapLayer);
	CGContextDrawLayerAtPoint(context, CGPointMake(0, 0), _locationsLayer);

	[self drawCurrentLocationInContext:context];
}


- (void)frameOrBoundsDidChange:(NSNotification *)notification {
	
#pragma	unused(notification)
	
	[self redrawMap];
}


@end