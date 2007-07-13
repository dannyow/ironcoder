//
//  ETZoner.h
//  Zoner
//
//  Created by John Labovitz on 7/21/06.
//  Copyright 2006 Eureka Toolworks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ETZonerView.h"
#import "ETTimeZoneGeoCoder.h"


@interface ETZoner : NSObject {
	
	NSMutableArray *_projections;
	ETTimeZoneGeoCoder *_geoCoder;
	
	IBOutlet ETZonerView *_view;
	IBOutlet NSStepper *_projectionStepper;
}

- (NSMutableArray *)projections;
- (void)setProjections:(NSArray *)projections;

- (unsigned)projectionIndex;
- (void)setProjectionIndex:(unsigned)index;

@end