//
//  Geometry.m
//  SimpleSequenceGrabber
//
//  Created by Jonathan Wight on 10/15/2005.
//  Copyright 2005 Toxic Software. All rights reserved.
//

#import "Geometry.h"

NSRect ScaleImageRectToRect(NSRect inImageRect, NSRect inDestinationRect, NSImageScaling inScaling, NSImageAlignment inAlignment)
{
NSRect theScaledImageRect;

if (inScaling == NSScaleToFit)
	{
	theScaledImageRect.origin = NSZeroPoint;
	theScaledImageRect.size = inDestinationRect.size;
	}
else
	{
	NSSize theScaledImageSize = inImageRect.size;

	if (inScaling == NSScaleProportionally)
		{
		float theScaleFactor = 1.0f;
		if (inDestinationRect.size.width / inImageRect.size.width < inDestinationRect.size.height / inImageRect.size.height)
			{
			theScaleFactor = inDestinationRect.size.width / inImageRect.size.width;
			}
		else
			{
			theScaleFactor = inDestinationRect.size.height / inImageRect.size.height;
			}
		theScaledImageSize.width *= theScaleFactor;
		theScaledImageSize.height *= theScaleFactor;
		
		theScaledImageRect.size = theScaledImageSize;
		}
	else if (inScaling == NSScaleNone)
		{
		theScaledImageRect.size.width = theScaledImageSize.width;
		theScaledImageRect.size.height = theScaledImageSize.height;
		}
	//
	if (inAlignment == NSImageAlignCenter)
		{
		theScaledImageRect.origin.x = inDestinationRect.origin.x + (inDestinationRect.size.width - theScaledImageSize.width) / 2.0f;
		theScaledImageRect.origin.y = inDestinationRect.origin.y + (inDestinationRect.size.height - theScaledImageSize.height) / 2.0f;
		}
	else if (inAlignment == NSImageAlignTop)
		{
		theScaledImageRect.origin.x = inDestinationRect.origin.x + (inDestinationRect.size.width - theScaledImageSize.width) / 2.0f;
		theScaledImageRect.origin.y = inDestinationRect.origin.y + inDestinationRect.size.height - theScaledImageSize.height;
		}
	else if (inAlignment == NSImageAlignTopLeft)
		{
		theScaledImageRect.origin.x = 0.0f;
		theScaledImageRect.origin.y = inDestinationRect.origin.y + inDestinationRect.size.height - theScaledImageSize.height;
		}
	else if (inAlignment == NSImageAlignTopRight)
		{
		theScaledImageRect.origin.x = inDestinationRect.origin.x + inDestinationRect.size.width - theScaledImageSize.width;
		theScaledImageRect.origin.y = inDestinationRect.origin.y + inDestinationRect.size.height - theScaledImageSize.height;
		}
	else if (inAlignment == NSImageAlignLeft)
		{
		theScaledImageRect.origin.x = 0.0f;
		theScaledImageRect.origin.y = inDestinationRect.origin.y + (inDestinationRect.size.height - theScaledImageSize.height) / 2.0f;
		}
	else if (inAlignment == NSImageAlignBottom)
		{
		theScaledImageRect.origin.x = inDestinationRect.origin.x + (inDestinationRect.size.width - theScaledImageSize.width) / 2.0f;
		theScaledImageRect.origin.y = 0.0f;
		}
	else if (inAlignment == NSImageAlignBottomLeft)
		{
		theScaledImageRect.origin.x = 0.0f;
		theScaledImageRect.origin.y = 0.0f;
		}
	else if (inAlignment == NSImageAlignBottomRight)
		{
		theScaledImageRect.origin.x = inDestinationRect.origin.x + inDestinationRect.size.width - theScaledImageSize.width;
		theScaledImageRect.origin.y = 0.0f;
		}
	else if (inAlignment == NSImageAlignRight)
		{
		theScaledImageRect.origin.x = inDestinationRect.origin.x + inDestinationRect.size.width - theScaledImageSize.width;
		theScaledImageRect.origin.y = inDestinationRect.origin.y + (inDestinationRect.size.height - theScaledImageSize.height) / 2.0f;
		}
	}
return(theScaledImageRect);
}

NSString *NSStringFromCarbonRect(Rect inRect)
{
return(NSStringFromRect(NSRectFromCarbonRect(inRect)));
}