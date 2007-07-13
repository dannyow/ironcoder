#import "BWCGView.h"

@interface BWCGShadowView : BWCGView
{
    BOOL drawShadow;
    BOOL useTransparencyLayer;
    float blur;
    float angle;
    float distance;
    
    NSPoint point;
}

- (IBAction) drawShadow: (id) sender;
- (IBAction) useTransparency: (id) sender;
- (IBAction) setBlur: (id) sender;
- (IBAction) setAngle: (id) sender;
- (IBAction) setDistance: (id) sender;

@end // BWCGShadowView

