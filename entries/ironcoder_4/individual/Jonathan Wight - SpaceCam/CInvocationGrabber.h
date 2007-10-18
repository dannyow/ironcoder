//
//  CInvocationGrabber.h
//
//  Created by Jonathan Wight on 03/16/2006.
//  Copyright 2006 Apago Inc., All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 * @class CInvocationGrabber
 * @discussion CInvocationGrabber is a helper object that makes it very easy to construct instances of NSInvocation. The object is inspired by NSUndoManager's prepareWithInvocationTarget method.

CInvocationGrabber *theInvocationGrabber = [CInvocationGrabber invocationGrabber];
[[theInvocationGrabber prepareWithInvocationTarget:someObject] doSomethingWithParameter:someParameter];
NSInvocation *theInvocation = [theInvocationGrabber invocation];

 */
@interface CInvocationGrabber : NSObject {
	id target;
	NSInvocation *invocation;
}

+ (id)invocationGrabber;

- (id)init;

- (id)target;
- (void)setTarget:(id)inTarget;

- (NSInvocation *)invocation;
- (void)setInvocation:(NSInvocation *)inInvocation;

- (id)prepareWithInvocationTarget:(id)inTarget;

@end
