//
//  NSObjectExtensions.m
//  Reminder
//
//  Created by Andy Kim on 2/21/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSObjectAdditions.h"


@implementation NSObject (PFAdditions)
- (id)v:(NSString*)key
{
	return [self valueForKey:key];
}

- (id)vp:(NSString*)path
{
	return [self valueForKeyPath:path];
}

- (void)sv:(id)value fk:(NSString*)key
{
	[self setValue:value forKey:key];
}
@end
