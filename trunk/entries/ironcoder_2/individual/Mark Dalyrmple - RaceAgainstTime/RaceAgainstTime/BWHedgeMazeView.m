// Maze game.  user runs around the maze trying to get to the exit in 
// the upper-right

#import "BWHedgeMazeView.h"
#import "AppController.h"
#import "BWTimerView.h"
#import "BWShader.h"

@implementation BWHedgeMazeView

// --------------------------------------------------
// maze generation
// this is all prety fugly - written after midnight.  It's bascially
// a depth-first-search as descirbed here
// http://en.wikipedia.org/wiki/Maze_generation_algorithm

// given a cell, return (in neighbors array, at least 5 Cells large)
// a list of all unvisited neighbors (N S E W).
// returns how many were found

- (int) fillNeighbors: (Cell *) neighbors  forRow: (int) row  
               column: (int) column
{
    // how many we've seen
    int count = 0;

    if (row > 0) {
        neighbors->row = row - 1;
        neighbors->column = column;
        if ((maze[neighbors->row][neighbors->column] & kVisited) == 0) {
            neighbors++;
            count++;
        }
    }

    if (row < MAZE_HEIGHT - 1) {
        neighbors->row = row + 1;
        neighbors->column = column;
        if ((maze[neighbors->row][neighbors->column] & kVisited) == 0) {
            neighbors++;
            count++;
        }
    }

    if (column > 0) {
        neighbors->row = row;
        neighbors->column = column - 1;
        if ((maze[neighbors->row][neighbors->column] & kVisited) == 0) {
            neighbors++;
            count++;
        }
    }

    if (column < MAZE_WIDTH - 1) {
        neighbors->row = row;
        neighbors->column = column + 1;
        if ((maze[neighbors->row][neighbors->column] & kVisited) == 0) {
            neighbors++;
            count++;
        }
    }

    return (count);

} // fillNeighbors


// knock a hole from one cell to another.  each cell has its own
// concept of walls (makes traversal checks easier that way),
// so knock out the corresponding bits between the two.

- (void) removeWallFromRow: (int) row1  column: (int) column1
                     toRow: (int) row2  column: (int) column2
{
    if (row1 == row2) {
        // east or west
        if (column1 < column2) {
            maze[row1][column1] &= ~kEast;
            maze[row2][column2] &= ~kWest;
        } else {
            maze[row1][column1] &= ~kWest;
            maze[row2][column2] &= ~kEast;
        }
    } else {
        // north or south
        if (row1 < row2) {
            maze[row1][column1] &= ~kNorth;
            maze[row2][column2] &= ~kSouth;

        } else {
            maze[row1][column1] &= ~kSouth;
            maze[row2][column2] &= ~kNorth;
        }
    }

} // removeWallFromRow



// recursive function.  visit a cell.  Find unvisited neighbors,
// randomly pick one and recurse.

- (void) growPathFromRow: (int) row  column: (int) column
{
    // visit the current cell
    maze[row][column] |= kVisited;

    // see who's lurking around.  whistle while you lurk.
    Cell neighbors[5];
    int count;
    count = [self fillNeighbors: neighbors  forRow: row  column: column];

    // nobody home.  give up
    if (count == 0) return;

    // keep looping until we've seen every neighbor
    int seenCount = count;

    do {
        // make sure everything didin't get visited by someone else.
        // Bail out if there's no work to be done
        BOOL loopdone = YES;
        int i;
        for (i = 0; i < count; i++) {
            if (!(maze[neighbors[i].row][neighbors[i].column] & kVisited)) {
                loopdone = NO;
            }
        }
        if (loopdone) break;

        // pick one at random
        int neighbor = rand() % count;

        // oops, might be visited, loop and try again.  This is kind
        // of pessimal in terms of # of loops, but it's a small maze
        if (maze[neighbors[neighbor].row][neighbors[neighbor].column]
            & kVisited) {
            // yeah yeah yeah, brute force
            continue;
        }

        // TEAR DOWN THE WALL!  TEAR DOWN THE WALL!
        [self removeWallFromRow: row  column: column
              toRow: neighbors[neighbor].row  
              column: neighbors[neighbor].column];

        // recurse and grow the path.
        [self growPathFromRow: neighbors[neighbor].row
              column: neighbors[neighbor].column];

        seenCount--;

    } while (seenCount > 0);

} // growPathFromRow


// populate the dungeon for a new game

- (void) omgDungies
{
    srand (playCount);

    // new game, so we're not done, and don't know yet if this
    // will be the best time.
    done = NO;
    isBestTime = NO;

    // initial user location
    currentLocation.row = currentLocation.column = 0;

    // BUILD UP THE WALLS!  BUILD UP THE WALLS!
    memset(maze, kAll, sizeof(maze));

    // grow a path through the maze
    [self growPathFromRow: MAZE_HEIGHT - 1  column: MAZE_WIDTH - 1];

    playCount++;

} // omgDungies


