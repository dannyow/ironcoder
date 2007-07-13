//
//  IronDazzleController.h
//  IronDazzle
//
//  Created by Tom Harrington on 7/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class IronDazzleView;

@interface IronDazzleController : NSObject {
	NSPanel *dazzlePanel;
	IronDazzleView *dazzleView;
}

@end
