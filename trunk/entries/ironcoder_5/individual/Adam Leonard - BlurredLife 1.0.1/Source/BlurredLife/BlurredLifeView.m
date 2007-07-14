//
//  BlurredLifeView.m
//  BlurredLife
//
//  Created by Adam Leonard on 3/30/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import "BlurredLifeView.h"
#import "FlickrParser.h"
#import "ALImageView.h"
#import "ControllerView.h"

#define ARCHETECTURE_GROUP_ID @"65703306@N00"
#define PORTRAIT_GROUP_ID @"52239745968@N01"
#define FACES_GROUP_ID @"98888485@N00"

#define FILTER_INTERVAL_PER_FRAME 0.75
#define INITIAL_FILTER_VALUE 50.0

#define TRANSITION_DURATION 1.0
#define DELAY_BEFORE_TRANSITION 2.0

#define INITIAL_POINTS_PER_PICTURE 1000
#define POINT_PENALTY_FOR_WRONG_ANSWER 1000

@implementation BlurredLifeView

static NSString * const moduleName = @"com.caffeinatedcocoa.blurredLife";

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self)
	{
        [self setAnimationTimeInterval:1/15.0];
		
		ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:moduleName];
		[defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:@"gaussianBlur",@"effect",[NSNumber numberWithBool:NO],@"sepiaTone",[NSNumber numberWithInt:0],@"highScore",nil]];
		
		NSRect imageViewRect;
		imageViewRect = NSMakeRect(frame.origin.x + 50.0,frame.origin.y + 150.0,frame.size.width - 100.0,frame.size.height - 200.0); //make sure there is space to the left and right of the image, and extra space at the bottom for the controls
		
		if(isPreview)
			imageViewRect = [self bounds]; //if it is a preview, give it all the possible space to work.
		
		imageView = [[ALImageView alloc]initWithFrame:imageViewRect];
		[self addSubview:imageView];
		
		if(!isPreview) //don't show the controller
		{
			NSRect controllerViewRect = NSMakeRect(frame.origin.x,frame.origin.y,frame.size.width,100.0); //bottom 100 px
			controllerView = [[ControllerView alloc]initWithFrame:controllerViewRect];
			[controllerView setTotalPoints:0];
			[self addSubview:controllerView];
		
			[self setAutoresizesSubviews:YES];
		}
		
		shouldAnimateImage = NO;
		
		//just set up the animations early on so we can use them later
		fadeOutAnimation = [[NSViewAnimation alloc]initWithViewAnimations:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:imageView,NSViewAnimationTargetKey,NSViewAnimationFadeOutEffect,NSViewAnimationEffectKey,nil]]];
		[fadeOutAnimation setDelegate:self];
		[fadeOutAnimation setDuration:TRANSITION_DURATION];
		
		fadeInAnimation = [[NSViewAnimation alloc]initWithViewAnimations:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:imageView,NSViewAnimationTargetKey,NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,nil]]];
		[fadeInAnimation setDelegate:self];
		[fadeInAnimation setDuration:TRANSITION_DURATION];
		
		
		notAliveParser = [[FlickrParser alloc]initWithFlickrGroupID:ARCHETECTURE_GROUP_ID delegate:self];
		[notAliveParser retrievePhotoURLs];
		aliveParser = [[FlickrParser alloc]initWithFlickrGroupID:FACES_GROUP_ID delegate:self];
		[aliveParser retrievePhotoURLs];
		
    }
    return self;
}
-(void)flickrParser:(FlickrParser *)parser didFindPhotoURLs:(NSArray *)results;
{
	if(!results) //if there was an error or no photos were found
	{
		NSLog(@"***Could not get photo URLs! ***");
		[self stopAnimation]; //just quit
	}
	
	if(parser == notAliveParser)
		notAlivePhotoURLs = [results mutableCopy];
	else if(parser == aliveParser)
		alivePhotoURLs = [results mutableCopy];
	else
		return;
	
	if(notAlivePhotoURLs && alivePhotoURLs) //yay! we have all the URLs. Now download and show the first image
		[self showNextImage];
	
	[parser release];
}

