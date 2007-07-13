#import <Cocoa/Cocoa.h>

@interface RedWireController : NSObject {
    NSTimer* bombTimer;
    BOOL explosion;
    BOOL game;
    int timeLeft;
    IBOutlet NSView* theView;
    NSMutableArray* wires;
    int wiresLeft;
    CGMutablePathRef wirePaths[6];
}

- (void)cut:(int)wireNumber;
- (void)decreaseTime;
- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) rect;
- (void)drawTimerInContext:(CGContextRef) context withRect:(CGRect*) rect;
- (void)drawWhiteInContext:(CGContextRef) context withRect:(CGRect*) rect;
- (void)drawWiresInContext:(CGContextRef) context withRect:(CGRect*) rect;
- (void)explode;
- (IBAction)reset:(id)sender;

@end
