#import <Carbon/Carbon.h>
#import "BokehController.h"
#import "BokehView.h"

#define FRAME_RATE (1.0f / 20.0f)

@implementation BokehController

- (BokehController *)init
{
    self = [super init];
    number_of_windows = 3;
    windows = [[NSMutableArray alloc] init];
  
    return self;
}

- (void)intersticeWindows:(id *)sender
{
    int i;
    
    for (i = 0; i < number_of_windows; i++)
    {
        [[windows objectAtIndex: i] orderWindow: NSWindowBelow relativeTo: (i + 3)];
        [[[windows objectAtIndex: i] contentView] filterFromCurrentView];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    int i;
    NSRect screenRect;
    
    screenRect = [[NSScreen mainScreen] frame];
    for (i = 0; i < number_of_windows; i++)
    {
        BokehView *view = [[BokehView alloc] init];
        NSWindow *window = [[NSWindow alloc] initWithContentRect: screenRect
                                                       styleMask: NSBorderlessWindowMask
                                                         backing: NSBackingStoreBuffered
                                                           defer: NO
                                                          screen: [NSScreen mainScreen]];
        [window setOpaque: NO];
        [window setBackgroundColor: [NSColor colorWithCalibratedRed: 0.0
                                                              green: 0.0
                                                               blue: 0.0
                                                              alpha: 0.25]];
        [window setIgnoresMouseEvents: YES];
        [window setContentView: view];
        [windows addObject: window];
    }
    
    [self intersticeWindows: nil];
    [self installAppChangedEventHandler];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    int i;
    
    for (i = 0; i < number_of_windows; i++)
    {
        [[windows objectAtIndex: i] orderOut: self];
    }
}

- (EventHandlerRef) installAppChangedEventHandler
{
    OSStatus eventErr;
    EventTypeSpec myEventTypes[1] = {{kEventClassApplication, kEventAppFrontSwitched}};
    EventHandlerRef newEventHandler;
    
    // Install Carbon event handler to hear about App-Changed events
    eventErr = InstallEventHandler(GetApplicationEventTarget(), NewEventHandlerUPP(MyAppChangedEventHandler),  1, myEventTypes, self /*userdata*/, &newEventHandler);
    if (eventErr != noErr)
    {
        newEventHandler = nil;
    }
    return newEventHandler;
}

OSStatus MyAppChangedEventHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
    OSStatus result = eventNotHandledErr;
    UInt32 eventClass = GetEventClass(inEvent);
    UInt32 eventKind = GetEventKind(inEvent);
    
    // We only handle active app chnaged events...
    if ((eventClass == kEventClassApplication) && (eventKind == kEventAppFrontSwitched))
    {
        ProcessSerialNumber newFrontProcess;
        
        // Get the new process ID out
        if (GetEventParameter(inEvent, kEventParamProcessID, typeProcessSerialNumber, NULL, sizeof(ProcessSerialNumber), NULL, &newFrontProcess) == noErr)
        {
            // Put your custom objective-C callback here
            [((BokehController *) inUserData) intersticeWindows: nil];
        }
        
        // Tell the dispatcher that we handled the event...
        result = noErr;
    }
    
    return result;
}

- (void)dealloc
{
    [super dealloc];
}


- (BOOL)canBecomeKeyWindow
{
    return YES;
}
@end
