//
//  CExceptionHandler.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/13/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CExceptionHandler : NSObject {
	BOOL presentError;
	BOOL reraiseException;
}

+ (CExceptionHandler *)sharedExceptionHandler;

- (void)handleException:(NSException *)inException;
- (void)handleError:(NSError *)inError;

- (void)setPresentError:(BOOL)inPresentError;
- (void)setReraiseException:(BOOL)inPresentError;

@end
