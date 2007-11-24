//
//  NSNumberAdditions.h
//
//  Created by Jonathan Saggau on 8/31/06.
//

#import <Foundation/Foundation.h>

@interface NSNumber (NSNumberAdditions)

// pass in a string representing a number...
+ (NSNumber *)numberWithString:(NSString *)string;

@end