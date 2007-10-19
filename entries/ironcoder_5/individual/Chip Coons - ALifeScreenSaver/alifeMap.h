//
//  alifeMap.h
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/30/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
From : http://www.cs.bgu.ac.il/~sipper/courses/ecal051/e3.html
Ant functions and terminals. The functions and terminals are executed to move the ant on the grid 
    during evaluation:

    if_food_ahead(a,b) : if the ant faces a food pellet then evaluate a, else evaluate b
        progn2(a,b) : evaluate a, then b, returning b's value
        progn3(a,b,c) : evaluate a, b then c, returning c's value
        left : turn the ant left by 90 degrees
        right : turn the ant right by 90 degrees
        move : move the ant forward by one square/step

    Fitness measure. The fitness for this problem is measured as the number of pellets not picked 
    up by the ant. The ant is typically given a total of 600 time steps to collect food pellets, 
    where each terminal takes one time step to execute. Each candidate program is re-evaluated, 
    without re-initializing the ant, until all the food has been collected or the maximum number of 
    time steps is reached. That is, you treat the program as though it were a loop that executes 
    until all food has been found or time is up.
*/


@interface alifeMap : NSObject {
	unsigned int width;
	unsigned int height;
	NSMutableArray *field;
	
}
+ (NSArray*)defaultMapPoints;

- (void)setWidth:(unsigned int)value;
- (unsigned int)width;

- (void)setHeight:(unsigned int)value;
- (unsigned int)height;

- (NSMutableArray *)field;
- (void)initializeField;
- (void)clearField;
- (void)resetField;

- (BOOL)locationContainsFood:(NSPoint)loc;
- (int)valueAtLocation:(NSPoint)loc;
- (void)setValue:(int)value atLocation:(NSPoint)loc;
- (void)markLocation:(NSPoint)loc;

@end
