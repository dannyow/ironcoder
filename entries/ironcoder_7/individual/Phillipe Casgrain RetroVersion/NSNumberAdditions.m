//
//  NSNumberAdditions.m
//
//  Created by Jonathan Saggau on 8/31/06.
//

#import "NSNumberAdditions.h"

@implementation NSNumber (NSNumberAdditions)

+ (NSNumber *)numberWithString:(NSString *)string;
{
    NSScanner *scanner;
    int scanLocation = 0;
        
    scanner = [NSScanner scannerWithString:string];
    // just in case we're given a dollar value
    if ([string hasPrefix:@"$"]) scanLocation = 1;    
    
    int intResult;
    [scanner setScanLocation:scanLocation];
    if ([scanner scanInt:&intResult] 
        && ([scanner scanLocation] == [string length] )) {
        return [NSNumber numberWithInt:intResult];
    }
    
    float floatResult;
    [scanner setScanLocation:scanLocation];
    if ([scanner scanFloat:&floatResult] 
        && ([scanner scanLocation] == [string length] )) {
        return [NSNumber numberWithFloat:floatResult];
    }
    
    long long longLongResult;
    [scanner setScanLocation:scanLocation];
    if ([scanner scanLongLong:&longLongResult] 
        && ([scanner scanLocation] == [string length] )) {
        return [NSNumber numberWithLongLong:floatResult];
    }
    
    NSLog(@"WARNING::: Couldn't convert %@ to nsnumber", string);
    return [NSNumber numberWithInt:0];
}
@end