- (void)animateOneFrame
{
	if(!shouldAnimateImage)
		return;
	
	if(currentFilterValue < minimumFilterValue) //the user took too much time
	{
		
		//fade out the imageView. We will fade it back in with the next image once the animation is done and the image is loaded
		//let the user see the final image for a moment before begining the transition
		[imageView setShouldShowBorder:YES];
		[fadeOutAnimation performSelector:@selector(startAnimation)
							   withObject:nil
							   afterDelay:DELAY_BEFORE_TRANSITION];
		
		shouldAnimateImage = NO;
		
		return;
	}
	
	//subtract the amount of points per frame needed to make the points equal 0 when the animation ends
	[controllerView setPicturePoints:(int)([controllerView picturePoints] - ((FILTER_INTERVAL_PER_FRAME * INITIAL_POINTS_PER_PICTURE) / INITIAL_FILTER_VALUE))];
	
	if([controllerView picturePoints] < 0)
		[controllerView setPicturePoints:0];
	
	currentFilterValue -= FILTER_INTERVAL_PER_FRAME;
	
	currentImageAsCIImage = [CIImage imageWithData:[currentImageAsNSImage TIFFRepresentation]]; //to CIImage
	if(!currentImageAsCIImage)
	{
		NSLog(@"***Could not create CIImage from NSImage data ***");
		return;
	}
	
	//apply the filter
	
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:moduleName];

	
	if([[defaults objectForKey:@"effect"]isEqualToString:@"pixellate"])
	{
		minimumFilterValue = 1.0;
		
		CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
		[pixellateFilter setValue:currentImageAsCIImage forKey:@"inputImage"];
		[pixellateFilter setValue:[CIVector vectorWithX:[currentImageAsNSImage size].width / 2  Y:[currentImageAsNSImage size].height / 2] forKey:@"inputCenter"];
		[pixellateFilter setValue:[NSNumber numberWithFloat:currentFilterValue] forKey:@"inputScale"];
	
		currentImageAsCIImage = [pixellateFilter valueForKey:@"outputImage"];
	}
	 
	
	else if([[defaults objectForKey:@"effect"]isEqualToString:@"gaussianBlur"])
	{
		minimumFilterValue = 0.0;
		
		CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
		[blurFilter setValue:currentImageAsCIImage forKey:@"inputImage"];
		[blurFilter setValue:[NSNumber numberWithFloat:currentFilterValue] forKey:@"inputRadius"];
	
		currentImageAsCIImage = [blurFilter valueForKey:@"outputImage"];
	}
	 
	if([[defaults objectForKey:@"sepiaTone"]boolValue] == YES)
	{
		if(currentFilterValue - FILTER_INTERVAL_PER_FRAME > minimumFilterValue)
		{
			CIFilter *sepiaToneFilter = [CIFilter filterWithName:@"CISepiaTone"];
			[sepiaToneFilter setValue:currentImageAsCIImage forKey:@"inputImage"];
			[sepiaToneFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputIntensity"];
	
			currentImageAsCIImage = [sepiaToneFilter valueForKey:@"outputImage"];
		}
	}
	
	
	
	//back to NSImage so we can use it in the ALImageView
	NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:currentImageAsCIImage];
	NSImage *newImageAsNSImage = [[NSImage alloc]init];
	[newImageAsNSImage addRepresentation:imageRep];
	NSImage *newImageAsNSImage2 = [[NSImage alloc]initWithData:[newImageAsNSImage TIFFRepresentation]];
	[newImageAsNSImage2 setScalesWhenResized:YES];
	[newImageAsNSImage2 setSize:[currentImageAsNSImage size]];
	
	
	[imageView setImage:newImageAsNSImage2];
	
	[newImageAsNSImage release];
	[newImageAsNSImage2 release];
}

