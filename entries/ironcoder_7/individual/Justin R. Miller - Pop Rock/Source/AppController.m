//  AppController.m
//  Pop Rock
//
//  Copyright © 2007 Code Sorcery Workshop. All rights reserved.

#import "AppController.h"
#import <Quartz/Quartz.h>

@implementation AppController

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // setup fullscreen window
    fullScreenWindow = [[NSWindow alloc] initWithContentRect:[[NSScreen mainScreen] frame]
                                                   styleMask:NSBorderlessWindowMask
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
    [fullScreenWindow setLevel:NSScreenSaverWindowLevel];
    
    // load in QC animation
    QCView *animationView = [[QCView alloc] init];
    [animationView loadCompositionFromFile:[NSBundle pathForResource:@"animation"
                                                              ofType:@"qtz"
                                                         inDirectory:[[NSBundle mainBundle] bundlePath]]];
    [fullScreenWindow setContentView:animationView];
    [animationView release];
    
    // setup empty known app icon dictionary (appName => appIcon)
    knownApps = [[NSMutableDictionary dictionaryWithCapacity:0] retain];

    // setup running apps name array & populate known apps
    runningApps = [[NSMutableArray arrayWithCapacity:0] retain];
    NSArray *launchedApps = [[NSWorkspace sharedWorkspace] launchedApplications];
    NSEnumerator *launchEnumerator = [launchedApps objectEnumerator];
    NSDictionary *thisApp;
    while (thisApp = [launchEnumerator nextObject])
    {
        // don't count our own app instance
        if ([[thisApp objectForKey:@"NSApplicationName"] isNotEqualTo:[[NSProcessInfo processInfo] processName]])
        {
            [self cacheAppWithName:[thisApp objectForKey:@"NSApplicationName"]
                            atPath:[thisApp objectForKey:@"NSApplicationPath"]];
            [runningApps addObject:[thisApp objectForKey:@"NSApplicationName"]];
        }
    }
    
    NSLog(@"known icons: %@", [knownApps allKeys]);
    NSLog(@"running apps: %@", runningApps);
    
    // register for app launch notifications
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(appDidLaunch:)
                                                               name:NSWorkspaceDidLaunchApplicationNotification 
                                                             object:nil];

    // register for app quit notifications
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector:@selector(appDidQuit:)
                                                               name:NSWorkspaceDidTerminateApplicationNotification 
                                                             object:nil];
    
    // set initial guitar riff
    riffCounter = 1;
}

- (void)dealloc
{
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [fullScreenWindow release];
    [knownApps release];
    [runningApps release];
    [super dealloc];
}

- (void)cacheAppWithName:(NSString *)name atPath:(NSString *)path
{
    /* Load the app's icon, capture a 128x128 PNG, and store it for future use for speed. 
       I wish I knew how to get QC to pick a large representation in multi-rep .icns, 
       but I can't, so this is a hack. Otherwise the icons in QC get a fuzzy, blown-up
       16x16 version if you pass the ICNS-based NSImage directly. */
    
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
    [icon setSize:NSMakeSize(128, 128)];
    NSSize size = [icon size];
    NSRect iconRect = NSMakeRect(0, 0, size.width, size.height);
    [icon lockFocus];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:iconRect];
    [icon unlockFocus];
    icon = [[NSImage alloc] initWithData:[rep representationUsingType:NSPNGFileType
                                                           properties:nil]];
    [rep release];
    [knownApps setObject:icon forKey:name];
    [icon release];
    NSLog(@"Added %@ to list of known icons", name);
}

- (void)appDidLaunch:(NSNotification *)aNotification
{
    // check if it's a known app & cache it if not
    if (![knownApps valueForKey:[[aNotification userInfo] objectForKey:@"NSApplicationName"]])
    {
        [self cacheAppWithName:[[aNotification userInfo] objectForKey:@"NSApplicationName"] 
                        atPath:[[aNotification userInfo] objectForKey:@"NSApplicationPath"]];
    }
    
    // add to running apps list
    [runningApps addObject:[[aNotification userInfo] objectForKey:@"NSApplicationName"]];
    
    // present launch sequence
    [self rockAndRoll:[[aNotification userInfo] objectForKey:@"NSApplicationName"]];
}

