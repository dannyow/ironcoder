#import "BWCGView.h"

@interface BWCGLayerView : BWCGView
{
    CGLayerRef	layer;
    BOOL useLayer;

    int pointCount;
    CGPoint *locations;

    NSTimer *timer;
}

- (IBAction) useLayer: (id) sender;
- (IBAction) animate: (id) sender;

@end // BWCGLayerView


