//
//  alifeAppController.m
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/31/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import "alifeAppController.h"
#define maxRunTime 600;

NSString * const kEntityName = @"_entityName";
NSString * const kEntityFitness = @"_entityFitness";

@implementation alifeAppController

- (id)init;
{
    if(![super init])
        return nil;
    
    displayData = [[NSMutableDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInt:0], @"displayGeneration",
        [NSNumber numberWithInt:51], @"maxGenerations",
        [NSNumber numberWithInt:0], @"displayPopulation",
        [NSNumber numberWithInt:50], @"maxPopulation",
        [NSNumber numberWithInt:600], @"runTime",
        [NSNumber numberWithInt:0], @"avgFitness",
        [NSNumber numberWithInt:0], @"entityDepth",
        [NSNumber numberWithInt:0], @"entityHeading",
        [NSNumber numberWithInt:0], @"entityHealth",
        [NSNumber numberWithInt:89], @"remainingFood",
        nil] retain];
    
    totalPopulation = [[NSMutableArray arrayWithCapacity:[[displayData valueForKey:@"maxPoplulation"] intValue]] retain];
    [self buildPopulation];
    return self;
}

- (void)awakeFromNib;
{
    
    theMap = [[[alifeMap alloc] init] retain];
    myDisplay = [[[ALifeScreenSaverView alloc] initWithFrame:[screenView bounds] isPreview:YES] retain];
    [myDisplay setCurrentMap:theMap];
    [screenView addSubview:myDisplay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDisplay:)
                                                 name:@"NSViewFrameDidChangeNotification"
                                               object:nil];
}

- (void)dealloc;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [totalPopulation release];
    [myDisplay release];
    [displayData release];
    [theMap release];
    [super dealloc];
}


- (void)buildPopulation;
{
    int popCount = [[displayData valueForKey:@"maxPopulation"] intValue];
    int i;
    alifeEntity *entity;
    
    for(i=0; i < popCount; i++){
        entity = [[alifeEntity alloc] initWithRandomGenes];
        [totalPopulation addObject:entity];
        entity = nil;
    }
    
}

- (void)updateDisplay:(NSNotification*)notification;
{
    [myDisplay setFrame:[screenView bounds]];
}


- (int)runDuration;
{
    return (int)maxRunTime;
}


- (void)setRemainingRuntime:(int)value;
{
    if(value >= 0)
        [displayData setValue:[NSNumber numberWithInt:value] forKey:@"runTime"];
    else{
        [displayData setValue:[NSNumber numberWithInt:0] forKey:@"runTime"];
    }
    
}

- (int)currentGeneration;
{
    return [[displayData valueForKey:@"displayGeneration"] intValue];
}

- (int)currentEntityIndex;
{
    return [[displayData valueForKey:@"displayPopulation"] intValue];
}

- (void)setCurrentEntityIndex:(int)value;
{
    [displayData setValue:[NSNumber numberWithInt:value] forKey:@"displayPopulation"];
}

- (alifeEntity *)nextEntity;
{
    int index;
    index = [self currentEntityIndex];
    alifeEntity *result = [totalPopulation objectAtIndex:index];
    [self updateEntity:result];
    runs++;
    fit = fit + ([result fitness]/1.0);
    
    if(index >= [totalPopulation count]){
        // need new population
        NSLog(@"%s >> index beyond bounds", _cmd);
        result = nil;
    }else{
        result = [totalPopulation objectAtIndex:index];
        [self setCurrentEntityIndex:(index + 1)];
    }
    
    return result;
}


- (void)updateEntity:(alifeEntity*)anEntity;
{
    float f = [anEntity fitness];
    
    [displayData setValue:[NSNumber numberWithInt:[anEntity currentHeading]] forKey:@"entityHeading"];
    [displayData setValue:[NSNumber numberWithInt:[anEntity currentDepth]] forKey:@"entityDepth"];
    [displayData setValue:[NSNumber numberWithInt:[anEntity fitness]] forKey:@"entityHealth"];
    [displayData setValue:[NSNumber numberWithInt:(89 - [anEntity fitness]) ] forKey:@"remainingFood"];

    [displayData setValue:[NSNumber numberWithFloat:((fit + f)/(runs+1.0))] forKey:@"avgFitness"];
}

- (IBAction)startButton:(id)sender;
{
    if([[controlButton title] isEqualToString:@"Start"]){
        [myDisplay setController:self];
        [myDisplay setCurrentEntity:[self nextEntity]];
        [myDisplay startAnimation];
        [controlButton setTitle:@"Stop"];
    }else{
        [myDisplay stopAnimation];
        [controlButton setTitle:@"Start"];
    }
}


- (IBAction)skipEntity:(id)sender;
{
    [myDisplay skipEntity];
}

- (IBAction)seedPopulation:(id)sender;
{
    [totalPopulation release];
    totalPopulation = [[NSMutableArray arrayWithCapacity:[[displayData valueForKey:@"maxPoplulation"] intValue]] retain];
    [self buildPopulation];
}


- (IBAction)forceBreeding:(id)sender;
{
    [self startButton:self];
    
    // sort population by fitness
    [self sortPopulation];
    
    //kill low half of pop
    [self genocide];
    
    // top half breeds
    [self repopulate];
    
    // update population
    int genX = [[displayData valueForKey:@"displayGeneration"] intValue];
    genX++;
    [displayData setValue:[NSNumber numberWithInt:genX] forKey:@"displayGeneration"];
    [self setCurrentEntityIndex:0];
    [self resetPopulation];
    [theMap resetField];
    
    [self startButton:self];
    
}

- (void)sortPopulation;
{   
    NSMutableArray *temp = [NSMutableArray arrayWithArray:[totalPopulation sortedArrayUsingSelector:@selector(compareFitness:)]];
    [temp retain];
    NSLog(@"%s >> fitness of item at index[0] = %d", _cmd, [[temp objectAtIndex:0] fitness] );
    [totalPopulation release];
    totalPopulation = temp;

}

- (void)genocide;
{
    int len = [totalPopulation count];
    int halfway = len/2;
    
    NSRange killRange = NSMakeRange(halfway, (len-halfway) );
    [totalPopulation removeObjectsInRange:killRange];
    
}

- (void)repopulate;
{
    int len = [totalPopulation count];
    int maxPop = [[displayData valueForKey:@"maxPopulation"] intValue];
    int i = len+1;
    
    alifeEntity *item1;
    alifeEntity *item2;
    alifeEntity *child;
    
    int j, k;
    k = 0;
    
    while(i < maxPop){
        j = SSRandomIntBetween(0, len);
        item1 = [totalPopulation objectAtIndex:k];
        item2 = [totalPopulation objectAtIndex:j];
        child = [item1 breedWith:item2];
        [totalPopulation addObject:child];
        child = nil;
        i++;
    }
    
}

- (void)resetPopulation;
{
    unsigned int nextGen = [[displayData valueForKey:@"displayGeneration"] intValue];
    
    NSEnumerator *e = [totalPopulation objectEnumerator];
    alifeEntity *item;
    
    while(item = [e nextObject]){
        [item reset:nextGen];
    }
    
}

@end
