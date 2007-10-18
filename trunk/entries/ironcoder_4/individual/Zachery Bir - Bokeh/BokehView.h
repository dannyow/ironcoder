/* BokehView */

#import <QuartzCore/QuartzCore.h>
#import <Cocoa/Cocoa.h>

@interface BokehView : NSImageView
{
    CIFilter *filter;
}
- (void)filterFromCurrentView;
@end
