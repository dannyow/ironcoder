//  AppController.h
//  Pop Rock
//
//  Copyright © 2007 Code Sorcery Workshop. All rights reserved.

#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
    NSWindow *fullScreenWindow;
    NSMutableDictionary *knownApps;
    NSMutableArray *runningApps;
    NSTimer *fadeTimer;
    int riffCounter;
}
- (void)cacheAppWithName:(NSString *)name atPath:(NSString *)path;
- (void)appDidLaunch:(NSNotification *)aNotification;
- (void)appDidQuit:(NSNotification *)aNotification;
- (void)rockAndRoll:(NSString *)appName;
- (void)fadeEffect:(NSTimer *)timer;
@end