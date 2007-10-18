#import "CCarbonComponentInstance.h"

@implementation CCarbonComponentInstance

- (id)init
{
if ((self = [super init]) != NULL)
	{
	componentInstance = NULL;
	}
return(self);
}

- (void)dealloc
{
[self close];
//
[super dealloc];
}

- (void)openDefaultComponentType:(OSType)inComponentType subType:(OSType)inComponentSubType
{
ComponentInstance theComponentInstance = NULL;
OSStatus theStatus = OpenADefaultComponent(inComponentType, inComponentSubType, &theComponentInstance);
if (theStatus != noErr)
	[NSException raise:NSGenericException format:@"-[CCarbonComponentInstance openDefaultComponentType] failed."];
[self setComponentInstance:theComponentInstance];
}

- (void)close
{
if (componentInstance)
	{
	OSStatus theStatus = CloseComponent(componentInstance);
	if (theStatus != noErr)
		[NSException raise:NSGenericException format:@""];
	componentInstance = NULL;
	}
}

- (void)setComponentInstance:(ComponentInstance)inComponentInstance
{
if (inComponentInstance == componentInstance)
	return;
if (componentInstance != NULL)
	{
	[self close];
	}
if (inComponentInstance != NULL)
	{
	componentInstance = inComponentInstance;
	}
}

- (ComponentInstance)componentInstance
{
return(componentInstance);
}

- (ComponentInstance)detachComponentInstance
{
ComponentInstance theComponentInstance = componentInstance;
componentInstance = NULL;
return(theComponentInstance);
}

@end
