//
//  GLDebug.m
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GLDebug.h"



@implementation GLDebug

static 	NSMutableString * debugString;

+ (void)initialize {
	debugString = [[NSMutableString alloc] init];
}

+(void)logFile:(char*)sourceFile lineNumber:(int)lineNumber
       format:(NSString*)format, ...;
{
	va_list ap;
	NSString *print,*file;
	va_start(ap,format);
	file=[[NSString alloc] initWithBytes:sourceFile 
                  length:strlen(sourceFile) 
                  encoding:NSUTF8StringEncoding];
	print=[[NSString alloc] initWithFormat:format arguments:ap];
	va_end(ap);
        //NSLog handles synchronization issues
	NSString * output = [NSString stringWithFormat:@"%s:%d %@\n",[[file lastPathComponent] UTF8String],
              lineNumber,print];
	[debugString appendString:output];
	
	
	
	[print release];
	[file release];
	
	return;
}

+ (void)writeToFile { 
	//[debugString writeToFile:GL_DEBUG_FILE atomically:YES];
}

@end
