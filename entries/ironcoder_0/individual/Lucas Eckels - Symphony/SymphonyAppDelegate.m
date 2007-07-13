//
//  SymphonyAppDelegate.m
//  Symphony
//
//  Created by Lucas Eckels on 3/3/06.
//
// Copyright (c) 2006, Flesh Eating Software
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without 
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
// * Neither the name of the Flesh Eating Software nor the names of its 
//    contributors may be used to endorse or promote products derived from 
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
//
#import "SymphonyAppDelegate.h"
#include <CoreFoundation/CoreFoundation.h>
#include <QTKit/QTKit.h>

#define MAX_ACTIVE_MOVIES 32
#define NSApplicationBundleIdentifier @"NSApplicationBundleIdentifier"
#define NSApplicationProcessIdentifier @"NSApplicationProcessIdentifier"
static int sActiveMovies = 0;
static NSMutableDictionary *playingTracks; // give access in the callback without an accessor on the app delegate

void app_observer_callback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon)
{
   NSDictionary *dict = (NSDictionary*)refcon;
   NSString *soundFilename = [dict valueForKey:@"soundFilename"];
   
   if (sActiveMovies < MAX_ACTIVE_MOVIES)
   {
      if ([playingTracks objectForKey:soundFilename])
      {
         return; // movie is already playing
      }
      [playingTracks setObject:[NSNumber numberWithBool:YES] forKey:soundFilename]; 
      // place a 5 second delay before this sound can be played again
      [[NSApp delegate] performSelector:@selector(removeLimitOnFilename:) withObject:[soundFilename retain] afterDelay:5]; // release the filename in the selector
         
      // show some GUI progress
     [(SymphonyAppDelegate*)[NSApp delegate] toggleDot];
      ++sActiveMovies; // prevent too many sounds from playing at a time
      NSString *filename = [[NSBundle mainBundle] pathForResource:soundFilename ofType:nil inDirectory:@"Data"];
      
      QTMovie *movie = [[QTMovie movieWithFile:filename error:nil] retain]; // released in notification method
      NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
      [center addObserver:[NSApp delegate] selector:@selector(soundFinished:) name:QTMovieDidEndNotification   object:[NSApp delegate]];
      [movie play];
   }
}
   
struct FESAxTypes
{
   AXObserverRef observer;
   AXUIElementRef element;
};

@implementation SymphonyAppDelegate

