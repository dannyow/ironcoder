// BWHedgeMaze.h -- interface to the maze game.  Not much CG used here
// 	            outside of a CGPatternReft used to draw the grass
//		    tiles.  Most of the work is in the maze algorithm, which
//		    is pretty crude

#import "BWRaceView.h"

typedef struct Cell {
    int row, column;
} Cell;

#define MAZE_WIDTH 14
#define MAZE_HEIGHT 12

// the maze is a 2-D array of ints, which is a bitmask indicating which
// walls currently exist.  Adjacent cells that share a wall actually each
// have the opposite wall set.

typedef enum Direction {
    kWest = 0x01,
    kSouth = 0x02, 
    kEast = 0x04, 
    kNorth = 0x08,
    kAll = 0x0F,

    // used during generation to know whether to ignore this cell.
    kVisited = 0x10

} Direction;



@interface BWHedgeMazeView : BWRaceView
{
    // the maze.
    unsigned char maze[MAZE_HEIGHT][MAZE_WIDTH];

    // where the player's location is
    Cell currentLocation;

    // the grass pattern
    CGImageRef grass;
    CGPatternRef grassPattern;

    // to get the same mazes each time the program is run.  The mazes
    // change from play to play.  Used to seed srand()
    int playCount;
}

@end // BWHedgeMazeView

