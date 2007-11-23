#import "CHTransparentTableView.h"

@implementation CHTransparentTableView

- (void)awakeFromNib {
	[[self enclosingScrollView] setDrawsBackground: NO];
}

- (void)drawBackgroundInClipRect:(NSRect)clipRect {
	// don't draw a background rect
}

- (BOOL)isOpaque {
	return NO;
}

@end