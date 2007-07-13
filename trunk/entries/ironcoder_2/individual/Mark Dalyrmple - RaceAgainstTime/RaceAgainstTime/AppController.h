// AppController - application controller.  One-stop-shopping for the 
//                 coordinating logic

#import <Cocoa/Cocoa.h>

@class BWRaceView;
@class BWStatusView;
@class BWMenuView;
@class BWMouseMotionWindow;
@class BWTimerView;

@interface AppController : NSObject
{
    // Special window that'll send mouse motion events directly
    // to the view that wants them, without firstResponder nonsense.
    IBOutlet BWMouseMotionWindow *mainWindow;

    // The main menu screen.
    BWMenuView *menuView;

    // The bar at the top that contains the timers.
    BWStatusView *statusView;

    // The 7-segment LED displays.  The first is the countdown timer,
    // the second shows the previous low-score for the game
    BWTimerView *timerView;
    BWTimerView *timeToBeatView;

    // All of the views that let you play games.  To add a new game,
    // subclass BWRaceView and add it to this list
    NSMutableArray *gameViews;

    // The currently displaying view.  Might be a menu, or a game.
    BWRaceView *currentView;
}

// nil to swap back to main menu

// Display a game view in the main window.  Pass nil to switch back to
// the menu window.  This is what game views use to go back to the main
// menu once they're done.

- (void) swapToView: (BWRaceView *) view;

// The count-down timer.  Unfortunately the timer logic is glommed
// together with the view.  Game views use this to start and stop
// the timer.

- (BWTimerView *) timerView;

// Menu item action to reset the user back to clean-slate, so they can
// get high (low?) scores again.

- (IBAction) resetCurrentTimes: (id) sender;

@end // AppController

