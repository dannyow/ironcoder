//
//  PhotoEnumerator.h
//  LifeCity
//
//  Created by Steven Canfield on 31/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>
#import "Photo.h"

@interface PhotoEnumerator : NSEnumerator {
	NSMutableArray * photos;
	int photoIndex;
}
- (id)initWithContentsOfFolder:(NSString *)folder;
- (id)nextObject;
@end
