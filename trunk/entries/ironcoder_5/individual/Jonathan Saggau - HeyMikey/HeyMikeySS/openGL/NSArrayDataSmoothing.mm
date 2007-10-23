//
//  NSArrayDataSmoothing.m
//  Exercise 20
//
//  Created by Jonathan Saggau on 9/22/06.
//  Copyright 2006 Jonathan Saggau. All rights reserved.
//

#import "NSArrayDataSmoothing.h"

NSNumber * averageArraySlice(NSArray *theArray, int startIndex, int endIndex)
{
    // *** Helper fn ***
    //Average a slice of an array given start and end (inclusive) indices
    //The output is autoreleased
    
    float output = 0.0;
    NSNumber *outNumber = [NSNumber numberWithInt:0];
    float divisor = 0.0;
    for (int i = startIndex; i <= endIndex; i++)
    {
        id currentObj = [theArray objectAtIndex:i];
        if ([currentObj respondsToSelector:@selector(floatValue)])
        {
            output += [currentObj floatValue];
            divisor += 1.0;
        }
    }
    // if divisor is still 0.0, we probably don't have any nsnumbers in range.
    // so we'll just call it 0.0 and get on with it.
    if (divisor == 0.0)
        output = 0.0;
    else
        output /= divisor;
    outNumber = [NSNumber numberWithFloat:output];
    return outNumber;
}

@implementation NSArray (NSArrayDataSmoothing)

- (NSArray *)movingAverageWithWidth:(int)width;
{
    int len = [self count];
    if (len < width)
        return [[self copy] autorelease]; 
        //make sure this method returns something autoreleased, even if it's empty
    
    NSMutableArray *avgArray = [NSMutableArray arrayWithCapacity:[self count] - width];
    int leftIndex = 0; //left inde
    for (int rightIndex = width; rightIndex < len; rightIndex++)
    {
        NSNumber * currentAvg = averageArraySlice(self, leftIndex, rightIndex);
        [avgArray addObject:currentAvg];
        leftIndex++;
    }
    return [NSArray arrayWithArray:avgArray];
}

- (NSArray *)paddedMovingAverageWithWidth:(int)width;
{
    int len = [self count];
    if (len < width)
        return [[self copy] autorelease]; 
    //make sure this method returns something autoreleased, even if it's empty
    
    NSMutableArray *avgArray = [NSMutableArray arrayWithCapacity:[self count]];
    NSNumber *padNumber = averageArraySlice(self, 0, width);
    for (int i = 0; i < width; i++)
    {
        [avgArray addObject:padNumber];
    }
    [avgArray addObjectsFromArray:[self movingAverageWithWidth:width]];
    return avgArray;
}

- (NSArray *)normalizedArrayToMin:(float) min
                            toMax:(float) max;
{
    int len = [self count];
    float minValue, maxValue, range, outRange;
    if (len <= 0)
        return [NSArray array];
    
    NSArray *sortedArray;
    sortedArray = [self sortedArrayUsingSelector:@selector(compare:)];
    minValue = [[sortedArray objectAtIndex:0] floatValue];
    maxValue = [[sortedArray lastObject] floatValue];
    range = maxValue - minValue;
    outRange = max - min;
    
    NSMutableArray *normalArray = [[NSMutableArray alloc] initWithCapacity:len];
    for (int i = 0; i < len; i++)
    {
        float eachNewValue = [[self objectAtIndex:i] floatValue];
        
        //normalize zero .. range
        eachNewValue -= minValue;
        
        //normalize zero .. one
        eachNewValue /= range;
        
        //normalize zero .. outRange
        eachNewValue *= outRange;
        
        //shift whole mess to make lowest value correspond to min
        eachNewValue += min;
        
        [normalArray addObject:[NSNumber numberWithFloat:eachNewValue]];
    }
    
    NSArray *outArray = [NSArray arrayWithArray:normalArray];
    [normalArray release];
    return outArray;
}

- (id)min
{  
    NSArray *sortedArray;
    sortedArray = [self sortedArrayUsingSelector:@selector(compare:)];
    return [sortedArray objectAtIndex:0];
}

- (id)max
{
    NSArray *sortedArray;
    sortedArray = [self sortedArrayUsingSelector:@selector(compare:)];
    return [sortedArray lastObject];
}

@end
