//
//  ControllerView.m
//  BlurredLife
//
//  Created by Adam Leonard on 3/31/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ControllerView.h"


@implementation ControllerView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
	{
       _selectedOption = @"life";
    }
    return self;
}

- (void)drawRect:(NSRect)rect 
{
	//fill with a dark color
	[[NSColor colorWithCalibratedWhite:0.25 alpha:1.0]set];
    [NSBezierPath fillRect:rect];
	
	
	NSFont *lifeNotLifeFont = [NSFont boldSystemFontOfSize:50.0];
	
	NSColor *color = [NSColor whiteColor];
	
	NSNumber *baselineOffset = [NSNumber numberWithFloat:35.0]; //that should about center it vertically
	
	NSShadow *shadow = [[[NSShadow alloc]init]autorelease];
	[shadow setShadowOffset:NSMakeSize(2.0,-2.0)];
	[shadow setShadowBlurRadius:1.5];
	[shadow setShadowColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.6]];
	
	NSMutableDictionary *lifeNotLifeAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys:lifeNotLifeFont,NSFontAttributeName,color,NSForegroundColorAttributeName,baselineOffset,NSBaselineOffsetAttributeName,shadow,NSShadowAttributeName,nil];
	
	NSMutableDictionary *pointsTitleAttributes = [[lifeNotLifeAttributes mutableCopy]autorelease];
	NSFont *pointsTitleFont = [NSFont boldSystemFontOfSize:25.0];
	[pointsTitleAttributes setObject:pointsTitleFont forKey:NSFontAttributeName];
	
	NSMutableDictionary *pointsAttributes = [[pointsTitleAttributes mutableCopy]autorelease];
	NSFont *pointsFont = [NSFont boldSystemFontOfSize:30.0];
	[pointsAttributes setObject:pointsFont forKey:NSFontAttributeName];
	
	
	float horizontalSpaceNeededForLifeText = [@"Life" sizeWithAttributes:lifeNotLifeAttributes].width;
	float horizontalSpaceNeededForNotLifeText = [@"Not Life" sizeWithAttributes:lifeNotLifeAttributes].width;
		
	//yay more ScreenSaver stuff!
	NSRect lifeNotLifeSelectionRect = SSCenteredRectInRect(NSMakeRect(0,0,horizontalSpaceNeededForLifeText + horizontalSpaceNeededForNotLifeText,rect.size.height),rect);
	
	NSRect lifeRect = NSIntegralRect(NSMakeRect(lifeNotLifeSelectionRect.origin.x,lifeNotLifeSelectionRect.origin.y,horizontalSpaceNeededForLifeText,lifeNotLifeSelectionRect.size.height));
	NSRect notLifeRect = NSIntegralRect(NSMakeRect(lifeNotLifeSelectionRect.origin.x + horizontalSpaceNeededForNotLifeText,lifeNotLifeSelectionRect.origin.y,horizontalSpaceNeededForNotLifeText,lifeNotLifeSelectionRect.size.height));
	
	
	[@"Life" drawAtPoint:lifeRect.origin withAttributes:lifeNotLifeAttributes];
	[@"Not Life" drawAtPoint:notLifeRect.origin withAttributes:lifeNotLifeAttributes];
	
	
	//draw "Points" at the top half of the rect on the left side
	[@"Points:" drawAtPoint:NSMakePoint(rect.origin.x + 10.0, (rect.size.height / 2.0) - 10.0) withAttributes:pointsTitleAttributes];
	
	//draw "Total" at the top half of the rect on the right side with the same attributes
	NSString *totalPointsAsString = [[NSNumber numberWithInt:[self totalPoints]]stringValue];
	float horizontalSpaceNeededForTotalPoints = [totalPointsAsString sizeWithAttributes:pointsAttributes].width; 
	float horizontalSpaceNeededForTotalPointsTitle;
	if(horizontalSpaceNeededForTotalPoints < [@"Total:" sizeWithAttributes:pointsTitleAttributes].width)
	{
		//if the title requires more space than the points, use the space needed for the title 
		horizontalSpaceNeededForTotalPointsTitle = [@"Total:" sizeWithAttributes:pointsTitleAttributes].width;
		horizontalSpaceNeededForTotalPoints = horizontalSpaceNeededForTotalPointsTitle; //move the points over to line up
	}
	else
	{
		//otherwise, align the title to the left side of where the points will be drawn
		horizontalSpaceNeededForTotalPointsTitle = horizontalSpaceNeededForTotalPoints;
	}
	[@"Total:" drawAtPoint:NSMakePoint(rect.size.width - horizontalSpaceNeededForTotalPointsTitle - 20.0, (rect.size.height / 2.0) - 10.0)  withAttributes:pointsTitleAttributes];
	
	
	//draw the picture points below the title ("Points")
	[[[NSNumber numberWithInt:[self picturePoints]]stringValue]drawAtPoint:NSMakePoint(rect.origin.x + 10.0, rect.origin.y + 10.0) withAttributes:pointsAttributes];
	
	//draw the total points below its title ("Total") with the same attributes
	[totalPointsAsString drawAtPoint:NSMakePoint(rect.size.width - horizontalSpaceNeededForTotalPoints - 20.0,rect.origin.y + 10.0) withAttributes:pointsAttributes];


	//draw the selection rect around the option that should be selected
	NSRect selectionRect;
	if([[self selectedOption]isEqualToString:@"life"])
	   selectionRect = lifeRect;
	else if([[self selectedOption]isEqualToString:@"notLife"])
		selectionRect = notLifeRect;
	
	selectionRect = NSMakeRect(selectionRect.origin.x - 10.0,selectionRect.origin.y + 20.0,selectionRect.size.width + 20.0, selectionRect.size.height - 40.0); //add a little padding to the left and right and take away some padding from the top and bottom
	
	NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
	[selectionPath setLineCapStyle:NSRoundLineCapStyle];
	[selectionPath setLineJoinStyle:NSRoundLineJoinStyle];
	[selectionPath setLineWidth:5.0];
	
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.75]set];
	[selectionPath stroke];
	
}

- (void)selectNextOption; //if life was selected, not life becomes selected, and vise versa
{
	if([[self selectedOption]isEqualToString:@"life"])
		_selectedOption = @"notLife";
	else if([[self selectedOption]isEqualToString:@"notLife"])
		_selectedOption = @"life";
	
	[self setNeedsDisplay:YES];
}
- (NSString *)selectedOption; //either @"life" or @"notLife"
{
	return _selectedOption;
}


- (int)picturePoints
{
    return picturePoints;
}
- (void)setPicturePoints:(int)aPicturePoints
{
    picturePoints = aPicturePoints;
	[self setNeedsDisplay:YES];
}

- (int)totalPoints
{
    return totalPoints;
}
- (void)setTotalPoints:(int)aTotalPoints
{
    totalPoints = aTotalPoints;
	[self setNeedsDisplay:YES];
}



@end
