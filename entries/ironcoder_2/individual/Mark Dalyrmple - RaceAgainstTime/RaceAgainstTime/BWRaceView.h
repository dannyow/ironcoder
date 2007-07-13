// BWRaceView.h -- base class for RaceAgainstTime views.  Has some handy
//		   utilities.

#import "BWCGView.h"

@class AppController;

@interface BWRaceView : BWCGView
{
    // the application controller, used to swap back to the menu
    // view when done, and used to access the on-screen timer so it
    // can be started and stopped
    AppController *controller;

    // The current 'low score', ordered as minutes, seconds, and tenths.
    int bestTime[3];

    // The game is done playing
    BOOL done;

    // The current game is the new low score.
    BOOL isBestTime;
}

// subclasses should override these two

// The display name of the game view

- (NSString *) name;


// The key to use in user preferences to store the lowest score for
// the game.  Return nil to not store scores for this view.

- (NSString *) bestTimePrefKey;


// designated initalizer

- (id) initWithFrame: (NSRect) frame
          controller: (AppController *) controller;


// get the controller for the app

- (AppController *) controller;

// get the best time (array of three ints: minutes, seconds, tenths)

- (int *) bestTime;

// pretend there is no more best time (actually use values of 99 for each
// value

- (void) resetBestTime;

// preserve the low score to the user prefs, and restore it from there
- (void) saveBestTime;
- (void) loadBestTime;


// handy utilities.

// draw a single line of text i na given font and size, optionally
// with a drop-shadow.  Draws the text in blue (probably should pass
// in a color too.  v2.0)
- (void) drawMenuText: (NSString *) text
                 font: (const char *) fontName
                 size: (float) size
               origin: (NSPoint) origin 
            inContext: (CGContextRef) context
           drawShadow: (BOOL) drawShadow;

// Get the bounding rectangle for text given a fond and a size

- (NSRect) boundsForMenuText: (NSString *) text
                        font: (const char *) fontName
                        size: (float) size
                      origin: (NSPoint) origin;

@end // BWRaceView

