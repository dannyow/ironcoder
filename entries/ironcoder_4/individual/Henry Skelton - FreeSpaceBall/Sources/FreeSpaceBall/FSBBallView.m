//
//  FSBBallView.m
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 Henry Skelton. All rights reserved.
//

#import "FSBBallView.h"

@implementation FSBBallView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
	{
        ballImage = [[CIImage imageWithContentsOfURL: [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"ball" ofType: @"png"]]] retain];
		outlineImage = [[CIImage imageWithContentsOfURL: [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource: @"outline" ofType: @"png"]]] retain];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryUsageChanged:) name:@"MemoryUsageChanged" object:nil];
	
		draws = 0;
    }
    return self;
}

- (void)drawRect:(NSRect)rect 
{
	CGRect ballRect;
	CGSize ballRectSize;
	double usedMemory;
	double totalMemory;
	usedMemory = [[FSBAppController theController] usedMemory];
	totalMemory = [[FSBAppController theController] totalMemory];
	double lastChange = [[FSBAppController theController] lastChange];
	CIContext* context = [[NSGraphicsContext currentContext] CIContext];
	[context drawImage:  outlineImage
							inRect: NSRectToCGRect(rect)
						  fromRect: [outlineImage extent]];
	
	//ballRectSize.width = ((usedMemory/totalMemory) * rect.size.width);
	//ballRectSize.height = ((usedMemory/totalMemory) * rect.size.height);
	
	if (firstDraw)
	{
		ballRectSize.width = rect.size.width;
		ballRectSize.height = rect.size.height;
	}
	else
	{
		ballRectSize.width = 2*((rect.size.width/2)*sqrtf(usedMemory/totalMemory));
		ballRectSize.height = 2*((rect.size.height/2)*sqrtf(usedMemory/totalMemory));
			
	}
		
	ballRect.size = ballRectSize;
	ballRect.origin = CGPointMake ((rect.size.width/2)-(ballRect.size.width/2), (rect.size.height/2)-(ballRect.size.width/2) );
			
	ballImageFilter = [[CIFilter filterWithName: @"CIBumpDistortion"
								  keysAndValues: 
		@"inputImage", ballImage, 
		@"inputRadius", [NSNumber numberWithFloat: ((abs(lastChange) * 10) * 100.0)],
		@"inputScale", [NSNumber numberWithFloat: -0.5],
		@"inputCenter", [CIVector vectorWithX: [ballImage extent].size.width/2 Y: [ballImage extent].size.height/2],
		nil] retain];	
	
	
	[context drawImage: [ballImageFilter valueForKey:@"outputImage"]
				inRect: ballRect
			  fromRect: [ballImage extent]];
	
	if (draws > 3)
	{
		NSString* percentToDraw; 
		double percent = (usedMemory/totalMemory)*100;
		percentToDraw = [NSString stringWithFormat:@"%d%%", [[NSNumber numberWithDouble:percent] intValue]];
		[percentToDraw drawAtPoint: NSMakePoint (80, 80) withAttributes: [[NSDictionary alloc] initWithObjectsAndKeys: [NSFont fontWithName: @"Helvetica" size: 40.0], NSFontAttributeName, nil]];
		
	}
	
	firstDraw = NO;
	draws++;
}

- (void)memoryUsageChanged:(NSNotification *)notification
{
	[self setNeedsDisplay:YES];
}

@end