- (void)animationDidEnd:(NSViewAnimation*)animation
{
	if(animation == fadeOutAnimation)
	{
		//if we were fading out, we download the new image
		[self showNextImage];
	}
	else if(animation == fadeInAnimation)
	{
		//if we were fading in, then we are ready to start animating again
		currentFilterValue = INITIAL_FILTER_VALUE;
		shouldAnimateImage = YES;
	}
}

- (void)showNextImage;
{
	shouldAnimateImage = NO; //not until we finish downloading
	
	if(currentImageAsNSImage)
	{
		[currentImageAsNSImage release];
		currentImageAsNSImage = nil;
	}
	
	//yay pointless ScreenSaver functions!
	//first decide if we will pick a URL from the living or nonliving arrays
	NSMutableArray *theURLArray;
	if(SSRandomIntBetween(0,1) == 0)
	{
		theURLArray = notAlivePhotoURLs;
		currentImageIsAlive = NO;
	}
	else
	{
		theURLArray = alivePhotoURLs;
		currentImageIsAlive = YES;
	}
	
	//now pick out an image to download
	
	if([theURLArray count] == 0)
		[self stopAnimation]; //maybe we have gone through all our images, so just quit
	
	int index = SSRandomIntBetween(0,[theURLArray count] - 1);
	NSURL *theURL = [theURLArray objectAtIndex:index];
	
	[NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:theURL] delegate:self]; //start the download
	
	[theURLArray removeObjectAtIndex:index]; //remove it from the array so we do not pick the same image twice
	
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	if(!currentImageData)
		currentImageData = [[NSMutableData alloc]init];
	
	[currentImageData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	currentImageAsNSImage = [[NSImage alloc]initWithData:currentImageData];
	
	[currentImageData release];
	currentImageData = nil; //get ready for the next image we download
	
	if(!currentImageAsNSImage)
	{
		NSLog(@"***Could not create image from data ***");
		return;
	}
	
	[imageView setShouldShowBorder:NO];
	
	//force the animation of a single frame so the new image will be displayed during the animation
	currentFilterValue = INITIAL_FILTER_VALUE;
	shouldAnimateImage = YES;
	[self animateOneFrame];
	shouldAnimateImage = NO;
	
	[controllerView setPicturePoints:INITIAL_POINTS_PER_PICTURE];
	
	//fade in the imageView
	[fadeInAnimation startAnimation];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
{
	NSLog(@"***Could not download image due to error: %@ ***",error);
	[currentImageData release];
	currentImageData = nil;
	
	[self showNextImage];
	
}

-(void)keyDown:(NSEvent *)theEvent
{
	BOOL hasHandledEvent = NO;
	
	if(!shouldAnimateImage)
	{
		//if we are not showing an image, dont let the user change anything (but still capture the event)
		hasHandledEvent = YES;
	}
	else if([[theEvent charactersIgnoringModifiers]isEqualToString:@" "])//space key
	{
		if(([[controllerView selectedOption] isEqualToString:@"life"] && currentImageIsAlive) ||
			([[controllerView selectedOption] isEqualToString:@"notLife"] && !currentImageIsAlive))
		{
			//correct!
			[controllerView setTotalPoints:[controllerView totalPoints] + [controllerView picturePoints]];
		}
		else
		{
			//wrong
			[controllerView setTotalPoints:[controllerView totalPoints] - POINT_PENALTY_FOR_WRONG_ANSWER];
		}
		
		[imageView setShouldShowBorder:YES];

		//show the final image, then move on to the next one after a delay
		currentFilterValue = minimumFilterValue;
		shouldAnimateImage = YES;
		[self animateOneFrame];
		shouldAnimateImage = NO;
		
		[fadeOutAnimation performSelector:@selector(startAnimation)
							   withObject:nil
							   afterDelay:DELAY_BEFORE_TRANSITION];
		
		
		hasHandledEvent = YES;
	}
	
	//taken from an example in the documentation
	else if ([theEvent modifierFlags] & NSNumericPadKeyMask) // arrow keys have this mask
	{ 
        NSString *theArrow = [theEvent charactersIgnoringModifiers];
        unichar keyChar = 0;
        if ( [theArrow length] == 0 )
            return;            // reject dead keys
        if ( [theArrow length] == 1 )
		{
            keyChar = [theArrow characterAtIndex:0];
			
            if ( keyChar == NSLeftArrowFunctionKey || keyChar == NSRightArrowFunctionKey) 
			{
				[controllerView selectNextOption];
				hasHandledEvent = YES;
            }
		}
	}
	
	if(!hasHandledEvent)
		[super keyDown:theEvent];
}

- (BOOL)hasConfigureSheet
{
    return YES;
}

- (NSWindow*)configureSheet
{
    if(!preferencesWindow)
	{
		if(![NSBundle loadNibNamed:@"Preferences" owner:self])
		{
			NSLog(@"***Could not load preferences nib!***");
			return nil;
		}
	}
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:moduleName];
	
	if([[defaults objectForKey:@"effect"]isEqualToString:@"gaussianBlur"])
		[effectPopUpButton selectItemAtIndex:0];
	else if([[defaults objectForKey:@"effect"]isEqualToString:@"pixellate"])
		[effectPopUpButton selectItemAtIndex:1];
	
	if([[defaults objectForKey:@"sepiaTone"]boolValue] == YES)
		[sepiaToneCheckbox setState:NSOnState];
	else
		[sepiaToneCheckbox setState:NSOffState];
	
	if([[defaults objectForKey:@"highScore"]intValue] == 0) //no high scores
		[highScoreField setStringValue:@"none"];
	else
		[highScoreField setIntValue:[[defaults objectForKey:@"highScore"]intValue]];
	
	return preferencesWindow;	
}

