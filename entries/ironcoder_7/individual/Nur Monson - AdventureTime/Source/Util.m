//
//  Util.m
//  AdventureTime
//
//  Created by Nur Monson on 11/12/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Util.h"


CGImageRef loadImageOfTypeFromMainBundle(NSString *filename, NSString *type)
{
	CGDataProviderRef dataProvider = CGDataProviderCreateWithURL((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filename ofType:type]] );
	if( !dataProvider )
		return NULL;
	
	CGImageRef newImage = NULL;
	if( [type isEqualToString:@"jpg"] )
		newImage = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, TRUE, kCGRenderingIntentDefault);
	else if( [type isEqualToString:@"png"] )
		newImage = CGImageCreateWithPNGDataProvider(dataProvider, NULL, TRUE, kCGRenderingIntentDefault);
	else
		return NULL;
	
	CGDataProviderRelease( dataProvider );
	return newImage;
}
