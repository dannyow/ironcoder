// BWUnicornView.h -- OMG Ponies!  Game to catch X number of unicorns.

#import "BWRaceView.h"

// number of unicorns to display on the screen
#define UNICORN_COUNT 30

// total number of unicorns to catch
#define TOTAL_COUNT 150

@interface BWUnicornQuestView : BWRaceView
{
    // unicorn image
    CGImageRef unicorn;

    // image mask - used to clip, and throug the clip draw acolor
    CGImageRef unicornMask;

    // how big the unicorn is
    CGSize unicornSize;

    // number of unicorns left to count
    int totalCount;

    // these are the visible unicorns.  If visible, it'll be drawn
    // points is where to draw it, and then the color
    BOOL visible[UNICORN_COUNT];
    NSPoint points[UNICORN_COUNT];
    float red[UNICORN_COUNT];
    float green[UNICORN_COUNT];
    float blue[UNICORN_COUNT];

    // timer used to jiggle the unicorns around
    NSTimer *timer;

    // where the "X" the user controls
    NSPoint whacker;

    // the cursor image to display
    CGImageRef whackerImage;
}

@end // BWUnicornQuestView

