/* BokehController */

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>

@interface BokehController : NSObject
{
    int number_of_windows;
    NSMutableArray *windows;
}
- (void)intersticeWindows:(id *)sender;
- (EventHandlerRef) installAppChangedEventHandler;
OSStatus MyAppChangedEventHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData);
@end
