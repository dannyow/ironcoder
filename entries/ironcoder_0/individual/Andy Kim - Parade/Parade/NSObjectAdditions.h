//
//  NSObjectExtensions.h
//  Reminder
//
//  Created by Andy Kim on 2/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (PFAdditions)
- (id)v:(NSString*)key;
- (id)vp:(NSString*)path;
- (void)sv:(id)value fk:(NSString*)key;
@end
