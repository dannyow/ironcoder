//
//  CToxicMediaPalette.m
//  ToxicMedia
//
//  Created by Jonathan Wight on 10/20/2005.
//  Copyright Toxic Software 2005 . All rights reserved.
//

#import "CToxicMediaPalette.h"

#import "CCoreImageViewInspector.h"

@implementation CToxicMediaPalette

+ (void)load
{
NSLog(@"CToxicMediaPalette loaded");
}

- (void)finishInstantiate
{
coreImageView = [[CCoreImageView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 320.0f, 240.0f)];
[self associateObject:coreImageView ofType:IBViewPboardType withView:coreImageViewProxy];

filteringCoreImageView = [[CFilteringCoreImageView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 320.0f, 240.0f)];
[self associateObject:filteringCoreImageView ofType:IBViewPboardType withView:filteringCoreImageViewProxy];

sequenceGrabberView = [[CSequenceGrabberView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 320.0f, 240.0f)];
[self associateObject:sequenceGrabberView ofType:IBViewPboardType withView:sequenceGrabberViewProxy];

sequenceGrabber = [[CSequenceGrabber alloc] init];
[self associateObject:sequenceGrabber ofType:IBObjectPboardType withView:sequenceGrabberProxy];

coreVideoMovieView = [[CCoreVideoMovieView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, 320.0f, 240.0f)];
[self associateObject:coreVideoMovieView ofType:IBViewPboardType withView:coreVideoMovieViewProxy];
}

@end

#pragma mark -

@implementation CCoreImageView (CCoreImageView_Inspector)

- (NSString *)inspectorClassName
{
return(NSStringFromClass([CCoreImageViewInspector class]));
}

@end

#pragma mark -

@implementation CFilteringCoreImageView (CFilteringCoreImageView_Inspector)

- (NSString *)inspectorClassName
{
return(NSStringFromClass([CCoreImageViewInspector class]));
}

@end

#pragma mark -

@implementation CSequenceGrabberView (CSequenceGrabberView_Inspector)

- (NSString *)inspectorClassName
{
return(NSStringFromClass([CCoreImageViewInspector class]));
}

@end
