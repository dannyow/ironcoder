#import "RSUIElement.h"

@implementation RSUIElement

+ (id) systemWideElement
{
	return [self uiElementWithNativeRef:AXUIElementCreateSystemWide()];
}

+ (NSArray*) applicationElements
{
	NSMutableArray* appArray = [NSMutableArray array];
	
	// Create an app node for every process Cocoa considers to be an "app"
	NSEnumerator* appEnum = [[[NSWorkspace sharedWorkspace] launchedApplications] objectEnumerator];
	NSNumber* thisPID = nil;
	while (thisPID = [[appEnum nextObject] objectForKey:@"NSApplicationProcessIdentifier"])
	{
		RSUIElement* thisAppElement = [self uiElementWithNativeRef:AXUIElementCreateApplication([thisPID intValue])];
		if (thisAppElement != nil)
		{
			[appArray addObject:thisAppElement];
		}
	}
	return appArray;
}

+ (id) uiElementWithNativeRef:(AXUIElementRef)newElement
{
	return [[[self alloc] initWithNativeRef:newElement] autorelease];	
}

- (id) initWithNativeRef:(AXUIElementRef)newElement
{
	if (self = [super init])
	{
		mNativeElement = newElement;
		if (mNativeElement != NULL)
		{
			CFRetain(newElement);
		}
	}
	return self;
}

- (void)dealloc
{
	if (mNativeElement != NULL)
	{
		CFRelease(mNativeElement);
	}
	
	[super dealloc];
}

- (BOOL) isLeaf
{
	return ([[self children] count] == 0);
}

- (BOOL) representsNativeElement:(AXUIElementRef)theElement
{
	return (theElement && mNativeElement && CFEqual(theElement, mNativeElement));
}

- (NSString*) roleDescription
{
	NSString* foundDesc = nil;
	AXUIElementCopyAttributeValue(mNativeElement, CFSTR("AXRoleDescription"), (CFTypeRef*) &foundDesc);
	return [foundDesc autorelease];
}

- (NSString*) title
{
	NSString* foundDesc = nil;
	AXUIElementCopyAttributeValue(mNativeElement, CFSTR("AXTitle"), (CFTypeRef*) &foundDesc);
	return [foundDesc autorelease];
}

- (NSString*) helpText
{
	NSString* foundDesc = nil;
	AXUIElementCopyAttributeValue(mNativeElement, CFSTR("AXHelp"), (CFTypeRef*) &foundDesc);
	return [foundDesc autorelease];
}

- (NSString*) userVisibleName
{
	// Try for help first
	if (([[self helpText] length] > 0) && ([[self helpText] isEqualToString:@"(null)"] == NO))
	{
		return [self helpText];
	}
	else if ([[self title] length] > 0)
	{
		return [self title];
	}
	else
	{
		return [self roleDescription];
	}

}

- (NSArray*) children
{
	NSMutableArray* childArray = [NSMutableArray array];
	CFArrayRef nativeCFArray = NULL;
	
	if (AXUIElementCopyAttributeValues(mNativeElement, CFSTR("AXChildren"), 0, 1000, &nativeCFArray) == kAXErrorSuccess)
	{
		NSArray* nativeArray = (NSArray*)nativeCFArray;
		NSEnumerator* axEnum = [nativeArray objectEnumerator];
		AXUIElementRef thisItem = NULL;
		while (thisItem = (AXUIElementRef) [axEnum nextObject])
		{
			[childArray addObject:[[self class] uiElementWithNativeRef:thisItem]];
		}
	}
	return childArray;
}

#if 0
- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %@>", [[self class] description], myPath];
}
#endif

@end
