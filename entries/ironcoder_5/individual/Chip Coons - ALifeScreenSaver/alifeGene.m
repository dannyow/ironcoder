//
//  alifeGene.m
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/31/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import "alifeGene.h"

#define MAX_DEPTH 10

@implementation alifeGene

- (id)init;
{
    if(![super init])
        return nil;
    marker = 5;         // default to move statement
    evalParam = 0;
    params = nil;       // with no parameters
    return self;
}

- (void)dealloc;
{
    [params release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if(![super init])
        return nil;
    
    marker = [[coder decodeObjectForKey:@"marker"] intValue];
    [self setParameters:[coder decodeObjectForKey:@"params"]];
    evalParam = 0;
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[NSNumber numberWithInt:marker] forKey:@"marker"];
    [coder encodeObject:params forKey:@"params"];
    return;
}

- (id)initWithMarker:(unsigned int)value;
{
    if(![super init])
        return nil;
        
    marker = value;
    evalParam = 0;
    [self addParameters];
    return self;
}

- (id)initWithMarker:(unsigned int)value andParameters:(NSDictionary*)dict;
{
    if(![super init])
        return nil;
    marker = value;
    evalParam = 0;
    [self addParameters];
    [self setParameters:dict];
    return self;
}

- (void)addParameters;
{
    if(!params)
        [params release];
    
    
    switch(marker){
        case 0: 
        case 1: {
                params = [[NSMutableDictionary dictionaryWithCapacity:2] retain]; 
                evalParam = 1;
                break;
            }
        case 2: {
                params = [[NSMutableDictionary dictionaryWithCapacity:3] retain];    
                evalParam = 1;
                break;
            }
        default : params = nil;
        break;
    }
    
}



- (id)randomInitWithDepth:(int)depth;
{
    if(![super init])
        return nil;
    
    srand( time(NULL) );
    
    int nextDepth = depth - 1;
    
    if(depth <= 0){
        marker = (3 + SSRandomIntBetween(1, 2));
    }else{
        marker = SSRandomIntBetween(0, 5);
    }
    if(marker > 5)
        marker = 0;
        
    evalParam = 0;
    [self addParameters];
    
    if([self isTerminal])
        return self;
    
    switch(marker){
        case 0:
        case 1: [params setValue:[[alifeGene alloc] randomInitWithDepth:nextDepth] forKey:@"a"];
                [params setValue:[[alifeGene alloc] randomInitWithDepth:nextDepth] forKey:@"b"];
                break;
        case 2: [params setValue:[[alifeGene alloc] randomInitWithDepth:nextDepth] forKey:@"a"];
                [params setValue:[[alifeGene alloc] randomInitWithDepth:nextDepth] forKey:@"b"];
                [params setValue:[[alifeGene alloc] randomInitWithDepth:nextDepth] forKey:@"c"];
                break;
    }
    
    return [[self retain] autorelease];
}

- (unsigned int)marker;
{
    return marker;
}

- (int)evalPoint;
{
    return evalParam;
}

- (void)incrementEvalPoint;
{
    evalParam++;
/*    if((evalParam > [params count]) && ([params count] > 0))
        evalParam = 1;*/
    if((evalParam > [params count]) || (params == nil))
        evalParam = 0;
}

- (void)setEvalPoint:(int)value;
{
    evalParam = value;
    if((value > [params count]) || (value < 0))
        evalParam = 0;

}

- (id)parameters;
{
    return params;
}

- (void)setParameters:(NSDictionary*)values;
{
    if(params == values)
        return;
    
    [values retain];
    [params release];
    params = [[NSMutableDictionary dictionaryWithDictionary:values] retain];
}

- (NSString*)description;
{
    NSString *result;
    result = [self geneAsString];
    return [[result retain] autorelease];
}


- (id)actionGene;
{
    // return self if terminal otherwise, track which parameter is being evaluated and return it;
    if([self isTerminal])
        return self;
    id result;
    
    switch(evalParam){
        case 1: {
            result = [params valueForKey:@"a"];
            break;
        }
        case 2: {
            result = [params valueForKey:@"b"];
            break;
        }
        case 3: {
            result = [params valueForKey:@"c"];
            break;
        }
        default : result=nil;
        break;
    }

    return result;
}

- (BOOL)isTerminal;
{
    BOOL result = NO;
    if(marker > 2)
        result = YES;
    return result;
}



- (NSString*)geneAsString;
{
    NSString *result = nil;
    NSString *a, *b, *c;
    
    if([self isTerminal]){
        result = [NSString stringWithFormat:@"[%d]", marker];
    }else{
        switch(marker){
            case 0:
            case 1: {
                a = [[params objectForKey:@"a"] geneAsString];
                b = [[params objectForKey:@"b"] geneAsString];
                result = [NSString stringWithFormat:@" (%d, %@, %@) ", marker, a, b];
                break;
            }
            case 2:{
                a = [[params objectForKey:@"a"] geneAsString];
                b = [[params objectForKey:@"b"] geneAsString];
                c = [[params objectForKey:@"c"] geneAsString];
                result = [NSString stringWithFormat:@" (%d, %@, %@, %@) ", marker, a, b, c];
                break;
            }
        }
    }
    return result;
}


- (NSData*)geneAsData;
{
   return [NSKeyedArchiver archivedDataWithRootObject:self];
}

@end