-(void)awakeFromNib
{
   applicationsLoaded = [[NSMutableDictionary dictionaryWithCapacity:50] retain];
   playingTracks = [[NSMutableDictionary dictionaryWithCapacity:MAX_ACTIVE_MOVIES] retain];
   
   NSNotificationCenter *notificationCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
   [notificationCenter addObserver:self selector:@selector(workspaceDidLaunchApplication:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
   [notificationCenter addObserver:self selector:@selector(workspaceDidTerminateApplication:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
   [self importSymphonyFromResource];
}

-(void)toggleDot;
{
   BOOL hidden = [dot isHidden];
   [dot setHidden:!hidden];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApp
{
   return YES;
}

-(void)dealloc;
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
   [alwaysMovie release];
   [applicationEffects release];
   [applicationsLoaded release]; // should iterate over the dict to remove everything
   [playingTracks release];
   [super dealloc];
}

-(IBAction)importSymphonyFromEditor:(id)sender;
{
   NSOpenPanel *openPanel = [NSOpenPanel openPanel];
   if ([openPanel runModalForDirectory:nil file:nil types:nil] == NSCancelButton)
   {
      return;
   }
   
   NSString *inFile = [[openPanel filenames] objectAtIndex:0];

   NSSavePanel *savePanel = [NSSavePanel savePanel];
   [savePanel setRequiredFileType:@"xml"];
   [savePanel setAllowsOtherFileTypes:NO];
   [savePanel setTitle:@"Export to XML"];
   [savePanel setNameFieldLabel:@"Export as"];
   [savePanel setPrompt:@"Export"];
   [savePanel setCanSelectHiddenExtension:YES];
   [savePanel setTreatsFilePackagesAsDirectories:YES];
   
   if ([savePanel runModalForDirectory:nil file:@"Effects.xml"] == NSFileHandlingPanelCancelButton)
   {
      return;
   }

   NSString *outFile = [savePanel filename];
   
   NSDictionary *fileDict = [NSDictionary dictionaryWithContentsOfFile:inFile];
   NSDictionary *appDict = [fileDict valueForKey:@"applications"];
   if ([appDict writeToFile:outFile atomically:NO] == NO)
   {
      NSLog(@"Problem writing out application array.");
   }

   NSString *soundDirectory = [outFile stringByDeletingLastPathComponent];
   NSDictionary *soundDict = [fileDict valueForKey:@"sounds"];
   NSEnumerator *soundEnum = [soundDict keyEnumerator];
   NSString *soundKey;
   while (soundKey = [soundEnum nextObject])
   {
      NSData *sound = [soundDict valueForKey:soundKey];
      NSString *soundFile = [soundDirectory stringByAppendingPathComponent:soundKey];
      if([sound writeToFile:soundFile atomically:NO] == NO)
      {
         NSLog(@"Problem writing out sound file: %@", soundKey);
      }
   }
}

-(void)importSymphonyFromResource;
{
   if (applicationEffects != nil)
   {
      NSLog(@"can't reinitialize");
      return;
   }
   
   
   NSString *filename = [[NSBundle mainBundle] pathForResource:@"Effects.xml" ofType:nil inDirectory:@"Data"];
   applicationEffects = [[NSDictionary dictionaryWithContentsOfFile:filename] retain];
   
   NSArray *appArray = [[NSWorkspace sharedWorkspace] launchedApplications];
   
   // special case for "Always" track
   NSDictionary *always = [applicationEffects valueForKey:@"Always"];
   if (always != nil)
   {
      NSString *soundFilename = [[[always valueForKey:@"effects"] objectAtIndex:0] valueForKey:@"soundFilename"];
      NSString *filename = [[NSBundle mainBundle] pathForResource:soundFilename ofType:nil inDirectory:@"Data"];
      
      alwaysMovie = [[QTMovie movieWithFile:filename error:nil] retain]; // released in dealloc
      NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
      [center addObserver:[NSApp delegate] selector:@selector(soundFinished:) name:QTMovieDidEndNotification   object:nil];
      [alwaysMovie play];
   }
   
   NSEnumerator *enumer = [appArray objectEnumerator];
   NSDictionary *app;
   // use carbon process manager?
   // special case to find the dock?
   while (app = [enumer nextObject])
   {
      [self addNotificationsForApplication:app];
   }
   
   
   ProcessSerialNumber psn = {0, kNoProcess};
   while (GetNextProcess(&psn) == 0)
   {
      pid_t pid;
      if (GetProcessPID(&psn, &pid) == 0)
      {
         // should clean these up as the applications are terminated, but I find myself not worrying too much
         [self addNotificationsForApplication:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:pid] forKey:NSApplicationProcessIdentifier]];
      }
            
   }
   
   
}

#pragma mark Accessibility notification setup and teardown

-(BOOL)addNotifications:(NSDictionary*)noteDict toObserver:(AXObserverRef)obs withElement:(AXUIElementRef)element;
{
   if (noteDict == nil)
   {
      return NO;
   }
   NSArray *effects = [noteDict valueForKey:@"effects"];
   NSEnumerator *effectsEnum = [effects objectEnumerator];
   NSDictionary *effect;
   while (effect = [effectsEnum nextObject])
   {
      NSArray *notes = [effect valueForKey:@"notifications"];
      NSEnumerator *noteEnum = [notes objectEnumerator];
      NSString *note;
      while (note = [noteEnum nextObject])
      {
         AXObserverAddNotification(obs, element, (CFStringRef)note, effect);
      }
      
   }
   return YES;
}


-(BOOL)addNotificationsForApplication:(NSDictionary*)app;
{
   if ([[app valueForKey:NSApplicationBundleIdentifier] isEqual:[[NSBundle mainBundle] bundleIdentifier]])
   {
      return NO; // do not add notifications for our own app
   }
   
   NSNumber *pidNumber = [app objectForKey:NSApplicationProcessIdentifier];
   if ([applicationsLoaded objectForKey:pidNumber] != nil)
   {
      return NO; // already have this app
   }
   
   pid_t pid = [pidNumber intValue];
   
   AXObserverRef observer;
   AXUIElementRef element;
   
   element = AXUIElementCreateApplication( pid );
   
   
   AXObserverCreate ( pid, app_observer_callback, &observer);
   
   // careful not to let the language short circuit evaluating the second set of notifications
   BOOL notificationAdded = [self addNotifications:[applicationEffects valueForKey:@"All applications"] toObserver:observer withElement:element];
   notificationAdded = [self addNotifications:[applicationEffects valueForKey:[app objectForKey:NSApplicationBundleIdentifier]] toObserver:observer withElement:element] || notificationAdded;
   
   if (notificationAdded)
   {
      struct FESAxTypes types = {observer, element};
      NSData *data = [[NSData alloc] initWithBytes:&types length:sizeof(struct FESAxTypes)];
      [applicationsLoaded setObject:data forKey:[NSNumber numberWithLong:pid]];
      [data release];
         
      CFRunLoopAddSource(CFRunLoopGetCurrent(), AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
   }
   else
   {
      CFRelease(observer);
      CFRelease(element);
   }
     
   return notificationAdded;
   
}

-(BOOL)removeNotificationsForApplication:(NSDictionary*)app;
{
   // the correctness of this code is far from certain
   NSNumber *pid = [app valueForKey:NSApplicationProcessIdentifier];
   NSData *data = [applicationsLoaded objectForKey:pid];
   if (data != nil)
   {
      struct FESAxTypes types;
      [data getBytes:&types];
      AXObserverRemoveNotification(types.observer,types.element,nil); // this is attempting to remove all notifications for the observer/element pair.  I have no idea if it's working.
      CFRelease(types.observer);
      CFRelease(types.element);
      return YES;
   }
   return NO;
}

#pragma mark NSNotification methods

-(void)workspaceDidLaunchApplication:(NSNotification*)notification;
{
   [self addNotificationsForApplication:[notification userInfo]];
}

-(void)workspaceDidTerminateApplication:(NSNotification*)notification;
{
   [self removeNotificationsForApplication:[notification userInfo]];
}

-(void)soundFinished:(NSNotification*)notification;
{
   id movie = [notification object];
   if (movie == alwaysMovie)
   {
      [alwaysMovie play];
      return;
   }
   NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
   [center removeObserver:self name:QTMovieDidEndNotification object:movie];
   [movie release];
   --sActiveMovies;
}

-(void)removeLimitOnFilename:(NSString*)filename;
{
   [playingTracks removeObjectForKey:filename];
   [filename release];
}
@end
