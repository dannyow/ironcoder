#import "TimeGraphView.h"
#import "LinenPatternDrawing.h"
#import "DenimPatternDrawing.h"

const float kGraphTopMargin = 20.0;
const float kGraphBottomMargin = 20.0;
const float kGraphRightMargin = 20.0;
const float kGraphLeftMargin = 20.0;
const float kGraphInterMargin = 10.0;

// Map constants to UI names 
static NSString* kDenimPatternName = @"Denim";
static NSString* kLinenPatternName = @"Linen";
static NSString* kPlaidPatternName = @"Plaid";
static NSString* kG5VentPatternName = @"Power Mac";
static NSString* kTableClothPatternName = @"Picnic";
static NSString* kDCJOfficeCarpetPatternName = @"My Office Carpet";

// Defaults key
static NSString* kSavedPatternKey = @"kSavedPatternKey";

@interface TimeGraphView (PrivateMethods)
- (NSTimeInterval) longestTime;
- (NSArray*) itemKeysSortedForDisplay;
- (NSArray*) keysForItemsExceedingTimeThreshold:(float)percentValue;
@end

@implementation TimeGraphView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil)
	{
		// Default to plaid
		NSString* savedPattern = [[NSUserDefaults standardUserDefaults] valueForKey:kSavedPatternKey];
		if (savedPattern == nil) savedPattern = kPlaidPatternName;
		[self setGraphPattern:savedPattern];
		
		// Start out with no graph data
		[self setNamedTimeIntervals:[NSDictionary dictionary]];
		
		// Show everything
		mShowsBarelyUsedApplications = YES;
	}
	return self;
}

- (BOOL) isOpaque
{
	return NO;
}

- (void)drawRect:(NSRect)rect
{
    CGContextRef gc = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect targetRect = *(CGRect *)(&rect);
	
	// Clear the background to a nice transparent black
    CGContextSetRGBFillColor(gc, 0, 0, 0, 0.45);
	CGContextFillRect(gc, targetRect);

	// Figure the portion of our view we can actually draw a graph in
	float graphHeight = [self frame].size.height - kGraphTopMargin - kGraphBottomMargin;
	float graphWidth = [self frame].size.width - kGraphRightMargin - kGraphLeftMargin;

	// Figure the number of divisions to compute bar real estate
	NSArray* drawableTimes = [self itemKeysSortedForDisplay];
	float barHeight = graphHeight;
	int graphDivisions = [drawableTimes count];
	if (graphDivisions > 1)
	{
		barHeight = (graphHeight - ((graphDivisions - 1) * kGraphInterMargin)) / graphDivisions;
	}
	
	// To gauge the bar width, we need to konw the minimum and maximum times represented
	NSTimeInterval barWidthScale = [self longestTime];

	// If graph divisions is one or less, then give the user a hint about how to use the app
	if (graphDivisions <= 1)
	{
		NSMutableParagraphStyle* centeredStyle = [[NSMutableParagraphStyle alloc] init];
		[centeredStyle setAlignment:NSCenterTextAlignment];
		
		NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor yellowColor], NSForegroundColorAttributeName, 
																			[NSFont fontWithName:@"Lucida Grande" size:12.0], NSFontAttributeName,
																			centeredStyle , NSParagraphStyleAttributeName,
																			nil];														
		[centeredStyle release];
		
		NSAttributedString* thisAttrString = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Hint: Try switching between apps to see what all the fuss is about.", nil)  attributes:attributes];		
		NSRect nameRect = NSMakeRect(kGraphLeftMargin, 2.0, graphWidth, 20.0);
		[thisAttrString drawInRect:nameRect];
	}

	// Now draw a graph element for each of our items
	float thisBarVertOffset = kGraphBottomMargin;
	float eachBarVertOffset = barHeight + kGraphInterMargin;
	NSEnumerator* itemEnum = [drawableTimes reverseObjectEnumerator];	// reverse because we draw from bottom to top
	NSString* thisName = nil;
	while (thisName = [itemEnum nextObject])
	{
		// the total area into which this item's info may draw
		NSRect targetRect = NSMakeRect(kGraphLeftMargin, thisBarVertOffset, graphWidth, barHeight);
		
		// Plot the name of this item just below the bar
		NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, 
																			[NSFont fontWithName:@"Lucida Grande" size:targetRect.size.height / 4], NSFontAttributeName,
																			nil];
		NSAttributedString* thisAttrString = [[NSAttributedString alloc] initWithString:thisName attributes:attributes];
		NSRect nameRect = targetRect;
		nameRect.size = [thisAttrString size];
		[thisAttrString drawInRect:nameRect];
		
		NSRect barRect = nameRect;
		barRect.origin.y += nameRect.size.height;
		barRect.size.height = targetRect.size.height - nameRect.size.height;
		
		// the width of a bar is its value in proportion to the scale
		barRect.size.width = targetRect.size.width;
		if (barWidthScale != 0)
		{
			NSNumber* thisTimeValue = [mNamedTimeIntervals objectForKey:thisName];
			barRect.size.width *= [thisTimeValue doubleValue] / barWidthScale;
		}

		// Draw a nifty patterened bar graph with CG
		// Use a pattern specified by string 
		if ([mGraphPattern isEqualToString:kDenimPatternName])
		{
			FillRectWithDenimPattern(gc, *(CGRect*)&barRect);
		}
		else if ([mGraphPattern isEqualToString:kLinenPatternName])
		{
			NSColor* baseColor = [[NSColor orangeColor] shadowWithLevel:0.2];
			float colorComps[4] = {[baseColor redComponent], [baseColor greenComponent], [baseColor blueComponent], 0.8};
			CGColorSpaceRef genericRGBSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
			if (genericRGBSpace != NULL)
			{
				CGColorRef thisBarColor = CGColorCreate(genericRGBSpace, colorComps);
				if (thisBarColor != NULL)
				{
					CGContextSetStrokeColorWithColor(gc, thisBarColor);					
					FillRectWithLinenPattern(gc, *(CGRect*)&barRect, thisBarColor);
					CGColorRelease(thisBarColor);
				}
				CGColorSpaceRelease(genericRGBSpace);
			}
		}
		else if ([mGraphPattern isEqualToString:kPlaidPatternName])
		{
			FillRectWithPlaidPattern(gc, *(CGRect*)&barRect);
		}
		else if ([mGraphPattern isEqualToString:kG5VentPatternName])
		{
			FillRectWithG5VentPattern(gc, *(CGRect*)&barRect);
		}
		else if ([mGraphPattern isEqualToString:kTableClothPatternName])
		{
			FillRectWithTableClothPattern(gc, *(CGRect*)&barRect);
		}
		else if ([mGraphPattern isEqualToString:kDCJOfficeCarpetPatternName])
		{
			FillRectWithDCJOfficeCarpetPattern(gc, *(CGRect*)&barRect);
		}
		
		// Advance ...
		thisBarVertOffset += eachBarVertOffset;
	}	
}

