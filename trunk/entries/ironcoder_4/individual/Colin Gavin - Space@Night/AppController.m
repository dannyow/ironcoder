#import "AppController.h"
#import <ApplicationServices/ApplicationServices.h>
#import "CGNightView.h"
@implementation AppController
- (void) applicationDidFinishLaunching:(NSNotification*)notification{
	//setup the desktop window
	NSRect frame;
	NSRect screen = [[NSScreen mainScreen] frame];
	frame = screen;
	frame.size.height -= 22;	
	desktop = [[NSWindow alloc] initWithContentRect:frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[desktop setContentView:spaceView];
	[desktop setLevel:-2147483628];
	int *tag = malloc(sizeof(int));
	*tag = 0x0200;
	CGSSetWindowTags(_CGSDefaultConnection(), [desktop windowNumber], tag, 32);
	[desktop orderFront:self];
	
	//setup the stars
	srandom(time(NULL));
	int i = 0;
	int num = floor(random()/100000000);
	num *= 2;
	num = floor(num);
	num += 5;
	NSMutableArray *stars = [[NSMutableArray alloc] init];
	for(i = 0; i < num; i++){
		CGStar newStar;
		srandom(i);
		newStar.radius = floor(random() / 100000000);
		newStar.radius /= 3.5;
		newStar.color = [[NSColor colorWithDeviceRed:random() / 100000000 green:random() / 1000000000 blue:random() / 1000000000 alpha:1.0] retain];
		newStar.center.x = random() / 1000000;
		newStar.center.x /= 1.5;
		newStar.center.y = random() / 1000000;
		newStar.center.y /= 1.5;
		newStar.on = (random() / 1000000) - 600 > 0;
		[stars addObject:[NSValue value:&newStar withObjCType:@encode(CGStar)]];
	}
	[spaceView setStars:stars];
	[spaceView setNeedsDisplay:YES];
	id timer = [NSTimer timerWithTimeInterval:0.8 target:spaceView selector:@selector(update) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	
	//setup the menu
	NSStatusItem *item = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[item setMenu:menu];
	[item setHighlightMode:YES];
	[item setTitle:@"space"];
}
@end
