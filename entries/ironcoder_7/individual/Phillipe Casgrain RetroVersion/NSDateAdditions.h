//
//  NSDateAdditions.h
//
//  Created by Philippe Casgrain on Nov 14, 2007
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateAdditions)

// pass in a svn-formatted string representing a date...
+ (NSDate*) dateWithSVNString: (NSString*) string;

@end