- (IBAction)savePreferences:(id)sender;
{
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:moduleName];
	
	if([effectPopUpButton indexOfSelectedItem] == 0)
		[defaults setObject:@"gaussianBlur" forKey:@"effect"];
	else if([effectPopUpButton indexOfSelectedItem] == 1)
		[defaults setObject:@"pixellate" forKey:@"effect"];
	
	if([sepiaToneCheckbox state] == NSOnState)
		[defaults setObject:[NSNumber numberWithBool:YES] forKey:@"sepiaTone"];
	else if([sepiaToneCheckbox state] == NSOffState)
			[defaults setObject:[NSNumber numberWithBool:NO] forKey:@"sepiaTone"];
	
	[self cancelPreferences:nil];
		
}
- (IBAction)cancelPreferences:(id)sener;
{
	[NSApp endSheet:preferencesWindow];
	[preferencesWindow orderOut:nil];
}

- (void)stopAnimation
{
	//if any NSAnimations are still running when stopAnimation is called, it tends to crash for some reason. So just make sure they are stopped.
	[fadeOutAnimation stopAnimation];
	[fadeInAnimation stopAnimation];
	
	ScreenSaverDefaults *defaults = [ScreenSaverDefaults defaultsForModuleWithName:moduleName];
	if([controllerView totalPoints] > [[defaults objectForKey:@"highScore"]intValue]) //if the user beat the high score
		[defaults setObject:[NSNumber numberWithInt:[controllerView totalPoints]] forKey:@"highScore"];
	
	[super stopAnimation];
}

- (void) dealloc 
{
	[notAlivePhotoURLs release];
	[alivePhotoURLs release];
	[controllerView removeFromSuperviewWithoutNeedingDisplay];
	[controllerView release];
	[imageView removeFromSuperviewWithoutNeedingDisplay];
	[imageView release];
	[fadeOutAnimation stopAnimation];
	[fadeOutAnimation release];
	[fadeInAnimation stopAnimation];
	[fadeInAnimation release];
	[super dealloc];
}

	

@end
