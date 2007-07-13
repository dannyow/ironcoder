//
//  ETZoner.m
//  Zoner
//
//  Created by John Labovitz on 7/21/06.
//  Copyright 2006 Eureka Toolworks. All rights reserved.
//

#import "ETZoner.h"

#import "ETProjection.h"


@implementation ETZoner


- (void)awakeFromNib {
	
	[[_view window] performZoom:self];
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification {
	
#pragma	unused(notification)
	
	//
	// These are the names of map projections, as used by the libproj4 library.  This list is somewhat edited,
	// as a few of the projections require extra parameters, and some others aren't useful or look ugly.
	
	NSArray *names = [NSArray arrayWithObjects:
		@"adams_hemi",
		@"adams_wsI",
		@"adams_wsII",
		@"aeqd",
		@"airy",
		@"aitoff",
		@"apian1",
		@"apian2",
		@"ardn_cls",
		@"arma",
		@"august",
		@"bacon",
		@"baker",
		@"baranyi4",
		@"boggs",
		@"braun2",
		@"brny_1",
		@"brny_2",
		@"brny_3",
		@"brny_4",
		@"brny_5",
		@"brny_6",
		@"brny_7",
		@"bromley",
		@"cc",
		@"cea",
		@"collg",
		@"crast",
		@"cyl_stere",
		@"denoy",
		@"eck1",
		@"eck2",
		@"eck3",
		@"eck4",
		@"eck5",
		@"eck6",
		@"eisen",
		@"eqc",
		@"eq_moll",
		@"erdi_krusz",
		@"fahey",
		@"fc_gen",
		@"fc_pe",
		@"fc_ar",
		@"fc_pp",
		@"fouc",
		@"fouc_s",
		@"four1",
		@"four2",
		@"gilbert",
		@"gins8",
		@"gnom",
		@"goode",
		@"guyou",
		@"hall",
		@"hammer",
		@"hatano",
		@"holzel",
		@"kav5",
		@"kav7",
		@"kh_sh",
		@"laea",
		@"lagrng",
		@"larr",
		@"lask",
		@"loxim",
		@"maurer",
		@"mayr",
		@"mb_P3",
		@"mb_Q3",
		@"mb_S2",
		@"mb_S3",
		@"mbt_s",
		@"mbt_fps",
		@"mbtfpp",
		@"mbtfpq",
		@"mbtfps",
		@"merc",
		@"near_con",
		@"mil_os",
		@"mill",
		@"mill_per",
		@"mill_2",
		@"moll",
		@"nell",
		@"nell_h",
		@"nicol",
		@"ocea",
		@"ortel",
		@"ortho",
		@"oxford",
		@"pav_cyl",
		@"peirce_q",
		@"poly",
		@"putp1",
		@"putp1p",
		@"putp2",
		@"putp3",
		@"putp3p",
		@"putp4p",
		@"putp5",
		@"putp5p",
		@"putp6",
		@"putp6p",
		@"qua_aut",
		@"robin",
		@"rouss",
		@"rpoly",
		@"sinu",
		@"somerc",
		@"stere",
		@"sterea",
		@"s_min_err",
		@"stmerc",
		@"tcc",
		@"times",
		@"tmerc",
		@"tobler_1",
		@"tobler_2",
		@"tob_sqr",
		@"tob_g1",
		@"urm_2",
		@"urm_3",
		@"urm5",
		@"vandg",
		@"vandg2",
		@"vandg3",
		@"vandg4",
		@"wag1",
		@"wag2",
		@"wag3",
		@"wag4",
		@"wag5",
		@"wag6",
		@"wag7",
		@"wag8",
		@"wag9",
		@"weren",
		@"weren2",
		@"weren3",
		@"wink1",
		@"wink2",
		@"wintri",
		nil];
	
	[self setProjections:[NSMutableArray array]];
	
	NSEnumerator *e = [names objectEnumerator];
	NSString *name;
	
	while ((name = [e nextObject]) != nil) {
		
		ETProjection *projection = [ETProjection projectionWithName:name];
		
		if (projection) {
			
			[[self projections] addObject:projection];
		}
	}
	
	[_projectionStepper setMinValue:0];
	[_projectionStepper setMaxValue:[names count] - 1];
	
	_geoCoder = [[ETTimeZoneGeoCoder alloc] init];
	
	[_view setLocations:[_geoCoder locations]];
}


- (void)dealloc {
	
	[self setProjections:nil];
	
	[_geoCoder release];
	
	[super dealloc];
}


- (NSMutableArray *)projections {
	
	return [[_projections retain] autorelease];
}


- (void)setProjections:(NSArray *)projections {
	
	if (_projections != projections) {
		
		[_projections release];
		_projections = [projections mutableCopy];
	}
}


- (unsigned)projectionIndex {
	
	return [_projections indexOfObject:[_view projection]];
}


- (void)setProjectionIndex:(unsigned)index {
	
	[_view setProjection:[[self projections] objectAtIndex:index]];
}


@end