//
//  CCarbonComponent.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/24/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CCarbonComponent.h"

#import "CCarbonHandle.h"

@implementation CCarbonComponent

+ (NSArray *)allComponentsOfType:(OSType)inComponentType subType:(OSType)inSubType
{
NSMutableArray *theComponents = [NSMutableArray array];

ComponentDescription theDescription = {
	.componentType = inComponentType,
	.componentSubType = inSubType,
	.componentManufacturer = 0,
	.componentFlags = 0,
	.componentFlagsMask = 0,
	};

Component theComponent = NULL;
while ((theComponent = FindNextComponent(theComponent, &theDescription)) != NULL)
	{
	CCarbonComponent *theCarbonComponent = [[[self alloc] init] autorelease];
	[theCarbonComponent setComponent:theComponent];
	[theComponents addObject:theCarbonComponent];
	}
return(theComponents);
}

- (Component)component
{
return(component);
}

- (void)setComponent:(Component)inComponent
{
component = inComponent;
}

- (NSDictionary *)info
{
NSMutableDictionary *theInfo = [NSMutableDictionary dictionary];

ComponentDescription theDescription;
CCarbonHandle *theComponentName = [CCarbonHandle carbonHandleWithEmptyHandle];
CCarbonHandle *theComponentInfo = [CCarbonHandle carbonHandleWithEmptyHandle];
OSStatus theStatus = GetComponentInfo([self component], &theDescription, [theComponentName handle], [theComponentInfo handle], NULL);
if (theStatus != noErr) [NSException raise:NSGenericException format:@"GetComponentInfo() failed."];

[theInfo setObject:[NSNumber numberWithUnsignedLong:theDescription.componentType] forKey:@"type"];
[theInfo setObject:[NSNumber numberWithUnsignedLong:theDescription.componentSubType] forKey:@"subType"];
[theInfo setObject:[NSNumber numberWithUnsignedLong:theDescription.componentManufacturer] forKey:@"manufacturer"];
[theInfo setObject:[NSNumber numberWithUnsignedLong:theDescription.componentFlags] forKey:@"flags"];
[theInfo setObject:[NSNumber numberWithUnsignedLong:theDescription.componentFlagsMask] forKey:@"flagsMask"];

[theInfo setObject:[theComponentName asPascalString] forKey:@"name"];
[theInfo setObject:[theComponentInfo asPascalString] forKey:@"info"];

return(theInfo);
}

@end
