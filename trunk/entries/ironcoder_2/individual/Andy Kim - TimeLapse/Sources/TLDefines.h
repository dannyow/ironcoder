/*
 *  TLFunctions.h
 *  TimeLapse
 *
 *  Created by Andy Kim on 7/23/06.
 *  Copyright 2006 Potion Factory. All rights reserved.
 *
 */

#define MAX_SCREENSHOT_WIDTH 1024
#define NSRectToCGRect(r) CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height)


// Debugging helpers

// Hybrid of printf and NSLog
#define print(format, ...)												\
printf("%s\n", [[NSString stringWithFormat:[NSString stringWithUTF8String:format], ##__VA_ARGS__] UTF8String])

#define printobj(obj) \
print("%@", obj)

// Print method signature
#define SIG											\
printf("----------------------------------------\n"); \
printf("%s\n", __PRETTY_FUNCTION__);
