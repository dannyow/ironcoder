//
//  DialView.m
//  SunMoonDial
//
//  Created by Chris Liscio on 22/07/06.
//  Copyright 2006 SuperMegaUltraGroovy. All rights reserved.
//

#import "DialView.h"
#import <Carbon/Carbon.h>

@interface DialView(Private)
- (void)refreshDisplay;
- (void)tick:(NSTimer*)timer;
@end

@implementation DialView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }    
    return self;
}

- (void)awakeFromNib
{
    NSRect screenFrame = [[NSScreen mainScreen]frame];
    // Set the frame to be a square, as big as the screen's width
    [[self window] setFrame:NSMakeRect(screenFrame.origin.x, 
                                       screenFrame.origin.y-((2*screenFrame.size.width)/5), 
                                       screenFrame.size.width, 
                                       screenFrame.size.width) display:NO];
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef imgURL = CFBundleCopyResourceURL( mainBundle,
                                               CFSTR("dial"),
                                               CFSTR("png"),
                                               NULL );
    CGDataProviderRef dp = CGDataProviderCreateWithURL( imgURL );
    mImageRef = CGImageCreateWithPNGDataProvider( dp,
                                                  NULL,
                                                  1,
                                                  kCGRenderingIntentDefault );

    CGDataProviderRelease( dp );
    CFRelease( imgURL );
    
    imgURL = CFBundleCopyResourceURL( mainBundle,
                                      CFSTR("dialmask"),
                                      CFSTR("png"),
                                      NULL );
    dp = CGDataProviderCreateWithURL( imgURL );

    mMaskRef = CGImageCreateWithPNGDataProvider( dp,
                                                 NULL,
                                                 1,
                                                 kCGRenderingIntentDefault );
    
    CGDataProviderRelease( dp );
    CFRelease( imgURL );
    
    // Set the display up properly on startup
    NSCalendarDate *d = [NSCalendarDate calendarDate];
    mHour = [d hourOfDay];
    mMinute = [d minuteOfHour];    
    [self refreshDisplay];
    
    // Check the time every 10 seconds.  Not a heavy operation.
    mTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                              target:self
                                            selector:@selector(tick:)
                                            userInfo:nil
                                             repeats:YES];    
}

- (void)dealloc
{
    CGImageRelease( mImageRef );
    CGImageRelease( mMaskRef );
    [mTimer invalidate];
    [mTimer release];
    [super dealloc];
}

- (BOOL)isFlipped
{
    return NO;
}

#define deg2rad(d) ((d)*(M_PI/180.0))
#define ns2cg(r) (*(CGRect*)&(r))

- (void)drawRect:(NSRect)rect {
    
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSaveGState( context );
       
    CGContextClipToMask( context, ns2cg(rect), mMaskRef );    
    
    // Rotate from the center of the image
    CGContextTranslateCTM( context, rect.size.width/2, rect.size.height/2);
    CGContextRotateCTM( context, deg2rad(mRotateDegrees) );
    CGContextTranslateCTM( context, -rect.size.width/2, -rect.size.height/2);
    
    CGContextDrawImage( context, ns2cg(rect), mImageRef );  
    
    CGContextRestoreGState( context );
}

@end

@implementation DialView(Private)

- (void)refreshDisplay
{
    // There are a million ways to calculate this, and this is the one off the top of my head
    mRotateDegrees = - ((((float)mHour + ((float)mMinute/60.f)) / 24.f ) * 360.f);
    [self setNeedsDisplay:YES];
}

- (void)tick:(NSTimer*)timer
{
    // Base the rotation degrees on the current time
    NSCalendarDate *d = [NSCalendarDate calendarDate];
    int hour = [d hourOfDay];
    int minute = [d minuteOfHour];
    
    // Only do stuff if the time has actually changed
    if ( ( hour != mHour ) || ( minute != mMinute ) ) {
        mHour = hour;
        mMinute = minute;
        [self refreshDisplay];
    }
}

@end
