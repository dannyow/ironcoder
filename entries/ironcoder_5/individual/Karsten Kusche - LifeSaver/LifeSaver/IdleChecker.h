//
//  IdleChecker.h
//  Sleeper
//
//  Created by Karsten Kusche on 23.01.07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IdleChecker : NSObject {
	id target;
	id userData;
	SEL selector;
	int idleTime;
}

+ (id)send:(SEL) selector to:(id) target with:(id)userData afterIdleTimeOf:(int)seconds;
- (void)changeIdleTime:(int)seconds;
- (int)idleTime;

@end
