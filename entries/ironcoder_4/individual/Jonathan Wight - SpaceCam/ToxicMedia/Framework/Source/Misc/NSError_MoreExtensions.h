//
//  NSError_MoreExtensions.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/13/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import <AppKit/AppKit.h>

/**
 * @category NSError (NSError_MoreExtensions)
 * @abstract TODO
 * @discussion TODO
 */
@interface NSError (NSError_MoreExtensions)

+ (NSDictionary *)userInfoForErrorDomain:(NSString *)inErrorDomain code:(int)inCode;

+ (NSError *)errorWithDomain:(NSString *)inDomain code:(int)inCode lookedUpUserInfo:(NSDictionary *)inUserInfo;

+ (NSError *)applicationErrorWithCode:(int)inCode userInfo:(NSDictionary *)inUserInfo;

@end
