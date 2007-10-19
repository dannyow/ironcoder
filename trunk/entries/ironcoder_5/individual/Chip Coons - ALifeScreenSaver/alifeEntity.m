//
//  alifeEntity.m
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/30/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import "alifeEntity.h"

#import <ScreenSaver/ScreenSaver.h>

enum directions{
    north = 0,
    east,
    south,
    west
    };

#define MAX_VALUE(x,y) ((x <= y) ? (y) : (x))

@implementation alifeEntity

- (id)init;
{
    if(![super init])
        return nil;
    
    stackArray = [[NSMutableArray arrayWithCapacity:10] retain];
    genes = [[[alifeGene alloc] init] retain];
    //currentEvaluationPoint = genes;
    generation = 0;
    age = 0;
    heading = east;
    x = 0;
    y = 31;
    food = 0;
    return self;
}

- (id)initWithRandomGenes;
{
    if(![super init])
        return nil;
	
    stackArray = [[NSMutableArray arrayWithCapacity:10] retain];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    genes = [[[alifeGene alloc] randomInitWithDepth:5] retain];
    //currentEvaluationPoint = genes;
    generation = 0;
    age = 0;
    heading = east;
    x = 0;
    y = 31;
    food = 0;
    
    [pool release];
    
    return self;
}

- (void)dealloc;
{
    [genes release];
    currentEvaluationPoint = nil;
    [stackArray release];
    [super dealloc];
}

- (alifeGene *)genes;
{
    return genes;
}

- (void)setGenes:(alifeGene*)value;
{
    [value retain];
    [genes release];
    genes = value;
    currentEvaluationPoint = genes;
}

- (alifeGene *)currentGeneticMarker;
{
    return currentEvaluationPoint;
}

- (NSPoint)currentLocation;
{
    return NSMakePoint(x, y);
}


- (unsigned int)generation;
{
    return generation;
}

- (void)setGeneration:(unsigned int)value;
{
    generation = value;
}

- (int)currentHeading;
{
    return heading;
}

- (unsigned int)currentAge;
{
    return age;
}

- (unsigned int)currentDepth;
{
    return [stackArray count];
}


- (void)reset:(unsigned int)newGeneration;
{
    generation = newGeneration;
    age = 0;
    heading = east;
    x = 0;
    y = 31;
    food = 0;
}

- (void)turnLeft;
{
    heading--;
    if(heading < 0)
        heading = 3;
    
}

- (void)turnRight;
{
    heading++;
    heading = heading % 4;
}

- (void)move;
{
    switch(heading){
        case north:{
            y++;
            y = y % 32;
            break;
        }
        case east: {
            x++;
            x = x % 32;
            break;
        }
        case south:{
            y--;
            if(y<0)
                y = 31;
            break;
        }
        case west:{
            x--;
            if(x < 0)
                x = 31;
            break;
        }
        default: NSLog(@"%s >> bad value in currentHeading", _cmd);
    }
}

- (BOOL)foodAhead:(alifeMap*)map;
{
    int px = x;
    int py = y;
    
    switch(heading){
        case north:{
            py++;
            py = py % 32;
            break;
        }
        case east: {
            px++;
            px = px % 32;
            break;
        }
        case south:{
            py--;
            if(py<0)
                py = 31;
            break;
        }
        case west:{
            px--;
            if(px < 0)
                px = 31;
            break;
        }
        default: NSLog(@"%s >> bad value in currentHeading", _cmd);
    }
    NSPoint aPoint = NSMakePoint(px,py);
    
    return [map locationContainsFood:aPoint];
}

- (void)executeStepOnMap:(alifeMap*)aMap;
{
	
    if([aMap locationContainsFood:[self currentLocation]]){
        food++;
        [aMap setValue:0 atLocation:[self currentLocation]];
    }
    
	[aMap markLocation:[self currentLocation]];

    [self walk:aMap];
    age++;
}

