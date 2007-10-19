//
//  ApplicationIconEnumerator.m
//  LifeCity
//
//  Created by Steven Canfield on 1/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ApplicationIconEnumerator.h"


extern OSStatus _LSCopyAllApplicationURLs(CFArrayRef *array);

@implementation ApplicationIconEnumerator
- (id)init {
	self = [super init];
	
	if( self ) {
		photos = [[NSMutableArray alloc] init];
		
		CFArrayRef array;
		_LSCopyAllApplicationURLs(&array);
	//	CFShow(array);
		int i;
		for(i = 0; i < CFArrayGetCount( array ); i++ ) {
			CFURLRef url = CFArrayGetValueAtIndex( array , i );
		//	CFShow(url);
			
			CFStringRef string = CFURLGetString( url );
		//	CFShow(string);
			
			CFRange range = CFStringFind( string, CFSTR("Applications"), 0 );
			
			if( range.location != kCFNotFound ) {
				//CFShow(string);
				NSString * path =  [(NSString *)string substringFromIndex:[@"file://localhost" length]];
				path = [path stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
				Photo * icon = [[Photo alloc] initWithIconForFile: path ];
				[photos addObject:icon];
			}
		}
		
		photoIndex = SSRandomIntBetween( 0 , [photos count]-1);
	
	}
	return self;
}

- (Photo *)nextObject {
	if( photoIndex >= [photos count] ) {
		photoIndex = 0;
	}
	
	Photo * p = [photos objectAtIndex:photoIndex];
	photoIndex++;
	return [[p retain] autorelease];
}
@end
