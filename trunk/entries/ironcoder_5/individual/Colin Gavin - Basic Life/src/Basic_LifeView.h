#import <ScreenSaver/ScreenSaver.h>
#import <QuartzComposer/QuartzComposer.h>
@interface Basic_LifeView : ScreenSaverView 
{
	NSString *bases;
	NSDictionary *amino_mapping;
	QCView *rendering_view;
	int pairs_showing;
	int current_position;
}

@end
