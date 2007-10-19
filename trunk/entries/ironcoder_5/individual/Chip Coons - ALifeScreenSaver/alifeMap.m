//
//  alifeMap.m
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/30/07.
//  Copyright 2007 GWSoftware. All rights reserved.
//

#import "alifeMap.h"
#define kDefaultWidth 32
#define kDefaultHeight 32

@implementation alifeMap

static NSArray *sharedDefaultPoints = nil;

+ (NSArray*)defaultMapPoints;
{
   if (sharedDefaultPoints == nil) {
            sharedDefaultPoints = [[NSArray arrayWithObjects: [NSValue valueWithPoint:NSMakePoint(0,31)],
                                                             [NSValue valueWithPoint:NSMakePoint(1,3)],
                                                             [NSValue valueWithPoint:NSMakePoint(1,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(1,5)],
                                                             [NSValue valueWithPoint:NSMakePoint(1,6)],
                                                             [NSValue valueWithPoint:NSMakePoint(1,31)],
                                                             [NSValue valueWithPoint:NSMakePoint(2,1)],
                                                             [NSValue valueWithPoint:NSMakePoint(2,31)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,1)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,27)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,28)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,29)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,30)],
                                                             [NSValue valueWithPoint:NSMakePoint(3,31)],
                                                             [NSValue valueWithPoint:NSMakePoint(4,1)],
                                                             [NSValue valueWithPoint:NSMakePoint(4,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(4,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(5,1)],
                                                             [NSValue valueWithPoint:NSMakePoint(5,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(6,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(7,2)],
                                                             [NSValue valueWithPoint:NSMakePoint(7,3)],
                                                             [NSValue valueWithPoint:NSMakePoint(7,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(8,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(8,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(8,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(9,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(9,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(9,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(10,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(10,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(10,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(11,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(11,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(11,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,8)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,9)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,10)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,11)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,12)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,13)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,16)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,17)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,18)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,19)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,21)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,22)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,23)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,24)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,25)],
                                                             [NSValue valueWithPoint:NSMakePoint(12,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(13,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(14,4)],
                                                             [NSValue valueWithPoint:NSMakePoint(16,5)],
                                                             [NSValue valueWithPoint:NSMakePoint(16,6)],
                                                             [NSValue valueWithPoint:NSMakePoint(16,7)],
                                                             [NSValue valueWithPoint:NSMakePoint(16,10)],
                                                             [NSValue valueWithPoint:NSMakePoint(16,12)],
                                                             [NSValue valueWithPoint:NSMakePoint(16,13)],
                                                             [NSValue valueWithPoint:NSMakePoint(16,14)],
                                                             [NSValue valueWithPoint:NSMakePoint(17,15)],
                                                             [NSValue valueWithPoint:NSMakePoint(20,16)],
                                                             [NSValue valueWithPoint:NSMakePoint(20,17)],
                                                             [NSValue valueWithPoint:NSMakePoint(20,20)],
                                                             [NSValue valueWithPoint:NSMakePoint(20,21)],
                                                             [NSValue valueWithPoint:NSMakePoint(20,22)],
                                                             [NSValue valueWithPoint:NSMakePoint(20,23)],
                                                             [NSValue valueWithPoint:NSMakePoint(21,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(22,26)],
                                                             [NSValue valueWithPoint:NSMakePoint(23,8)],
                                                             [NSValue valueWithPoint:NSMakePoint(23,16)],
                                                             [NSValue valueWithPoint:NSMakePoint(24,13)],
                                                             [NSValue valueWithPoint:NSMakePoint(24,27)],
                                                             [NSValue valueWithPoint:NSMakePoint(24,28)],
                                                             [NSValue valueWithPoint:NSMakePoint(25,29)],
                                                             [NSValue valueWithPoint:NSMakePoint(26,9)],
                                                             [NSValue valueWithPoint:NSMakePoint(26,17)],
                                                             [NSValue valueWithPoint:NSMakePoint(26,29)],
                                                             [NSValue valueWithPoint:NSMakePoint(27,12)],
                                                             [NSValue valueWithPoint:NSMakePoint(27,17)],
                                                             [NSValue valueWithPoint:NSMakePoint(27,29)],
                                                             [NSValue valueWithPoint:NSMakePoint(28,17)],
                                                             [NSValue valueWithPoint:NSMakePoint(29,19)],                                                             
                                                             [NSValue valueWithPoint:NSMakePoint(29,22)],                                                             
                                                             [NSValue valueWithPoint:NSMakePoint(29,25)],                                                             
                                                             [NSValue valueWithPoint:NSMakePoint(29,27)],                                                             
                                                             [NSValue valueWithPoint:NSMakePoint(29,28)],                                                             
                                                             nil] retain];
        }
    return sharedDefaultPoints;
}

 
- (id)init;
{
	if(![super init])
		return nil;
	[self setWidth:kDefaultWidth];
	[self setHeight:kDefaultHeight];
	field = [[NSMutableArray arrayWithCapacity:width] retain];
	[self initializeField];
    [self resetField];
	return self;
}

- (void)dealloc;
{
	[field release];
	[super dealloc];
}

- (NSString*)description;
{
	return [field description];
}

- (void)setWidth:(unsigned int)value;
{
	width = value;
}

- (unsigned int)width;
{
	return width;
}

- (void)setHeight:(unsigned int)value;
{
	height = value;
}

- (unsigned int)height;
{
	return height;
}

- (NSMutableArray *)field;
{
	return field;
}

- (void)initializeField;
{
    unsigned int i, j;
	NSMutableArray *col;
	
	for(i=0; i < width; i++){
        col = [NSMutableArray arrayWithCapacity:height];
		for(j=0; j < height; j++){
			[col addObject:[NSNumber numberWithInt:0]];
		}
		[field addObject:col];
	}
}

- (void)clearField;
{
	unsigned int i, j;
	NSMutableArray *col;
	
	for(i=0; i < width; i++){
        col = [[NSMutableArray arrayWithCapacity:height] retain];
		for(j=0; j < height; j++){
			[col addObject:[NSNumber numberWithInt:0]];
		}
		[field replaceObjectAtIndex:i withObject:col];
        [col release];
	}
}

- (void)resetField;
{
    
    [self clearField];
    
    NSArray *defaults = [alifeMap defaultMapPoints];
    NSEnumerator *e = [defaults objectEnumerator];
    NSValue *v;
    
    while(v=[e nextObject]){
        [self setValue:1 atLocation:[v pointValue]];
    }
    
}

- (BOOL)locationContainsFood:(NSPoint)loc;
{
	BOOL result = NO;
	int i = [[[field objectAtIndex:loc.x] objectAtIndex:loc.y] intValue];
	if(i == 1)
		result = YES;
	
	return result;
}

- (int)valueAtLocation:(NSPoint)loc;
{
	int result = 0;
	result =  [[[field objectAtIndex:loc.x] objectAtIndex:loc.y] intValue];
	return result;
}

- (void)setValue:(int)value atLocation:(NSPoint)loc;
{
	[[field objectAtIndex:loc.x] replaceObjectAtIndex:loc.y withObject:[NSNumber numberWithInt:value]];
}

- (void)markLocation:(NSPoint)loc;
{
    int place = [self valueAtLocation:loc];
    place--;
    [self setValue:place atLocation:loc];
}

@end
