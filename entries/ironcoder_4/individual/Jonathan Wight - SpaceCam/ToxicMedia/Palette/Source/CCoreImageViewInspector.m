//
//  CCoreImageViewInspector.m
//  ToxicMedia
//
//  Created by Jonathan Wight on 10/20/2005.
//  Copyright Toxic Software 2005 . All rights reserved.
//

#import "CCoreImageViewInspector.h"
#import "CCoreImageView.h"

@implementation CCoreImageViewInspector

- (id)init
{
if ((self = [super init]) != NULL)
	{
	model = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
		[NSNumber numberWithBool:NO], @"flipHorizontal",
		[NSNumber numberWithBool:NO], @"crop",
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithFloat:0.0f], @"origin_x",
			[NSNumber numberWithFloat:0.0f], @"origin_y",
			[NSNumber numberWithFloat:640.0f], @"size_width",
			[NSNumber numberWithFloat:480.0f], @"size_height",
			NULL], @"cropRect",
		NULL];	
	[NSBundle loadNibNamed:@"CCoreImageViewInspector" owner:self];
	
	[model addObserver:self forKeyPath:@"flipHorizontal" options:NSKeyValueObservingOptionNew context:NULL];
	[model addObserver:self forKeyPath:@"crop" options:NSKeyValueObservingOptionNew context:NULL];
	[model addObserver:self forKeyPath:@"cropRect.origin_x" options:NSKeyValueObservingOptionNew context:NULL];
	[model addObserver:self forKeyPath:@"cropRect.origin_y" options:NSKeyValueObservingOptionNew context:NULL];
	[model addObserver:self forKeyPath:@"cropRect.size.width" options:NSKeyValueObservingOptionNew context:NULL];
	[model addObserver:self forKeyPath:@"cropRect.size.height" options:NSKeyValueObservingOptionNew context:NULL];
	}
return(self);
}

#pragma mark -

- (void)ok:(id)sender
{
[super ok:sender];
}

- (void)revert:(id)sender
{
[super revert:sender];

[model setValue:[[self object] valueForKey:@"flipHorizontal"] forKeyPath:@"flipHorizontal"];
}

- (IBAction)actionDebug:(id)inSender
{
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
if ([keyPath isEqual:@"flipHorizontal"])
	[[self object] setValue:[change objectForKey:@"new"] forKey:@"flipHorizontal"];
else if ([keyPath isEqual:@"crop"])
	[[self object] setValue:[change objectForKey:@"new"] forKey:@"crop"];
else
	{
	NSRect theRect = [[self object] cropRect];
	if ([keyPath isEqual:@"cropRect.origin_x"])
		theRect.origin.x = [[change objectForKey:@"new"] floatValue];
	else if ([keyPath isEqual:@"cropRect.origin_y"])
		theRect.origin.y = [[change objectForKey:@"new"] floatValue];
	else if ([keyPath isEqual:@"cropRect.size.width"])
		theRect.size.width = [[change objectForKey:@"new"] floatValue];
	else if ([keyPath isEqual:@"cropRect.size.height"])
		theRect.size.height = [[change objectForKey:@"new"] floatValue];
	}
}

@end
