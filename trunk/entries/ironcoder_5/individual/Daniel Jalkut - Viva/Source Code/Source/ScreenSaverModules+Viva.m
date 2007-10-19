//
//  ScreenSaverModules+Viva.m
//  VivaApp
//
//  Created by Daniel Jalkut on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ScreenSaverModules+Viva.h"


@implementation ScreenSaverModules (Viva)

+ (NSArray*) usableModuleNamesForViva
{
	ScreenSaverModules* modules = [ScreenSaverModules sharedInstance];
	NSMutableArray* allModules = [[[modules moduleNames] mutableCopy] autorelease];
	[allModules removeObject:@"Viva"];
	[allModules removeObject:@"Random"];
	return [NSArray arrayWithArray:allModules]; 
}

@end
