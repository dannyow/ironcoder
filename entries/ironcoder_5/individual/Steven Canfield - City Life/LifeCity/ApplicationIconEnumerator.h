//
//  ApplicationIconEnumerator.h
//  LifeCity
//
//  Created by Steven Canfield on 1/04/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Photo.h"
#import <ApplicationServices/ApplicationServices.h>
#import <ScreenSaver/ScreenSaver.h>

@interface ApplicationIconEnumerator : NSEnumerator {
	NSMutableArray * photos;
	int photoIndex;
}
- (Photo *)nextObject;
@end
