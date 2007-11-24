//
//  NSDateAdditions.m
//
//  Created by Philippe Casgrain on Nov 14, 2007
//

#import "NSDateAdditions.h"

@implementation NSDate (NSDateAdditions)

+ (NSDate*) dateWithSVNString: (NSString*) string
{
	NSString* str = [string stringByReplacingOccurrencesOfString:@"T" withString:@" "];
	str = [str stringByReplacingOccurrencesOfString:@".000000Z" withString:@" +0000"];
	return [NSDate dateWithString: str];
}
@end