- (void)appDidQuit:(NSNotification *)aNotification
{
    [runningApps removeObject:[[aNotification userInfo] objectForKey:@"NSApplicationName"]];
    NSString *msg = [NSString stringWithFormat:@"%@ just quit: %i apps still running", 
                        [[aNotification userInfo] objectForKey:@"NSApplicationName"],
                        [runningApps count]];
    NSLog(msg);
}

- (void)rockAndRoll:(NSString *)appName
{
    NSString *msg = [NSString stringWithFormat:@"Running %@ and %i other apps", appName, ([runningApps count] - 1)];
    NSLog(msg);
    
    // get QCView object
    QCView *animation = [fullScreenWindow contentView];
    
    // load up main app icon
    NSImage *appImage = [knownApps valueForKey:appName];
    [animation setValue:appImage forInputKey:@"AppImage"];

    // load launched app's name
    [animation setValue:appName forInputKey:@"AppName"];
    
    // load up audience icons (up to 20, selected from other running apps, semi-random placement in crowd)
    int appCount = (([runningApps count] < 20) ? [runningApps count] : 20);
    NSMutableArray *usedPlaces = [NSMutableArray arrayWithCapacity:appCount];
    srandom(time(NULL));
    int generated;
    int i; for (i = 0; i < appCount; i++)
    {
        if ([[runningApps objectAtIndex:i] isNotEqualTo:appName])
        {
            generated = (random() % 20);
            while ([usedPlaces containsObject:[NSNumber numberWithInt:generated]])
            {
                generated = (random() % 20);
            }
            NSString *audience = [runningApps objectAtIndex:i];
            NSString *keyName = [NSString stringWithFormat:@"Image%i", generated];
            [animation setValue:[knownApps valueForKey:audience]
                    forInputKey:keyName];
            [usedPlaces addObject:[NSNumber numberWithInt:generated]];
        }
    }
    
    // determine level of audience reaction & crowd noises
    NSString *crowdSoundName;
    if (appCount < 4)
    {
        [animation setValue:[NSNumber numberWithInt:0] forInputKey:@"ActivityLevel"];
        // alternate between "you suck" and "freebird"
        if (riffCounter % 2)
            crowdSoundName = @"you suck";
        else
            crowdSoundName = @"freebird";
    }
    else if (appCount >= 4 && appCount < 8)
    {
        [animation setValue:[NSNumber numberWithInt:1] forInputKey:@"ActivityLevel"];
        crowdSoundName = @"clapping";
    }
    else if (appCount >= 8 && appCount < 16)
    {
        [animation setValue:[NSNumber numberWithInt:2] forInputKey:@"ActivityLevel"];
        crowdSoundName = @"cheering";
    }
    else
    {
        [animation setValue:[NSNumber numberWithInt:3] forInputKey:@"ActivityLevel"];
        crowdSoundName = @"arena";
    }
        
    // bring animation to front
    [NSApp activateIgnoringOtherApps:YES];
    [animation startRendering];
    [fullScreenWindow setAlphaValue:1.0];
    [fullScreenWindow orderFront:self];
    
    // start the crowd noise
    NSSound *crowdSound = [NSSound soundNamed:crowdSoundName];
    [crowdSound setDelegate:self];
    [crowdSound play];
    
    // pick the guitar riff
    NSString *riffName = [NSString stringWithFormat:@"guitar%i", riffCounter];
    NSSound *guitar = [NSSound soundNamed:riffName];
    [guitar play];
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
    fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.025
                                                 target:self
                                               selector:@selector(fadeEffect:)
                                               userInfo:nil
                                                repeats:YES];
    [fadeTimer retain];
}

- (void)fadeEffect:(NSTimer *)timer
{
    if ([fullScreenWindow alphaValue] > 0)
    {
        // fade out by 1/10th
        [fullScreenWindow setAlphaValue:([fullScreenWindow alphaValue] - 0.1)];
    }
    else
    {
        [timer invalidate];
        [timer release];
        
        // hide from view
        [NSApp hide:self];
        [fullScreenWindow orderOut:self];
        QCView *animation = [fullScreenWindow contentView];
        [animation stopRendering];
        
        // clear out audience icons
        int i; for (i = 0; i < 20; i++)
        {
            [animation setValue:nil forInputKey:[NSString stringWithFormat:@"Image%i", i]];
        }
        
        // increment riff counter
        riffCounter = ((riffCounter == 4) ? 1 : (riffCounter + 1));
    }
}

@end