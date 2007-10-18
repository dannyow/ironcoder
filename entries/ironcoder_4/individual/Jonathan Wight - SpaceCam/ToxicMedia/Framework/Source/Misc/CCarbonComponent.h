//
//  CCarbonComponent.h
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/24/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface CCarbonComponent : NSObject {
	Component component;
}

+ (NSArray *)allComponentsOfType:(OSType)inComponentType subType:(OSType)inSubType;

- (Component)component;
- (void)setComponent:(Component)inComponent;

- (NSDictionary *)info;

@end
