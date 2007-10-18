//
//  NSError_MoreExtensions.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/13/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import "NSError_MoreExtensions.h"

@implementation NSError (NSError_MoreExtensions)

+ (NSDictionary *)userInfoForErrorDomain:(NSString *)inErrorDomain code:(int)inCode
{
NSBundle *theBundle = [NSBundle mainBundle];

NSString *thePrefix = [NSString stringWithFormat:@"%@.%d", inErrorDomain, inCode];

NSString *theDescription = [theBundle localizedStringForKey:[NSString stringWithFormat:@"%@.Description", thePrefix] value:NULL table:@"Errors"];
NSString *theFailureReason = [theBundle localizedStringForKey:[NSString stringWithFormat:@"%@.FailureReason", thePrefix] value:NULL table:@"Errors"];
NSString *theRecoverySuggestion = [theBundle localizedStringForKey:[NSString stringWithFormat:@"%@.RecoverySuggestion", thePrefix] value:NULL table:@"Errors"];

NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionary];
if (theDescription != NULL)
	[theUserInfo setObject:theDescription forKey:NSLocalizedDescriptionKey];
if (theFailureReason != NULL)
	[theUserInfo setObject:theFailureReason forKey:NSLocalizedFailureReasonErrorKey];
if (theRecoverySuggestion != NULL)
	[theUserInfo setObject:theRecoverySuggestion forKey:NSLocalizedRecoverySuggestionErrorKey];

return(theUserInfo);
}

+ (NSError *)errorWithDomain:(NSString *)inDomain code:(int)inCode lookedUpUserInfo:(NSDictionary *)inUserInfo
{
NSMutableDictionary *theUserInfo = [[[self userInfoForErrorDomain:inDomain code:inCode] mutableCopy] autorelease];
[theUserInfo addEntriesFromDictionary:inUserInfo];
NSError *theError = [self errorWithDomain:inDomain code:inCode userInfo:theUserInfo];
return(theError);
}

+ (NSError *)applicationErrorWithCode:(int)inCode userInfo:(NSDictionary *)inUserInfo
{
NSString *theDomain = [NSString stringWithFormat:@"%@.ErrorDomain", [[NSBundle mainBundle] bundleIdentifier]];

NSMutableDictionary *theUserInfo = [[[self userInfoForErrorDomain:theDomain code:inCode] mutableCopy] autorelease];
[theUserInfo addEntriesFromDictionary:inUserInfo];
NSError *theError = [self errorWithDomain:theDomain code:inCode userInfo:theUserInfo];
return(theError);
}

@end
