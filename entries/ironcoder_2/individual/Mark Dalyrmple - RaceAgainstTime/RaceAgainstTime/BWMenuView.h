// BWMenuView.h -- the main window screen.  This shows the happy clock guy,
// 		   the throbbing colored text, and the menu

#import "BWRaceView.h"

@interface BWMenuView : BWRaceView
{
    // The happy clock guy, and where to draw him
    CGImageRef appIcon;
    NSRect appIconBounds;

    // the timer that controls the changing of colors in the
    // application name.
    NSTimer *throbber;

    // color ramping stuff.  *Rgb is the color to be used at the 
    // beginning and end of the shading.  The *Up arrays indicate
    // which direction the R,G,B colors are moving (the components are
    // incremented or decremented by the timer.  Just having the values
    // wrapping around had jarring jumps to dark colors.
    BOOL startUp[3];
    int startRgb[3];
    BOOL endUp[3];
    int endRgb[3];

    // the set of games we can play.
    NSArray *gameViews;

    // This is the game title under the mouse.
    int selectedMenu; // -1 == no selection
}

// the controller tells us what game views are available so we know
// what to put in the menu.

- (void) setGameViews: (NSArray *) gameViews;

@end // BWMenuView


