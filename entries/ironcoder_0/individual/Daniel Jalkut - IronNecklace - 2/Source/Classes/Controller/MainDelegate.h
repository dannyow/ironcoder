/* MainDelegate */

#import <Cocoa/Cocoa.h>

@class RSUIElement;
@class OverlayAnimationWindow;

@interface MainDelegate : NSObject
{
	RSUIElement* mTargetElement;
	OverlayAnimationWindow* mOverlayWindow;
	NSString* mLastDesc;
	
    Point _lastMousePoint;	
	
	IBOutlet id mWelcomeQCView;
	IBOutlet id mToggleTabs;
}

- (void) updateNecklaceAtX:(float)xAnchor andY:(float)yAnchor;

@end
