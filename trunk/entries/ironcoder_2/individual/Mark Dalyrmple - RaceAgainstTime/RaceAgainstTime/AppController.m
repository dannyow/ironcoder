#import "AppController.h"

#import "BWStatusView.h"
#import "BWTimerView.h"

#import "BWMenuView.h"
#import "BWHedgeMazeView.h"
#import "BWUnicornQuestView.h"

#import "BWMouseMotionWindow.h"

// how tall and how wide to make the countodwn timer.
#define STATUS_BAR_HEIGHT 76
#define TIMER_WIDTH 170

@implementation AppController

// Clean up the mess. 
// !!! this is probably incomplete.  Currently the app never disposes of
// !!! any game views it makes, nor does the controller ever get nuked.

- (void) dealloc
{
    [gameViews release];
    [menuView release];
    [statusView release];

    [super dealloc];

} // dealloc


// Create the game views, position the countdown timer and status bar

- (void) awakeFromNib
{
    // the gmae takes over the entire window, so get its size.
    NSRect frame;
    frame.origin = NSZeroPoint;
    frame.size = [mainWindow frame].size;

    // the main play area needs to skip over the status bar
    frame.size.height -= STATUS_BAR_HEIGHT;

    // the game view and status view are added as children of
    // the content view.  The timer views are children of the
    // status view.
    NSView *contentView = [mainWindow contentView];

    // add the menu
    menuView = [[BWMenuView alloc] initWithFrame: frame
                                   controller: self];
    [contentView addSubview: menuView];

    // make the games.  A decent programmer would have some
    // kind of regitration abstraction to make this more concise.x
    gameViews = [[NSMutableArray alloc] init];
    
    BWRaceView *view;
    view = [[BWHedgeMazeView alloc] initWithFrame: frame
                                    controller: self];
    [gameViews addObject: view];
    [view release];

    view = [[BWUnicornQuestView alloc] initWithFrame: frame
                                       controller: self];
    [gameViews addObject: view];
    [view release];

    // Tell the menu what games are available.  These will be shown
    // as a menu the user can choose from.
    [menuView setGameViews: gameViews];
    

    // now place the status line at the top

    frame.origin.y = frame.size.height;
    frame.size.height = STATUS_BAR_HEIGHT;

    statusView = [[BWStatusView alloc] initWithFrame: frame];
    [contentView addSubview: statusView];

    // stick in the timers.  The countdown timer goes at the very right.
    frame.origin.x = frame.origin.x + frame.size.width - TIMER_WIDTH;
    frame.origin.y = 0.0;
    frame.size.width = TIMER_WIDTH;

    timerView = [[BWTimerView alloc] initWithFrame: frame];
    [timerView setSegmentColor: [NSColor orangeColor]];
    [statusView addSubview: timerView];

    // the "last low score" timer view gets put some space to the
    // left of the countdown timer

    frame.origin.x -= TIMER_WIDTH * 2;
    timeToBeatView = [[BWTimerView alloc] initWithFrame: frame];
    [timeToBeatView setSegmentColor: [NSColor grayColor]];
    [statusView addSubview: timeToBeatView];

    // hide it on the main menu - it only makes sense in a game-play
    // context
    [timeToBeatView setHidden: YES];

    currentView = menuView;

    // Games may want to use mouse motion, so turn them on
    [mainWindow setAcceptsMouseMovedEvents: YES];

    // this is the view that wants the motion events.
    [mainWindow setMotionTarget: menuView];

} // awakeFromNib



// put a different view in the main play area of the window.
// nil means to boing back to the main menu view.

- (void) swapToView: (BWRaceView *) view
{
    // turn off the motion stream
    [mainWindow setMotionTarget: nil];

    // don't let the currently displaying view get destroyed while
    // it's in limbo land
    [currentView retain];
    [currentView removeFromSuperview];


    if (view == nil) {
        view = menuView;
    }
    currentView = view;

    // Putx the new view into the window
    NSView *contentView = [mainWindow contentView];
    [contentView addSubview: view];

    // feed it motion events, and make sure it's first
    // responder in case it wants to get key events.
    [mainWindow setMotionTarget: view];
    [mainWindow makeFirstResponder: currentView];

    // Tell the 'last low score' what the current low score is.
    int *bestTime = [view bestTime];
    [timeToBeatView setTime: bestTime];

    // show the 'last low score' if there actually is a low score.
    // The menu view says it has a low score of 99:99:99, which is
    // th magic flag for having a score, so that's how it gets
    // hidden for the menu view.
    
    if (bestTime[0] == 99) {
        [timeToBeatView setHidden: YES];
    } else {
        [timeToBeatView setHidden: NO];
    }

} // swapToView



// return the timer view - game views use this to turn on and off
// the timer

- (BWTimerView *) timerView
{
    return (timerView);
} // timerView



// The user decides they can't beat their own low scores any more,
// so zero them out and save it, as if it was a fresh start.

- (IBAction) resetCurrentTimes: (id) sender
{
    int i;
    for (i = 0; i < [gameViews count]; i++) {
        BWRaceView *view = [gameViews objectAtIndex: i];
        [view resetBestTime];
        [view saveBestTime];
    }
    [menuView setNeedsDisplay: YES];

} // resetCurrentTimes


@end // AppController