//  namedTimeIntervals 
- (NSDictionary *) namedTimeIntervals
{
    return mNamedTimeIntervals; 
}

- (void) setNamedTimeIntervals: (NSDictionary *) theNamedTimeIntervals
{
    if (mNamedTimeIntervals != theNamedTimeIntervals)
    {
        [mNamedTimeIntervals release];
        mNamedTimeIntervals = [theNamedTimeIntervals copy];
		
		[self setNeedsDisplay:YES];
    }
}

// Convenience method returns a sorted list of whatever items should be displayed now
- (NSArray*) itemKeysSortedForDisplay
{
	NSArray* displayedKeys = nil;
	if (mShowsBarelyUsedApplications == YES)
	{
		displayedKeys = [mNamedTimeIntervals allKeys];
	}
	else
	{
		// Cull the shorties - anything less than 5% of total time
		displayedKeys = [self keysForItemsExceedingTimeThreshold:0.05];
	}
	
	return [displayedKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

//  showsBarelyUsedApplications 
- (BOOL) showsBarelyUsedApplications
{
    return mShowsBarelyUsedApplications;
}

- (void) setShowsBarelyUsedApplications: (BOOL) flag
{
    mShowsBarelyUsedApplications = flag;
	
	[self setNeedsDisplay:YES];
}

- (NSArray*) graphPatterns
{
	NSArray* allPatterns = [NSArray arrayWithObjects:kDenimPatternName, kLinenPatternName, kTableClothPatternName, kPlaidPatternName, kG5VentPatternName, kDCJOfficeCarpetPatternName, nil];
	return [allPatterns sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

//  graphPattern 
- (NSString *) graphPattern
{
    return mGraphPattern; 
}

- (void) setGraphPattern: (NSString *) theGraphPattern
{
    if (mGraphPattern != theGraphPattern)
    {
        [mGraphPattern release];
        mGraphPattern = [theGraphPattern retain];
		
		// save to defaults 
		[[NSUserDefaults standardUserDefaults] setValue:mGraphPattern forKey:kSavedPatternKey];
    }
}

- (NSTimeInterval) longestTime
{	
	// Special case - if there are no items there is no time interval
	if ([[self namedTimeIntervals] count] == 0)
	{
		return 0.0;
	}
	
	NSTimeInterval longTime = 0.0;
	NSEnumerator* timeEnum = [[[self namedTimeIntervals] allValues] objectEnumerator];
	NSNumber* thisNumber;
	while (thisNumber = [timeEnum nextObject])
	{
		NSTimeInterval thisInterval = [thisNumber doubleValue];
		if (thisInterval > longTime) longTime = thisInterval;
	}
	return longTime;
}

- (NSArray*) keysForItemsExceedingTimeThreshold:(float)percentValue
{
	// We use the longest time as the comparison for threshold
	NSTimeInterval thresholdStandard = [self longestTime];
	
	NSMutableArray* passedKeys = [NSMutableArray array];
	NSEnumerator* keyEnum = [[mNamedTimeIntervals allKeys] objectEnumerator];
	id thisKey = nil;
	while (thisKey = [keyEnum nextObject])
	{
		NSTimeInterval thisTime = [[mNamedTimeIntervals objectForKey:thisKey] doubleValue];

		// If the item's time exceeds the designated percent threshold, we keep it
		if ((thisTime / thresholdStandard) > percentValue)
		{
			[passedKeys addObject:thisKey];
		}
	}
	
	return passedKeys;
}

@end