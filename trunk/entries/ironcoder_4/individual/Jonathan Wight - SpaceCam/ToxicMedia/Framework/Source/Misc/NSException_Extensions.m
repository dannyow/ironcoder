//
//  NSException_Extensions.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/12/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import "NSException_Extensions.h"

#import "NSError_MoreExtensions.h"

@implementation NSException (NSException_Extensions)

+ (NSException *)exceptionWithError:(NSError *)inError format:(NSString *)inFormat, ...;
{
va_list theArgs;
va_start(theArgs, inFormat);
NSString *theReason = [[[NSString alloc] initWithFormat:inFormat arguments:theArgs] autorelease];
va_end(theArgs);

NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	inError, @"NSError",
	NULL];
NSException *theException = [self exceptionWithName:NSGenericException reason:theReason userInfo:theUserInfo];
return(theException);
}

+ (void)raiseError:(NSError *)inError format:(NSString *)inFormat, ...
{
va_list theArgs;
va_start(theArgs, inFormat);
NSString *theReason = [[[NSString alloc] initWithFormat:inFormat arguments:theArgs] autorelease];
va_end(theArgs);

NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	inError, @"NSError",
	NULL];
NSException *theException = [self exceptionWithName:NSGenericException reason:theReason userInfo:theUserInfo];
[theException raise];
}

+ (void)raiseErrorDomain:(NSString *)inDomain code:(int)inCode format:(NSString *)inFormat, ...;
{
va_list theArgs;
va_start(theArgs, inFormat);
NSString *theReason = [[[NSString alloc] initWithFormat:inFormat arguments:theArgs] autorelease];
va_end(theArgs);

NSError *theError = [NSError errorWithDomain:inDomain code:inCode lookedUpUserInfo:NULL];

NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	theError, @"NSError",
	NULL];
NSException *theException = [self exceptionWithName:inDomain reason:theReason userInfo:theUserInfo];
[theException raise];
}

+ (void)raiseOSStatus:(OSStatus)inStatus format:(NSString *)inFormat, ...
{
va_list theArgs;
va_start(theArgs, inFormat);
NSString *theReason = [[[NSString alloc] initWithFormat:inFormat arguments:theArgs] autorelease];
va_end(theArgs);

NSError *theError = [NSError errorWithDomain:NSOSStatusErrorDomain code:inStatus lookedUpUserInfo:NULL];

NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
	theError, @"NSError",
	NULL];
NSException *theException = [self exceptionWithName:NSGenericException reason:theReason userInfo:theUserInfo];
[theException raise];
}

- (NSError *)error
{
return([[self userInfo] valueForKey:@"NSError"]);
}


@end
