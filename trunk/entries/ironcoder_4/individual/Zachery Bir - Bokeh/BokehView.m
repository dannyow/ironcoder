#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import <QuartzCore/QuartzCore.h>
#import "BokehView.h"

@implementation BokehView
- (void)filterFromCurrentView
{
    [self lockFocus];
    NSLog( @"Locking focus" );
    NSBitmapImageRep *screen_rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect: [self bounds]];
    [self unlockFocus];
    NSLog( @"Unlocking focus" );
    CIImage *background = [[CIImage alloc] initWithBitmapImageRep: screen_rep];
    NSLog( @"Building a CIImag from our bitmap" );
    filter = [[CIFilter filterWithName: @"CIGaussianBlur"
                         keysAndValues: 
        @"inputImage", background,
        @"inputRadius", [NSNumber numberWithFloat: 10.0],
        nil] retain];
}

- (void)drawRect:(NSRect) rect
{
    [self filterFromCurrentView];
    CIContext *context = [[NSGraphicsContext currentContext] CIContext];
    CGRect trans_rect = CGRectMake([self bounds].origin.x,
                                   [self bounds].origin.y,
                                   [self bounds].size.width,
                                   [self bounds].size.height);

    [context drawImage: [filter valueForKey: @"outputImage"]
                inRect: trans_rect
              fromRect: CGRectMake(0, 0, [self bounds].size.width, [self bounds].size.height)];
}
@end
