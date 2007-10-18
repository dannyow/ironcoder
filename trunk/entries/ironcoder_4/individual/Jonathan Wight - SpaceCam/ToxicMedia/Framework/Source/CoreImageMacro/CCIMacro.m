//
//  CCIMacro.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/27/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CCIMacro.h"

#import <QuartzCore/QuartzCore.h>

#import "CIImage_Extensions.h"

@implementation CCIMacro

+ (void)initialize
{
NSDictionary *theFilterAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
	@"CCIMacro", kCIAttributeFilterDisplayName,
	NULL];

[CIFilter registerFilterName:@"CCIMacro" constructor:self classAttributes:theFilterAttributes];
}

+ (CIFilter *)filterWithName: (NSString *)name
{
#pragma unused (name)
return([[[self alloc] init] autorelease]);
}

- (id)init
{
if ((self = [super init]) != NULL)
	{
	}
return(self);
}

- (void)dealloc
{
[inputs autorelease];
inputs = NULL;

[outputs autorelease];
outputs = NULL;

[nodesList autorelease];
outputs = NULL;

[nodes autorelease];
nodes = NULL;
//
[super dealloc];
}

#pragma mark -

- (NSArray *)inputKeys
{
return([inputs allKeys]);
}

- (NSArray *)outputKeys
{
return([outputs allKeys]);
}

#pragma mark -

- (void)updateOutputs
{
inputsChanged = NO;

NSEnumerator *thenodesListEnumerator = [nodesList objectEnumerator];
NSMutableDictionary *thenodesListDictionary = NULL;
while ((thenodesListDictionary = [thenodesListEnumerator nextObject]) != NULL)
	{
	CIFilter *thenodesList = [thenodesListDictionary objectForKey:@"filter"];
	NSEnumerator *theInputEnumerator = [[thenodesListDictionary objectForKey:@"inputs"] objectEnumerator];
	NSMutableDictionary *theInputDictionary = NULL;
	while ((theInputDictionary = [theInputEnumerator nextObject]) != NULL)
		{
		id theValue = [self valueForKeyPath:[theInputDictionary objectForKey:@"ref"]];
		[thenodesList setValue:theValue forKey:[theInputDictionary objectForKey:@"key"]];
		}
	}
}

#pragma mark -

- (BOOL)dryrun
{
CIImage *theImage = [CIImage placeholderImage];
[self setValue:theImage forKey:@"inputImage"];

return(YES);
}

#pragma mark -

- (CIImage *)outputImage
{
CIImage *theOutputImage = [self valueForUndefinedKey:@"outputImage"];
return(theOutputImage);
}

- (id)valueForUndefinedKey:(NSString *)inKey
{
if (inputsChanged == YES)
	[self updateOutputs];
	
id theValue = NULL;

theValue = [[inputs objectForKey:inKey] objectForKey:@"value"];
if (theValue != NULL)
	return(theValue);

if ([outputs objectForKey:inKey] != NULL)
	{
	NSMutableDictionary *theOutputDictionary = [outputs objectForKey:inKey];
	theValue = [theOutputDictionary objectForKey:@"value"];
	if (theValue != NULL)
		return(theValue);
		
	NSString *theReference = [theOutputDictionary objectForKey:@"ref"];	
	if (theReference != NULL)
		{
		theValue = [self valueForKeyPath:theReference];
		if (theValue != NULL)
			return(theValue);
		}
	}

theValue = [nodes valueForKey:inKey];
if (theValue != NULL)
	return(theValue);

return(NULL);
}

- (void)setValue:(id)inValue forUndefinedKey:(NSString *)inKey
{
NSMutableDictionary *theInputDictionary = [inputs objectForKey:inKey];
[theInputDictionary setObject:inValue forKey:@"value"];
inputsChanged = YES;
}

@end