// the pattern drawing function.  draw the grass pattern, and CG will
// align thigns so it all joins together nicely

static void drawImage (void *info, CGContextRef context)
{
    BWHedgeMazeView *view = (BWHedgeMazeView *) info;

    CGRect rect;
    rect.origin = CGPointZero;
    rect.size.width = CGImageGetWidth(view->grass);
    rect.size.height = CGImageGetHeight(view->grass);

    CGContextDrawImage (context, rect, view->grass);

} // drawImage


// get the ball rolling

- (id) initWithFrame: (NSRect) frame  controller: (AppController *) c
{
    if ((self = [super initWithFrame: frame  controller: c])) {
        // get the grass pattern
        NSString *path;
        path = [[NSBundle mainBundle] pathForResource: @"grass"
                                      ofType: @"png"];
        grass = pngImageAtPath (path);

        // make the pattern and hang on to it.
        CGRect imagerect = CGRectMake(0, 0, CGImageGetWidth(grass),
                                      CGImageGetHeight(grass));
        CGPatternCallbacks callbacks = { 0, drawImage, NULL };
        
        grassPattern = CGPatternCreate 
            (self, imagerect, CGAffineTransformIdentity,
             CGImageGetWidth(grass),
             CGImageGetHeight(grass),
             kCGPatternTilingNoDistortion,
             YES,
             &callbacks);
    }

    return (self);

} // initWithFrame


// draw a cell, basically draw the walls.

- (void) drawCellAtRow: (int) row
                column: (int) column
                inRect: (NSRect) rect
             inContext: (CGContextRef) context
{
    int border = maze[row][column];

    // find the endpoints of the rectangle
    float maxX = truncf(NSMaxX(rect));
    float maxY = truncf(NSMaxY(rect));
    float minX = truncf(NSMinX(rect));
    float minY = truncf(NSMinY(rect));

    CGContextSaveGState(context); {

        // engage the pattern
        CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
        CGContextSetFillColorSpace (context, space);

        float alpha[1] = { 1.0 };
        CGContextSetFillPattern (context, grassPattern, alpha);
        
        // how large to make the walls
#define SHRUBBERY 15

        // make a rectangle and fill it on the appropraite side
        if (border & (kWest)) {
            CGContextFillRect (context,
                               CGRectMake(minX, minY,
                                          SHRUBBERY, 
                                          maxY - minY + SHRUBBERY));
        }
        if (border & (kNorth)) {
            CGContextFillRect (context,
                               CGRectMake(minX, 
                                          minY + rect.size.height, 
                                          maxX - minX + SHRUBBERY, 
                                          SHRUBBERY));
        }
        if (row == 0) {
            CGContextFillRect (context,
                               CGRectMake(minX, 
                                          minY,
                                          maxX - minX + SHRUBBERY, 
                                          SHRUBBERY));
        }
        if (column == MAZE_WIDTH - 1) {
            CGContextFillRect (context,
                               CGRectMake(minX + rect.size.width,
                                          minY,
                                          maxX - minX + SHRUBBERY, 
                                          rect.size.height));
        }

    } CGContextRestoreGState(context);

    // draw the user / exit blocks if we're on the proper cell

    // nubmers determiend through careful fiddling to make it look
    // non-sucky.
    rect = NSInsetRect(rect, 9, 9);
    rect.origin.x += 7;
    rect.origin.y += 7;

    if (row == MAZE_HEIGHT - 1 && column == MAZE_WIDTH - 1) {
        [[NSColor redColor] set];
        NSRectFill(rect);
    }
    if (row == currentLocation.row && column == currentLocation.column) {
        [[NSColor orangeColor] set];
        NSRectFill(rect);
    }

} // drawCellAtRow


// map a cell to the bounding rectangle

- (NSRect) rectForCell: (Cell) cell
{
    NSRect bounds = [self bounds];

    // tweak the bounds so we can draw a shrubbery row along the top
    // and right side
    bounds.size.height -= SHRUBBERY;
    bounds.size.width -= SHRUBBERY;

    float width, height;
    width = bounds.size.width / MAZE_WIDTH;
    height = bounds.size.height / MAZE_HEIGHT;

    NSRect rect = NSMakeRect (width * cell.column,
                              height * cell.row,
                              width, height);

    return (rect);

} // rectForCell



// draw the playfield

