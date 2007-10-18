//
//  CGenericCIFilter.h
//  MotionDetector
//
//  Created by Jonathan Wight on 08/18/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

// Thanks to Jens Barth for contributions to this class.

#import <QuartzCore/QuartzCore.h>

/**
 * @class CGenericCIFilter
 * @discussion This class allows you to create Core Image filters with a custom kernel without having to create a seperate plug-in or subclass anything. The Core Image kernel is just another attribute of the filter object.
 */
@interface CGenericCIFilter : CIFilter {
	NSString *inputKernel;
	NSArray *inputKernelParameterNames;
	NSMutableArray *kernelParameters;
	NSDictionary *kernelOptions;
	
	CIKernel *compiledInputKernel;
}

- (NSString *)inputKernel;
- (void)setInputKernel:(NSString *)inInputKernel;

- (NSArray *)inputKernelParameterNames;
- (void)setInputKernelParameterNames:(NSArray *)inInputKernelParameterNames;

- (NSDictionary *)kernelOptions;
- (void)setKernelOptions:(NSDictionary *)inKernelOptions;

- (CIKernel *)compiledInputKernel;

@end
