//
//  BSInvaderAppDelegate.m
//  Invader
//
//  Created by Blake Seely on 10/28/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BSInvaderAppDelegate.h"
#import "BSInvaderView.h"
#import "BSInvaderBulletView.h"


@implementation BSInvaderAppDelegate

- (id)init
{
    if (self = [super init])
    {
        _liveInvaders = [[NSMutableSet alloc] init];
        _stepTimer = nil;
        
        // Take a screen capture
        NSString *capturePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Screen.png"];
        NSTask *screencapture = [NSTask launchedTaskWithLaunchPath:@"/usr/sbin/screencapture" arguments:[NSArray arrayWithObjects:@"-x", capturePath, nil]];
        [screencapture waitUntilExit];
        
    }
    
    return self;
}

- (void)dealloc
{
    NSString *screenshotPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"Screen.png"];
    [[NSFileManager defaultManager] removeFileAtPath:screenshotPath handler:nil];
    
    [_liveInvaders release];
    [_stepTimer release];
    
    [super dealloc];
}

- (void)awakeFromNib
{    
    [self performSelector:@selector(goInvade) withObject:nil afterDelay:2.0];
}

- (void)goInvade
{
    [invaderView setValue:self forKey:@"delegate"];
    
    float invaderWidth = 170;
    float invaderCount = floorf(([[NSScreen mainScreen] frame].size.width / (invaderWidth) - 4)); // some reasonable default
    float invaderSecondRow = invaderCount + 2;
    
    float invaderTopRowBaseY = [[NSScreen mainScreen] frame].size.height - (invaderWidth);
    float invaderBottomRowBaseY = invaderTopRowBaseY - (invaderWidth);
    
    float invaderTopRowStartX = ([[NSScreen mainScreen] frame].size.width - (invaderWidth * invaderCount)) / 2;
    invaderTopRowStartX -= 2 * invaderWidth;
    
    float invaderBottomRowStartX = ([[NSScreen mainScreen] frame].size.width - (invaderWidth * invaderSecondRow)) / 2;
    invaderBottomRowStartX -= 2 *invaderWidth;
    
    // Plant the first row
    int i;
    for (i = 0; i < invaderCount; i++)
    {
        BSInvaderView *invader = [[BSInvaderView alloc] init];
        [invaderView addSubview:invader];
        NSRect startRect = NSMakeRect(invaderTopRowStartX + (invaderWidth * i), invaderTopRowBaseY, invaderWidth, invaderWidth);
        [invader birthAtRect:startRect];
        
        [_liveInvaders addObject:invader];
    }
    
    for (i = 0; i < invaderSecondRow; i++)
    {
        BSInvaderView *invader = [[BSInvaderView alloc] init];
        [invaderView addSubview:invader];
        NSRect startRect = NSMakeRect(invaderBottomRowStartX + (invaderWidth * i), invaderBottomRowBaseY, invaderWidth, invaderWidth);
        [invader birthAtRect:startRect];
        
        [_liveInvaders addObject:invader];
    }
    
    _stepCount = 0;
    _stepDirection = YES;
    _stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(step:) userInfo:nil repeats:YES];
    
}

- (void)step:(NSTimer *)timer
{
    float movement = 170 / 4;
    
    if ((_stepCount % 10 == 0) && (_stepCount != 0))
    {
        // We hit one side - go down
        NSEnumerator *enumerator = [_liveInvaders objectEnumerator];
        BSInvaderView *invader = nil;
        while (invader = [enumerator nextObject])
        {
            NSRect frame = [invader frame];
            frame.origin.y -= movement;
            [invader step:frame];
        }
        
        _stepDirection = !_stepDirection;
        
    }
    else
    {
        if (!_stepDirection)
            movement = 0 - movement;
        
        NSEnumerator *enumerator = [_liveInvaders objectEnumerator];
        BSInvaderView *invader = nil;
        while (invader = [enumerator nextObject])
        {
            NSRect frame = [invader frame];
            frame.origin.x += movement;
            [invader step:frame];
        }
    }
    
    _stepCount++;
    
    [invaderView setNeedsDisplay:YES];
}

- (void)removeInvader:(BSInvaderView *)invader
{
    NSLog(@"Killed.");
    
    [invader removeFromSuperview];
    
    [_liveInvaders removeObject:invader];
    if ([_liveInvaders count] == 0)
        [_stepTimer invalidate];
}
@end