- (void)walk:(alifeMap*)aMap;
{
    // alternative implementation with stack from the start;
    if((currentEvaluationPoint == nil)){
        currentEvaluationPoint = genes;
        [self flush];
        [currentEvaluationPoint setEvalPoint:0];
    }
    
    
    if([currentEvaluationPoint isTerminal]){
        [self takeTerminalAction];
        currentEvaluationPoint = [self pop];
    }else{
        //only terminal acrions in grammar should have eval point == 0
        [self push:currentEvaluationPoint];
        [currentEvaluationPoint incrementEvalPoint];
        currentEvaluationPoint = [self nextAction:aMap];
    }
    
    
}

- (alifeGene *)nextAction:(alifeMap*)aMap;
{
    
    if([currentEvaluationPoint marker]==0){
        if([self foodAhead:aMap]){
            [currentEvaluationPoint setEvalPoint:1];
        }else{
            [currentEvaluationPoint setEvalPoint:2];
        }	
    }
    
    return [currentEvaluationPoint actionGene];
}


- (void)takeTerminalAction;
{
    //take appropriate action
    switch([currentEvaluationPoint marker]){
        case 3: [self turnLeft];
            break;
        case 4: [self turnRight];
            break;
        case 5: {
            [self move];
            break;
        }	
    }
}

- (void)push:(id)value;
{
    if(value == nil)
        return;
        
    [stackArray insertObject:value atIndex:0];
}

- (id)pop;
{
    if([stackArray count] <= 0)
        return nil;
        
    id top = [stackArray objectAtIndex:0];
    [stackArray removeObjectAtIndex:0];
    
    return top;
}

- (id)top;
{
    if([stackArray count] <= 0)
        return nil;
    
    id top = [stackArray objectAtIndex:0];

    return top;
}

- (void)flush;
{
    [stackArray removeAllObjects];
}

- (unsigned int)fitness;
{
	return food;
}

- (void)setFitness:(unsigned int)value;
{
    food = value;
}

// allow two entities to breed

- (alifeGene *)spliceGene:(alifeGene *)fullGene;
{
    // last minnute bug found
    alifeGene *result;
    if([fullGene isTerminal]){
        result = fullGene;
    }else{
        int branch = SSRandomIntBetween(1, [[fullGene parameters] count]);
        switch(branch){
            case 1:{
                result = [[fullGene parameters] valueForKey:@"a"];
                break;
            }
            case 2:{
                result = [[fullGene parameters] valueForKey:@"b"];
                break;   
            }
            case 3:{
                result = [[fullGene parameters] valueForKey:@"c"];
                break;   
            }
        }
    }
    
    return result;
}

- (alifeEntity *)breedWith:(alifeEntity*)partner;
{
    alifeGene *plasm;
    
    alifeEntity *result = [[alifeEntity alloc] init];
    if(!result)
	    return nil;
    
    [result setGeneration:MAX_VALUE([self generation], [partner generation])];

    if([[self genes] isTerminal]){
        plasm = [[alifeGene alloc] initWithMarker:1];
        [[plasm parameters] setValue:[self genes] forKey:@"a"];
        [[plasm parameters] setValue:[self spliceGene:[partner genes]] forKey:@"b"];
    }else{
        // set param b to be a splice
        plasm = [[[alifeGene alloc] initWithMarker:[[self genes] marker]] retain];
        [[plasm parameters] setValue:[self genes] forKey:@"a"];
        [[plasm parameters] setValue:[self spliceGene:[partner genes]] forKey:@"b"];
        if([[self genes] marker] == 2){
            [[plasm parameters] setValue:[self spliceGene:[self genes]] forKey:@"c"];
        }
    }
    
    [result setGenes:plasm];
    [plasm release];
    
    return result;
}


- (NSComparisonResult)compareFitness:(alifeEntity *)aValue;
{
    int a, b;
    NSComparisonResult result;
    
    a = [self fitness];
    b = [aValue fitness];
    if(a < b){
        result = NSOrderedDescending;
    }else if(a==b){
        result = NSOrderedSame;
    }else{
        result = NSOrderedAscending;
    }
    return result;
}

@end
