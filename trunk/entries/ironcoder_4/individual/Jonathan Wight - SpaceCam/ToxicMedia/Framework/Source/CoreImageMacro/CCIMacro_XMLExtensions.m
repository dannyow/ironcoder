//
//  CCIMacro_XMLExtensions.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 09/10/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import "CCIMacro_XMLExtensions.h"

#import <QuartzCore/QuartzCore.h>

@interface CCIMacro (CCIMacro_XMLExtensions_Private)

- (void)processMacro:(NSXMLElement *)inElement;
- (void)processInputs:(NSXMLElement *)inElement;
- (void)processOutputs:(NSXMLElement *)inElement;
- (void)processNodes:(NSXMLElement *)inElement;
- (NSMutableDictionary *)processValue:(NSXMLElement *)inElement;

@end

#pragma mark -

@implementation CCIMacro (CCIMacro_XMLExtensions)

- (id)initWithXMLData:(NSData *)inData;
{
if ((self = [super init]) != NULL)
	{
	NSError *theError = NULL;
	NSXMLDocument *theDocument = [[[NSXMLDocument alloc] initWithData:inData options:0 error:&theError] autorelease];
	if (theDocument == NULL) [NSException raise:NSGenericException format:@"Coult not parse XML document %@", theError];

	inputs = [[NSMutableDictionary alloc] init];
	outputs = [[NSMutableDictionary alloc] init];
	nodesList = [[NSMutableArray alloc] init];
	nodes = [[NSMutableDictionary alloc] init];

	[self processMacro:[theDocument rootElement]];
	
//	[self dryrun];
	}
return(self);
}

- (id)initWithFile:(NSString *)inFile;
{
NSData *theXMLData = [NSData dataWithContentsOfFile:inFile];
return([self initWithXMLData:theXMLData]);
}

@end

#pragma mark -

@implementation CCIMacro (CCIMacro_XMLExtensions_Private)

- (void)processMacro:(NSXMLElement *)inElement
{
NSError *theError = NULL;
NSXMLElement *theInputsElement = [[inElement nodesForXPath:@"inputs" error:&theError] objectAtIndex:0];
[self processInputs:theInputsElement];
NSXMLElement *theNodesElement = [[inElement nodesForXPath:@"nodes" error:&theError] objectAtIndex:0];
[self processNodes:theNodesElement];

// If there are no outputs create a default output based on the outputImage of the last filter.
if ([[inElement nodesForXPath:@"outputs" error:&theError] count] > 0)
	{
	NSXMLElement *theOutputsElement = [[inElement nodesForXPath:@"outputs" error:&theError] objectAtIndex:0];
	[self processOutputs:theOutputsElement];
	}
else
	{
	NSString *theLastNodeKey = [[nodesList lastObject] objectForKey:@"key"];
	NSMutableDictionary *theDefaultOutputDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		@"outputImage", @"key",
		@"image", @"type",
		[NSString stringWithFormat:@"%@.outputImage", theLastNodeKey], @"ref",
		NULL
		];
	[outputs setObject:theDefaultOutputDictionary forKey:@"outputImage"];
	}
}

- (void)processInputs:(NSXMLElement *)inElement
{
NSError *theError;
NSArray *theInputs = [inElement nodesForXPath:@"*" error:&theError];
NSEnumerator *theEnumerator = [theInputs objectEnumerator];
NSXMLElement *theInput = NULL;
while ((theInput = [theEnumerator nextObject]) != NULL)
	{
	NSMutableDictionary *theValueDictionary = [self processValue:theInput];
	[inputs setObject:theValueDictionary forKey:[theValueDictionary objectForKey:@"key"]];
	}
}

- (void)processOutputs:(NSXMLElement *)inElement
{
NSError *theError;
NSArray *theOutputs = [inElement nodesForXPath:@"*" error:&theError];
NSEnumerator *theEnumerator = [theOutputs objectEnumerator];
NSXMLElement *theOutput = NULL;
while ((theOutput = [theEnumerator nextObject]) != NULL)
	{
	NSMutableDictionary *theValueDictionary = [self processValue:theOutput];
	[outputs setObject:theValueDictionary forKey:[theValueDictionary objectForKey:@"key"]];
	}
}

