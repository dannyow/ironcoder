//
//  GLDebug.h
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define GLDebug(s,...) \
    [GLDebug logFile:__FILE__ lineNumber:__LINE__ \
          format:(s),##__VA_ARGS__]


#define GL_DEBUG_FILE @"/Users/scanfield/Desktop/GLDEBUG.txt"
@interface GLDebug : NSObject {
}
+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber
       format:(NSString*)format, ...;
+ (void)writeToFile;
@end
