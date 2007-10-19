//
//  alifeGene.h
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/31/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
From : http://www.cs.bgu.ac.il/~sipper/courses/ecal051/e3.html
Ant functions and terminals. The functions and terminals are executed to move the ant on the grid 
    during evaluation:

        0 : if_food_ahead(a,b) : if the ant faces a food pellet then evaluate a, else evaluate b
        1 : progn2(a,b) : evaluate a, then b, returning b's value
        2 : progn3(a,b,c) : evaluate a, b then c, returning c's value
        3 : left : turn the ant left by 90 degrees
        4 : right : turn the ant right by 90 degrees
        5 : move : move the ant forward by one square/step
        Genes represent the state machine used to determine behavior.
        Think of it as a list of numbers.  Each number represents either a function or a term action
        in the grammar.  Current state is the current point of evaluation in the list.

*/



@interface alifeGene : NSObject <NSCoding>{
    unsigned int marker, evalParam;
    NSMutableDictionary *params;
}
- (id)randomInitWithDepth:(int)depth;
- (id)initWithMarker:(unsigned int)value;
- (id)initWithMarker:(unsigned int)value andParameters:(NSDictionary*)dict;
- (unsigned int)marker;
- (void)addParameters;
- (id)parameters;
- (void)setParameters:(NSDictionary*)values;
- (id)actionGene;
- (BOOL)isTerminal;
- (int)evalPoint;
- (void)incrementEvalPoint;
- (void)setEvalPoint:(int)value;

- (NSString*)geneAsString;
- (NSData*)geneAsData;

@end
