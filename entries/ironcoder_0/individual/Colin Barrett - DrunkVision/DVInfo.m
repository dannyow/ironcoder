//
//  DVInfo.m
//  DrunkVision
//
//  Created by Colin Barrett on 3/5/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DVInfo.h"

@implementation DVInfo

/**
 * @brief Dig into the guts of the Accessibility API
 *
 * @param point Carbon-centric (top-left origined) point to inspect
 * @return NSDictionary with keys defined in DVInfo.h, contains information about the name of the application and the
 * title of the window the mouse is currently over.
 *
 * All of the Acessibility API calls are in this method. To avoid slowing things down, we only talk to the API once per
 * cycle, in this method. The alternative is to call in to the API twice, once of the name and once for the window.
 * There was actually a noticable speed hit.
 */
+ (NSDictionary *)getInfoForPoint:(NSPoint)point
{

	//Set up our dictionary to be non-nil.
	NSDictionary *returnDict = [NSMutableDictionary dictionary];
	AXUIElementRef element = NULL, systemWide = NULL;
	
	//We must call this first, or nothing works (??? @ Apple)
	if (AXAPIEnabled()) {
		//Get the system-wide accessibility context
		systemWide = AXUIElementCreateSystemWide();
		//Try to get the element at our current position
		if (AXUIElementCopyElementAtPosition(systemWide, point.x, point.y, &element) == kAXErrorSuccess) {
			//If we succeed, try getting the name of the app via the PID
			pid_t appPID = 0;
			ProcessSerialNumber appPSN = {0,0};
			FSRef loc;
			//try to get the PID of element, then the corresponding PSN and path to bundle
			if (AXUIElementGetPid(element, &appPID) == kAXErrorSuccess
				&& GetProcessForPID(appPID, &appPSN) == noErr
				&& GetProcessBundleLocation(&appPSN, &loc) == noErr) {
				
				//If it works, try to get the process name from the Process Manager API
				NSString *name = nil;
				if (CopyProcessName(&appPSN, (CFStringRef *)&name) == noErr) {
					//We got something, so stick it in the dictionary
					[returnDict setValue:name forKey:DV_INFO_APP_NAME];
					//Clean up our memory on the heap. The rest is on stack, it will be disposed of.
					[name release];
				}
			}
			
			//Next, try getting the window of this element we found
			AXUIElementRef window = NULL;
			if (AXUIElementCopyAttributeValue(element, kAXWindowAttribute, (CFTypeRef *)&window) == kAXErrorSuccess) {
				//If we find a window, try to get its title
				NSString *title = nil;
				if (AXUIElementCopyAttributeValue(window, kAXTitleAttribute, (CFTypeRef *)&title) == kAXErrorSuccess)  {
					//Store our found title
					[returnDict setValue:title forKey:DV_INFO_WINDOW_TITLE];
					//Clean up
					[title release]; 
				}
				
				//If we couldn't find an Application name from Process Manager, try the Accessibility API.
				//Empirical data showed the PM API to return results more frequently, so it is tried first
				if (![returnDict valueForKey:DV_INFO_APP_NAME]) {
					//See if this window has a parent
					NSString *name = nil; 
					AXUIElementRef application = NULL;
					if (AXUIElementCopyAttributeValue(window, kAXParentAttribute, (CFTypeRef *)&application) == kAXErrorSuccess) {
						//If it does, it must be have the AXApplicationRole, which is what we want. Try getting the title!
						if (AXUIElementCopyAttributeValue(application, kAXTitleAttribute, (CFTypeRef *)&name) == kAXErrorSuccess)  {
							//Save the name of the app...
							[returnDict setValue:name forKey:DV_INFO_APP_NAME];
							//..and clean up the memory
							[name release];
						}
						
						//The next lines are just cleaning up data that we need to release
						CFRelease(application);
					}
				}
				CFRelease(window);
			}
			CFRelease(element);
		}
		CFRelease(systemWide);
	}

	//Return our dictionary, packed full of info.
	return returnDict;
}

@end
