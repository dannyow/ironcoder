#import "JTView.h"
#import "SSView.h"

@implementation JTView

- (id)initWithFrame:(NSRect)frameRect
{
	NSRect theScreenRect = [[NSScreen mainScreen] frame];

	return( [[SSView alloc] initWithFrame:theScreenRect isPreview:YES] );
}

- (void)drawRect:(NSRect)rect
{
}

@end
