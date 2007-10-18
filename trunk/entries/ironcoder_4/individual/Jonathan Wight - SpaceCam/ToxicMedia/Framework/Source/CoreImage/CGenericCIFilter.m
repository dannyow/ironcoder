//
//  CGenericCIFilter.m
//  MotionDetector
//
//  Created by Jonathan Wight on 08/18/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "CGenericCIFilter.h"

@implementation CGenericCIFilter

+ (void)initialize
{
NSDictionary *theFilterAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
	@"GenericFilter", kCIAttributeFilterDisplayName,
	NULL];

[CIFilter registerFilterName:@"GenericFilter" constructor:self classAttributes:theFilterAttributes];
}

+ (CIFilter *)filterWithName: (NSString *)name
{
#pragma unused (name)
return([[[self alloc] init] autorelease]);
}

#pragma mark -

- (id)init
{
if ((self = [super init]) != NULL)
	{
	[self setInputKernel:NULL];
	[self setKernelOptions:NULL];
	}
return(self);
}

- (void)dealloc
{
[self setInputKernel:NULL];

[self setInputKernelParameterNames:NULL];

[kernelParameters release];
kernelParameters = NULL;
//
[self setKernelOptions:NULL];
//
[super dealloc];
}

#pragma mark -

- (NSString *)inputKernel
{
return(inputKernel);
}

- (void)setInputKernel:(NSString *)inInputKernel
{
if (inputKernel != inInputKernel)
	{
	[inputKernel autorelease];
	inputKernel = [inInputKernel retain];
	//
	[compiledInputKernel autorelease];
	compiledInputKernel = NULL;
	}
}

- (NSArray *)inputKernelParameterNames
{
return(inputKernelParameterNames);
}

- (void)setInputKernelParameterNames:(NSArray *)inInputKernelParameterNames
{
if (inputKernelParameterNames != inInputKernelParameterNames)
	{
	[inputKernelParameterNames autorelease];
	inputKernelParameterNames = [inInputKernelParameterNames retain];

	[kernelParameters autorelease];
	kernelParameters = NULL;
	if (inputKernelParameterNames != NULL)
		{
		kernelParameters = [[NSMutableArray alloc] initWithCapacity:[inInputKernelParameterNames count]];
		unsigned int N;
		for (N = 0; N != [inInputKernelParameterNames count]; ++N)
			{
			[kernelParameters addObject:[NSNull null]];
			}
		}
	}
}

- (NSDictionary *)kernelOptions
{
return(kernelOptions);
}

- (void)setKernelOptions:(NSDictionary *)inKernelOptions
{
if (kernelOptions != inKernelOptions)
	{
	[kernelOptions autorelease];
	kernelOptions = [inKernelOptions retain];
	}
}

- (CIKernel *)compiledInputKernel
{
if (compiledInputKernel == NULL)
	{
	if ([self inputKernel] != NULL)
		{
		// Why an array? I don't know...
		NSArray *theKernels = [CIKernel kernelsWithString:[self inputKernel]];
		if ([theKernels count] > 0)
			compiledInputKernel = [[theKernels objectAtIndex:0] retain];
		}
	}
return(compiledInputKernel);
}

#pragma mark -

- (id)valueForUndefinedKey:(NSString *)inKey
{
const unsigned theIndex = [inputKernelParameterNames indexOfObject:inKey];
return([kernelParameters objectAtIndex:theIndex]);
}

- (void)setValue:(id)inValue forUndefinedKey:(NSString *)inKey
{
const unsigned theIndex = [inputKernelParameterNames indexOfObject:inKey];

id theValue = inValue;
if ([[inValue class] isSubclassOfClass:[CIImage class]])
	{
	theValue = [CISampler samplerWithImage:theValue];
	}
[kernelParameters replaceObjectAtIndex:theIndex withObject:theValue];
}

#pragma mark -

- (CIImage *)outputImage
{
//NSDictionary *theOptions = [NSDictionary dictionaryWithObjectsAndKeys:
//	NULL];
//extern NSString *kCIApplyOptionExtent AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
//extern NSString *kCIApplyOptionDefinition AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;
//extern NSString *kCIApplyOptionUserInfo AVAILABLE_MAC_OS_X_VERSION_10_4_AND_LATER;

CIImage *theOutputImage = NULL;
CIKernel *theKernel = [self compiledInputKernel];
if (theKernel != NULL)
	{
	@try
		{
		NSLog(@"APPLY %@", kernelParameters);
		theOutputImage = [self apply:theKernel arguments:kernelParameters options:[self kernelOptions]];
		}
	@catch (NSException *localException)
		{
		NSLog(@"Exception occured! %@", localException);
		}
	@finally
		{
		}
	}

return(theOutputImage);
}

@end

