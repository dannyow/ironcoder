//
//  NSException_Extensions.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/12/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import <AppKit/AppKit.h>

#include <stdarg.h>

/**
 * @category NSException (NSException_Extensions)
 * @abstract TODO
 * @discussion TODO
 */
@interface NSException (NSException_Extensions)

+ (NSException *)exceptionWithError:(NSError *)inError format:(NSString *)inFormat, ...;

+ (void)raiseError:(NSError *)inError format:(NSString *)inFormat, ...;
+ (void)raiseErrorDomain:(NSString *)inDomain code:(int)inCode format:(NSString *)inFormat, ...;
+ (void)raiseOSStatus:(OSStatus)inStatus format:(NSString *)inFormat, ...;

- (NSError *)error;

@end
