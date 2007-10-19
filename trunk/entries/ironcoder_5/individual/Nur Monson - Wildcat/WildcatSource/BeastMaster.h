//
//  BeastMaster.h
//  Wildcat
//
//  Created by Nur Monson on 3/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BeastKeeper.h"

@interface BeastMaster : NSObject {
	NSMutableArray *_beastKeepers;
}

- (void)simulate;

- (void)draw;
@end
