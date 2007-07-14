//
//  BlurredLifeView.h
//  BlurredLife
//
//  Created by Adam Leonard on 3/30/07.
//  Copyright (c) 2007, __MyCompanyName__. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <QuartzCore/QuartzCore.h>
@class FlickrParser;
@class ALImageView;
@class ControllerView;

@interface BlurredLifeView : ScreenSaverView 
{
	NSMutableArray *notAlivePhotoURLs;
	NSMutableArray *alivePhotoURLs;
	FlickrParser *notAliveParser;
	FlickrParser *aliveParser;
	
	ControllerView *controllerView;
	
	ALImageView *imageView;
	NSImage *currentImageAsNSImage;
	CIImage *currentImageAsCIImage;
	float currentFilterValue; //how pixelated the image is (1-100)
	float minimumFilterValue;
	
	BOOL currentImageIsAlive;
	
	BOOL shouldAnimateImage;
	NSViewAnimation *fadeOutAnimation;
	NSViewAnimation *fadeInAnimation;
	
	NSMutableData *currentImageData;
	
	//config sheet
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSPopUpButton *effectPopUpButton;
	IBOutlet NSButton *sepiaToneCheckbox;
	IBOutlet NSTextField *highScoreField;
}
-(void)flickrParser:(FlickrParser *)parser didFindPhotoURLs:(NSArray *)results;

- (void)animationDidEnd:(NSViewAnimation*)animation;

-(void)showNextImage;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

- (IBAction)savePreferences:(id)sender;
- (IBAction)cancelPreferences:(id)sener;

@end