- (void)processNodes:(NSXMLElement *)inElement
{
NSError *theError;
NSArray *theFilters = [inElement nodesForXPath:@"filter" error:&theError];
NSEnumerator *theFilterEnumerator = [theFilters objectEnumerator];
NSXMLElement *theFilterElement = NULL;
while ((theFilterElement = [theFilterEnumerator nextObject]) != NULL)
	{
	NSString *theKey = [[theFilterElement attributeForName:@"key"] stringValue];
	NSString *theCIFilterName = [[theFilterElement attributeForName:@"cifiltername"] stringValue];
	NSMutableDictionary *theInputsDictionary = [NSMutableDictionary dictionary];

	CIFilter *theFilter = [CIFilter filterWithName:theCIFilterName];
	[theFilter setDefaults];

	NSMutableDictionary *theFilterDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		theKey, @"key",
		theInputsDictionary, @"inputs",
		theFilter, @"filter",
		NULL];

	NSArray *theFilterInputs = [theFilterElement nodesForXPath:@"inputs/*" error:&theError];
	NSEnumerator *theInputEnumerator = [theFilterInputs objectEnumerator];
	NSXMLElement *theInputElement = NULL;
	while ((theInputElement = [theInputEnumerator nextObject]) != NULL)
		{
		NSDictionary *theValueDictionary = [self processValue:theInputElement];
		if ([theValueDictionary objectForKey:@"value"])
			{
			[theFilter setValue:[theValueDictionary objectForKey:@"value"] forKey:[theValueDictionary objectForKey:@"key"]];
			}
		else
			{
			[theInputsDictionary setValue:theValueDictionary forKey:[theValueDictionary objectForKey:@"key"]];
			}
		}
		
	[nodesList addObject:theFilterDictionary];
	[nodes setObject:theFilter forKey:theKey];
	}
}

- (NSMutableDictionary *)processValue:(NSXMLElement *)inElement
{
// Every value needs a type and a key...
NSString *theType = [inElement name];
NSString *theKey = [[inElement attributeForName:@"key"] stringValue];

NSMutableDictionary *theValueDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
	theKey, @"key",
	theType, @"type",
	NULL];

if ([inElement attributeForName:@"ref"])
	{
	[theValueDictionary setObject:[[inElement attributeForName:@"ref"] stringValue] forKey:@"ref"];
	}
else 
	{
	if ([theType isEqual:@"float"])
		{
		id theValue = [NSNumber numberWithFloat:[[inElement stringValue] floatValue]];
		[theValueDictionary setObject:theValue forKey:@"value"];
		}
	else if ([theType isEqual:@"vector"])
		{
//		<vector key="inputTopLeft">
//			<float>302.885</float>
//			<float>644.712</float>
//		</vector>
		NSError *theError = NULL;
		NSArray *theFloatElements = [inElement nodesForXPath:@"float" error:&theError];
		float X = 0.0;
		if ([theFloatElements count] >= 1)
			X = [[[theFloatElements objectAtIndex:0] stringValue] floatValue];
		float Y = 0.0;
		if ([theFloatElements count] >= 2)
			Y = [[[theFloatElements objectAtIndex:1] stringValue] floatValue];
		float Z = 0.0;
		if ([theFloatElements count] >= 3)
			Z = [[[theFloatElements objectAtIndex:2] stringValue] floatValue];
		float W = 0.0;
		if ([theFloatElements count] >= 4)
			W = [[[theFloatElements objectAtIndex:3] stringValue] floatValue];

		CIVector *theValue = [[[CIVector alloc] initWithX:X Y:Y Z:Z W:W] autorelease];
		[theValueDictionary setObject:theValue forKey:@"value"];
		}
	else if ([theType isEqual:@"color"])
		{
		NSError *theError = NULL;
		NSArray *theFloatElements = [inElement nodesForXPath:@"float" error:&theError];
		float R = 0.0;
		if ([theFloatElements count] >= 1)
			R = [[[theFloatElements objectAtIndex:0] stringValue] floatValue];
		float G = 0.0;
		if ([theFloatElements count] >= 2)
			G = [[[theFloatElements objectAtIndex:1] stringValue] floatValue];
		float B = 0.0;
		if ([theFloatElements count] >= 3)
			B = [[[theFloatElements objectAtIndex:2] stringValue] floatValue];
		float A = 0.0;
		if ([theFloatElements count] >= 4)
			A = [[[theFloatElements objectAtIndex:3] stringValue] floatValue];

		CIColor *theValue = [CIColor colorWithRed:R green:G blue:B alpha:A];
		[theValueDictionary setObject:theValue forKey:@"value"];
		}
	}

return(theValueDictionary);
}



@end
