//
//  CExceptionHandler.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/13/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CExceptionHandler.h"

#import "NSException_Extensions.h"

@implementation CExceptionHandler

+ (CExceptionHandler *)sharedExceptionHandler
{
CExceptionHandler *theExceptionHandler = [[[NSThread currentThread] threadDictionary] objectForKey:NSStringFromClass([self class])];
if (theExceptionHandler == NULL)
	{
	theExceptionHandler = [[[self alloc] init] autorelease];
	[[[NSThread currentThread] threadDictionary] setObject:theExceptionHandler forKey:NSStringFromClass([self class])];
	}
return(theExceptionHandler);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	presentError = YES;
	reraiseException = NO;
	}
return(self);
}

- (void)handleException:(NSException *)inException
{
if (presentError == YES)
	{
	NSError *theError = [inException error];
	if (theError == NULL)
		{
		NSDictionary *theUserInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			inException, @"NSException",
			NULL];
		theError = [NSError errorWithDomain:@"TXToxicSoftwareDomain" code:-1 userInfo:theUserInfo];
		}
	[[NSApplication sharedApplication] presentError:theError];
	}
if (reraiseException == YES)
	[inException raise];
}

- (void)handleError:(NSError *)inError
{
NSException *theException = [NSException exceptionWithError:inError format:@""];
[self handleException:theException];
}

- (void)setPresentError:(BOOL)inPresentError
{
presentError = inPresentError;
}

- (void)setReraiseException:(BOOL)inReraiseException
{
reraiseException = inReraiseException;
}


@end
