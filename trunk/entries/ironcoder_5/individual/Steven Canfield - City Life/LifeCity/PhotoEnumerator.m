//
//  PhotoEnumerator.m
//  LifeCity
//
//  Created by Steven Canfield on 31/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "PhotoEnumerator.h"


@implementation PhotoEnumerator
- (id)initWithContentsOfFolder:(NSString *)folder
{
	self = [super init];
	
	if( self ) {
		photoIndex = 0;
		photos = [[NSMutableArray alloc] init];
	
		NSString * file;
		NSDirectoryEnumerator * enumer = [[NSFileManager defaultManager] enumeratorAtPath:folder];
		while( file = [enumer nextObject] ) {
			if( [[file pathExtension] isEqualToString:@"jpg"] ) {
				NSString * fullPath = [NSString stringWithFormat:@"%@/%@", folder, file];
				//NSLog(fullPath);
				Photo * myPhoto = [[Photo alloc] initWithContentsOfFile:fullPath];
				if( myPhoto != NULL ) {
					[photos addObject:myPhoto];
				}
			}
		}
		
		photoIndex = SSRandomIntBetween( 0 , [photos count] - 1 );
		
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
