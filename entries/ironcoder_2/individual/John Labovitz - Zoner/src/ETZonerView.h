/* ETZonerView */

#import <Cocoa/Cocoa.h>

#import "ETProjection.h"

#include <shapefil.h>


@interface ETZonerView : NSView {

	NSData *_trackingRectTags;
	ETProjection *_projection;
	NSDictionary *_locations;
	NSTimeZone *_currentLocation;
	CGLayerRef _mapLayer;
	CGLayerRef _locationsLayer;
	SHPHandle _shapeFile;
}

- (ETProjection *)projection;
- (void)setProjection:(ETProjection *)projection;

- (void)setLocations:(NSDictionary *)locations;

- (NSTimeZone *)currentLocation;
- (void)setCurrentLocation:(NSTimeZone *)timeZone;

@end