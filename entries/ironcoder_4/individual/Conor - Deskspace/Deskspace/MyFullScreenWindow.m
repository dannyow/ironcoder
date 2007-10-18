//
//  MyFullScreenWindow.m


#import "MyFullScreenWindow.h"
#import "MyDeskView.h"


@implementation MyFullScreenWindow

- (BOOL)canBecomeKeyWindow {
	return YES;
}


// Quit the app if they hit q, esc, period, command period or enter
- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	unichar characterHit = [[theEvent characters] characterAtIndex:0];
	if ( characterHit == 27 || characterHit == 13 || characterHit == 32 || characterHit == 127 || characterHit == 46) { //enter, delete, esc, period
		[NSApp terminate:self];
		return YES;
	}
	
	return NO;
}


- (void)keyDown:(NSEvent *)theEvent {
	unichar characterHit = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
		
	if (characterHit == 'q' || characterHit == 27 || characterHit == 13 || characterHit == 32 || characterHit == 127 || characterHit == 46) { //enter, delete, q, esc, period
		[NSApp terminate:self];
	}
	else 
		[super keyDown:theEvent];
}


@end
