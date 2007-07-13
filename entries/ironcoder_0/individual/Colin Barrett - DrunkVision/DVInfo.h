//
//  DVInfo.h
//  DrunkVision
//
//  Created by Colin Barrett on 3/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DV_INFO_WINDOW_TITLE	@"window title"
#define DV_INFO_APP_NAME		@"app name"

@interface DVInfo : NSObject {

}

//Hackily return a dictionary, to save on requestes to the API. See constants above.
+ (NSDictionary *)getInfoForPoint:(NSPoint)point;

@end
