//
//  TextBoxLayer.h
//  AdventureTime
//
//  Created by Nur Monson on 11/11/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface TextBoxLayer : CALayer {
	CATextLayer *_text;
	CALayer *_textBackground;
	CATextLayer *_name;
	CALayer *_nameBackground;
	
	CALayer *_cursor;
}

- (void)setString:(NSString *)newString;
- (NSString *)string;
- (void)setName:(NSString *)newName;
- (BOOL)doneDisplaying;
@end
