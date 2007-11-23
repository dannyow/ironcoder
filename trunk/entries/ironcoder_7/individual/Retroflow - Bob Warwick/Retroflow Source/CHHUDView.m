#import "CHHUDView.h"

@implementation CHHUDView

- (void)drawRect:(NSRect)rect {
	rect = [self bounds];
	[[NSColor blackColor] set];
	[NSBezierPath fillRect: rect];
	[self setAlphaValue:0.8];
}

@end
