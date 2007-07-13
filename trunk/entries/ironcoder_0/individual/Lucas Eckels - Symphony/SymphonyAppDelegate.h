//
//  SymphonyAppDelegate.h
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
#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@interface SymphonyAppDelegate : NSObject {
   NSDictionary *applicationEffects;
   NSMutableDictionary *applicationsLoaded;
   QTMovie *alwaysMovie;
   IBOutlet NSImageView *dot;
}

/**
 * Toggles the dot.  Used to indicate that a thing has been played.
 */
-(void)toggleDot;

/**
 * Extracts the combined effect and sound data from the format produced by Symphony Editor into that consumed by Symphony.
 *
 * This will not effect what effects are currently in effect.  Copy the results into the Resources of the app bundle to take effect next time you start Symphony.
 */
-(IBAction)importSymphonyFromEditor:(id)sender;

/**
 * Imports the effect data from the app bundle's resources.  This can only be done once during the run of the application.
 */
-(void)importSymphonyFromResource;

#pragma mark Accessibility notification setup and teardown
/**
 * Adds the notifications found within noteDict to the observer.
 *
 * @param noteDict
 *        Dictionary containing the notifications to add.
 * @param obs
 *        Observer to add the notification to
 * @element
 *        Element to observer.
 * @return YES if any notifications were added, NO if noteDict has no relevant notifications.
 */ 
-(BOOL)addNotifications:(NSDictionary*)noteDict toObserver:(AXObserverRef)obs withElement:(AXUIElementRef)element;

/**
 * Adds notifications for the application.  Does the AX/CF magic to get callback setup.
 *
 * @param app
 *        Dictionary containing the constants described in NSWorkspace to specify what application to observe.
 * @return YES if any notifications were added, NO otherwise.
 *
 * @see removeNotificationsForApplication:
 */
-(BOOL)addNotificationsForApplication:(NSDictionary*)app;

/**
 * Remove notifications for the application.
 * 
 * @param app
 *        Dictionary containing the constants described in NSWorkspace to specify what application to observe.
 * @return YES if any notifications were added, NO otherwise.
 *
 * @see addNotificationsForApplication:
 */        
-(BOOL)removeNotificationsForApplication:(NSDictionary*)app;

#pragma mark NSNotification methods
/**
 * Notification method to call when an application was launched.  This will add it to the observed applications.
 *
 * @param notification
 *        NSNotification with a userDict containing the constants describing the application which was launched.
 */
-(void)workspaceDidLaunchApplication:(NSNotification*)notification;

/**
 * Notification method to call when an application was terminated.  This will remove it from the observed applications.
 *
 * @param notification
 *        NSNotification with a userDict containing the constants describing the application which was terminated.
 */
-(void)workspaceDidTerminateApplication:(NSNotification*)notification;

/**
 * Notification method to call when a sound finished playing.
 * 
 * @param notification
 *        NSNotification with an object containing the QTMovie that finished playing.
 */
-(void)soundFinished:(NSNotification*)notification;

/**
 * Clear the "do not play" flag
 */
-(void)removeLimitOnFilename:(NSString*)filename;
@end
