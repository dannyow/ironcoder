//
//  FSBInvisibleWindow.h
//  FreeSpaceBall
//
//  Created by Henry Skelton on 10/28/06.
//  Copyright 2006 Henry Skelton. All rights reserved.
//


#import <Cocoa/Cocoa.h>

/*!
	@class			FSBInvisibleWindow
	@abstract		This object is an invisible NSWindow.
	@discussion		This is exactly like and NSWindow, but the init method causes it to be invisible.
*/
@interface FSBInvisibleWindow : NSWindow {

}

/*!
	@method			initWithContentRect
	@discussion		This is like a standard NSWindow init, but it creates an invisible window
	@result			An invisible NSWindow is created
 */
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;

@end