- (void) drawRect: (NSRect) rect  inContext: (CGContextRef) context
{
    // nice white background
    [self cleanSlate];

    // draw each cell
    int row, column;
    for (row = 0; row < MAZE_HEIGHT; row++) {
        for (column = 0; column < MAZE_WIDTH; column++) {
            Cell cell = { row, column };

            NSRect cellRect = [self rectForCell: cell];

            if (NSIntersectsRect(rect, cellRect)) {
                [self drawCellAtRow: row
                      column: column
                      inRect: cellRect
                      inContext: context];
            }
        }
    }

    // ++ refactor me - copied from unicorn game
    if (done) {
        NSRect bounds = [self bounds];

        BWShader *shader;
        shader = [BWAxialShader shaderWithStartColor: [NSColor orangeColor]
                                endColor: [NSColor magentaColor]
                                startPoint: NSMakePoint(30.0, 30.0)
                                endPoint: NSMakePoint(bounds.size.width - 30.0,
                                                      bounds.size.height - 30.0)
                                extendStart: YES
                                extendEnd: YES
                                colorSpace: [self rgbColorSpace]];
        [shader drawInContext: context];

        
        // draw WOO
        [self drawMenuText: @"WOOOOOOO!!!"
              font: "Marker Felt Wide"
              size: 100.0
              origin: NSMakePoint(180, 215)
              inContext: context
              drawShadow: NO];

        if (isBestTime) {
            // draw Best Time Evar
            [self drawMenuText: @"Best Score Ever!"
                  font: "Marker Felt Wide"
                  size: 50.0
                  origin: NSMakePoint(270, 165)
                  inContext: context
                  drawShadow: NO];
        }
    }
    // -- refactor me

} // drawRect


// the display name in the menu

- (NSString *) name
{
    return (@"Run The Hedge Maze!");
} // name



// exit the 'woo you won' screen with a click.

- (void) mouseUp: (NSEvent *) event
{
    if (done) {
        [controller swapToView: nil];
    }

} // mouseUp



// populate the dungeon when added to a widnow

- (void) viewDidMoveToSuperview
{
    if ([self superview] != nil) {
        [self omgDungies];

        [[controller timerView] start];

    } else {
        [[controller timerView] stop];
    }

} // didMoveToSuperview


// make sure user can move from the current cell in the given direction.

- (BOOL) canMoveFromCell: (Cell) cell
               direction: (Direction) direction
{
    BOOL canni = YES;

    unsigned char stuff = maze[cell.row][cell.column];;

    // check to see if there's a wall blocking our way

    if (stuff & direction) {
        canni = NO;
    }

    return (canni);

} // canMoveFromCell


// user hit the exit. yay

- (void) done
{
    [[controller timerView] stop];

    done = YES;

    [self setNeedsDisplay: YES];

    // ++ refactor me
    int *time = [[controller timerView] minutesSecondsTenths];
    isBestTime = NO;

    if (time[0] < bestTime[0]) {
        isBestTime = YES;
    } else if (time[0] == bestTime[0]) {
        if (time[1] < bestTime[1]) {
            isBestTime = YES;
        } else if (time[1] == bestTime[1]) {
            if (time[2] < bestTime[2]) {
                isBestTime = YES;
            }
        }
    }

    if (isBestTime) {
        int i;
        for (i = 0; i < 3; i++) {
            bestTime[i] = time[i];
        }
        [self saveBestTime];
    }
    // -- refactor me

} // done


// given a direction, figure out what the destination cell would be,
// see if a move can be made, and if so, do the move.  If hit the end,
// we're done.

- (void) tryMove: (Direction) direction
{
    int rowDelta, columnDelta;
    rowDelta = columnDelta = 0;

    switch (direction) {
    case kNorth:
        rowDelta++;
        break;
    case kSouth:
        rowDelta--;
        break;
    case kEast:
        columnDelta++;
        break;
    case kWest:
        columnDelta--;
        break;
    default:
        assert(!"oops");
    }

    Cell newCell = currentLocation;
    newCell.row += rowDelta;
    newCell.column += columnDelta;

    if ([self canMoveFromCell: currentLocation
              direction: direction]) {
        [self setNeedsDisplay: YES];
        currentLocation = newCell;

        if (currentLocation.row == MAZE_HEIGHT - 1
            && currentLocation.column == MAZE_WIDTH - 1) {
            [self done];
        }
    }

} // tryMove


// all interaction for this game is via keypresses.

- (void) keyDown: (NSEvent *) event
{
    NSString *characters;
    characters = [event characters];

    // in case just get dead keys.
    if ([characters length] == 0) return;

    unichar character;
    character = [characters characterAtIndex: 0];

    switch (character) {
    case 27: // escape
        [controller swapToView: nil];
        break;
    case NSUpArrowFunctionKey:
        [self tryMove: kNorth];
        break;
    case NSDownArrowFunctionKey:
        [self tryMove: kSouth];
        break;
    case NSLeftArrowFunctionKey:
        [self tryMove: kWest];
        break;
    case NSRightArrowFunctionKey:
        [self tryMove: kEast];
        break;
    }

} // keyDown


// gotta have this to get keypresses

- (BOOL) acceptsFirstResponder
{
    return (YES);
} // accpetsFirstResponder


// the key to store the current low-time into the user prefs.

- (NSString *) bestTimePrefKey
{
    return (@"hedgeFund");
} // bestTimePrefKey


@end // BWHedgeMazeView

