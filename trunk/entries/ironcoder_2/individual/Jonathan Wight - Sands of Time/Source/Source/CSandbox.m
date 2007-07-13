//
//  CSandbox.m
//  FallingSand
//
//  Created by Jonathan Wight on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "CSandbox.h"

#import "Utilities.h"

inline SCell *CellAt(SCell *inBuffer, int inBufferWidth, int inBufferHeight, int X, int Y);
inline BOOL SwapCell(SCell *inCellOne, SCell *inCellTwo);

static void UpdateCell(SCell *inBuffer, int inBufferWidth, int inBufferHeight, int X, int Y, SParticleTemplate *inParticleTemplates);

inline SCell *CellAt(SCell *inBuffer, int inBufferWidth, int inBufferHeight, int X, int Y)
{
#pragma unused (inBufferHeight)

if (X >= 0 && X < inBufferWidth && Y >= 0 && Y < inBufferWidth)
	{
	return(inBuffer + Y * inBufferWidth + X);
	}
else
	{
	static SCell theCell = { .particle = { .type = ParticleType_Adamantium } };
	return(&theCell);
	}
}

inline BOOL SwapCell(SCell *inCellOne, SCell *inCellTwo)
{
inCellOne->particle.moves += 1;
inCellTwo->particle.moves += 1;

SParticle T = inCellTwo->particle;
inCellTwo->particle = inCellOne->particle;
inCellOne->particle = T;

return(YES);
}

@implementation CSandbox

- (id)init
{
if ((self = [super init]) != NULL)
	{
	[self setup];
	}
return(self);
}

- (void)dealloc
{
[sandBuffer autorelease];
//
[super dealloc];
}

- (void)setup
{
const NSSize theSize = { 400, 400 };
width = ceilf(theSize.width);
height = ceilf(theSize.height);

SParticleTemplate theParticleTemplates[ParticleType_LENGTH] = {
	{ .name = @"Vacuum", .color = 0x000000, .density = 0.0f, .dynamic = YES, .slipperiness = 0.0f, .flammability = 0.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Air", .color = 0x001010, .density = 0.2f, .dynamic = YES, .slipperiness = 0.0f, .flammability = 0.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Sand", .color = 0xFFFF00, .density = 1.0f, .dynamic = YES, .slipperiness = 0.1f, .flammability = 0.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Water", .color = 0x0000FF, .density = 0.9f, .dynamic = YES, .slipperiness = 0.8f, .flammability = 0.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Oil", .color = 0x804040, .density = 0.8f, .dynamic = YES, .slipperiness = 0.9f, .flammability = 1.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Wall", .color = 0x808080, .density = 1.0f, .dynamic = NO, .slipperiness = 0.0f, .flammability = 0.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Fire", .color = 0xFF0000, .density = 0.2f, .dynamic = YES, .slipperiness = 0.0f, .flammability = 0.0f, .burn = 1.0f, .survivability = 0.95f },
	{ .name = @"Smoke", .color = 0x108080, .density = 0.05f, .dynamic = YES, .slipperiness = 0.0f, .flammability = 0.0f, .burn = 0.0f, .survivability = 0.90f },
	{ .name = @"Wax", .color = 0xFFFFFF, .density = 1.0f, .dynamic = NO, .slipperiness = 0.0f, .flammability = 0.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Molten Wax", .color = 0xFFAAAA, .density = 0.95f, .dynamic = YES, .slipperiness = 0.8f, .flammability = 0.0f, .burn = 0.0f, .survivability = 1.0f },
	{ .name = @"Adamantium", .color = 0x0000AA, .density = 1.0f, .dynamic = NO, .slipperiness = 0.0f, .flammability = 0.0f },
	};

//NSLog(@"%d", sizeof(SParticleTemplate) * ParticleType_LENGTH);
memcpy(particleTemplates, theParticleTemplates, sizeof(SParticleTemplate) * ParticleType_LENGTH);

SCell *theSand = [[self sandBuffer] mutableBytes];

for (unsigned Y = 0; Y != height; ++Y)
	{
	for (unsigned X = 0; X != width; ++X)
		{
		CellAt(theSand, width, height, X, Y)->particle.type = ParticleType_Air;
		}
	}
	
if (NO)
	{
	for (int N = 0; N != 1000; ++N)
		{
		CellAt(theSand, width, height, randint(0, width), randint(0, height))->particle.type = ParticleType_Sand;
		}
	}

for (unsigned X = 0; X != width; ++X)
	{
	CellAt(theSand, width, height, X, 0)->particle.type = ParticleType_Adamantium;
	}
}

#pragma mark -

- (size_t)width
{
return(width);
}

- (size_t)height
{
return(height);
}

#pragma mark -

- (NSMutableData *)sandBuffer
{
if (sandBuffer == NULL)
	{
	const size_t theBufferLength = width * sizeof(SCell) * height;
	sandBuffer = [[NSMutableData alloc] initWithLength:theBufferLength];
	}
return(sandBuffer);
}

- (SParticleTemplate *)particleTemplates;
{
return(particleTemplates);
}

#pragma mark -

- (void)update
{
SCell *theSand = [[self sandBuffer] mutableBytes];

// Reset
for (unsigned Y = 0; Y != height; ++Y)
	{
	for (unsigned X = 0; X != 400; ++X)
		{
		CellAt(theSand, width, height, X, Y)->particle.moves = 0;
		}
	}

// Generators
if (NO)
	{
	CellAt(theSand, width, height, width / 2, height - 1)->particle.type = ParticleType_Oil;
	}

int theOrder[400];
range(theOrder, 400);
shuffle(theOrder, 400);

for (unsigned Y = 0; Y != height; ++Y)
	{
	for (unsigned i = 0; i != 400; ++i)
		{
		int X = theOrder[i];
		UpdateCell(theSand, width, height, X, Y, particleTemplates);
		}
	}

[self willChangeValueForKey:@"census"];
[self didChangeValueForKey:@"census"];
}

- (void)setCircleOf:(SCell)inCell center:(NSPoint)inCenter radius:(float)inRadius
{
SCell *theSand = [[self sandBuffer] mutableBytes];

for (int Y = roundf(-inRadius); Y < roundf(inRadius); ++Y)
	{
	for (int X = roundf(-inRadius); X < roundf(inRadius); ++X)
		{
		if (sqrt(abs(X) * abs(X) + abs(Y) * abs(Y)) <= inRadius)
			{
			SCell *theCell = CellAt(theSand, width, height, inCenter.x + X, inCenter.y + Y);
			*theCell = inCell;
			}
		}
	}
}

- (NSMutableArray *)census
{
int thePopulations[ParticleType_LENGTH] = { };

SCell *theSand = [[self sandBuffer] mutableBytes];
for (unsigned Y = 0; Y != height; ++Y)
	{
	for (unsigned X = 0; X != width; ++X)
		{
		SCell *theCell = CellAt(theSand, width, height, X, Y);
		++thePopulations[theCell->particle.type];
		}
	}

NSMutableArray *theCensus = [NSMutableArray array];
for (int N = 0; N != ParticleType_LENGTH; ++N)
	{
	SParticleTemplate theSourceTemplate = [self particleTemplates][N];

	NSDictionary *theDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:N], @"type",
		theSourceTemplate.name, @"title",
		[NSNumber numberWithInt:thePopulations[N]], @"population",
		NULL];
		
	[theCensus addObject:theDictionary];
	}
	
return(theCensus);
}

- (void)loadFromImageAtUrl:(NSURL *)inUrl
{
CGImageSourceRef theImageSource = CGImageSourceCreateWithURL((CFURLRef)inUrl, NULL);
CGImageRef theImage = CGImageSourceCreateImageAtIndex(theImageSource, 0, NULL);
CFRelease(theImageSource);

width = CGImageGetWidth(theImage);
height = CGImageGetHeight(theImage);

const size_t theSandBufferLength = width * sizeof(SCell) * height;
[sandBuffer autorelease];
sandBuffer = [[NSMutableData alloc] initWithLength:theSandBufferLength];

const size_t theImageBufferLength = width * 4 * height;
NSMutableData *theImageBuffer = [[NSMutableData alloc] initWithLength:theImageBufferLength];

CGColorSpaceRef theColorSpace = CGColorSpaceCreateDeviceRGB();

CGContextRef theSandContext = CGBitmapContextCreate([theImageBuffer mutableBytes], width, height, 8, width * 4, theColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
if (theSandContext == NULL) [NSException raise:NSGenericException format:@"CGBitmapContextCreate() failed."];

CFRelease(theColorSpace);
//
CGRect theRect = { 0, 0, width, height };
CGContextDrawImage(theSandContext, theRect, theImage);

CFRelease(theImage);

CFRelease(theSandContext);

SCell *theSand = [[self sandBuffer] mutableBytes];

UInt32 *theBitmapPointer = [theImageBuffer mutableBytes];
for (unsigned Y = 0; Y != height; ++Y)
	{
	for (unsigned X = 0; X != width; ++X)
		{
		UInt32 theColor = theBitmapPointer[(height - Y) * width + X];
		theColor = theColor & 0x00FFFFFF;
		int N;
		for (N = 0; N != ParticleType_LENGTH; ++N)
			{
			if (particleTemplates[N].color == theColor)
				{
				SCell *theCell = CellAt(theSand, width, height, X, Y);
				theCell->particle.type = N;
				break;
				}
			}
		}
	}
}


@end

static void UpdateCell(SCell *inBuffer, int inBufferWidth, int inBufferHeight, int X, int Y, SParticleTemplate *inParticleTemplates)
{
SCell *theSource = CellAt(inBuffer, inBufferWidth, inBufferHeight, X, Y);

SCell *theNeighbours[] = {
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X - 1, Y + 1),
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X    , Y + 1),
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X + 1, Y + 1),
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X - 1, Y    ),
	NULL, // CellAt(inBuffer, inBufferWidth, inBufferHeight, X    , Y    ),
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X + 1, Y    ),
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X - 1, Y - 1),
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X    , Y - 1),
	CellAt(inBuffer, inBufferWidth, inBufferHeight, X + 1, Y - 1),
	};

SParticleTemplate *theSourceTemplate = &inParticleTemplates[theSource->particle.type];

// Dying...
if (theSourceTemplate->survivability < 1.0f && randomfloat() > theSourceTemplate->survivability)
	{
	theSource->particle.type = ParticleType_Air;
	theSourceTemplate = &inParticleTemplates[theSource->particle.type];
	}

// Burning
if (theSourceTemplate->burn > 0.0f)
	{
	// Igniting
	for (int theDirection = 0; theDirection != 9; ++theDirection)
		{
		SCell *theDestination = theNeighbours[theDirection];
		if (theDestination != NULL)
			{
			SParticleTemplate *theDestinationTemplate = &inParticleTemplates[theDestination->particle.type];
			if (theDestinationTemplate->flammability > 0.0f)
				{
				if (randomfloat() * 2.0f <= (theSourceTemplate->burn + theDestinationTemplate->flammability))
					theDestination->particle.type = ParticleType_Fire;
				}
			}
		}
	
	// Smoking
	int theSmokeDirections[] = { Neighbour_TopLeft, Neighbour_TopCenter, Neighbour_TopRight, Neighbour_CenterLeft, Neighbour_CenterRight };
	shuffle(theSmokeDirections, 5);
	for (int theDirection = 0; theDirection != 5; ++theDirection)
		{
		SCell *theDestination = theNeighbours[theSmokeDirections[theDirection]];
//		SParticleTemplate *theDestinationTemplate = &inParticleTemplates[theDestination->particle.type];
		if (theDestination->particle.type == ParticleType_Air)
			{
			theDestination->particle.type = ParticleType_Smoke;
			break;
			}
		}	
	}

if (theSourceTemplate->dynamic == YES)
	{
	// Gravity
	if (theSource->particle.moves == 0)
		{
		int theDirections[] = { Neighbour_BottomCenter, Neighbour_BottomLeft, Neighbour_BottomRight };
		shuffle(&theDirections[1], 2);
		if (!randint(0, 10))
			shuffle(theDirections, 3);
		for (int N = 0; N != 3; ++N)
			{
			SCell *theDestination = theNeighbours[theDirections[N]];
			SParticleTemplate *theDestinationTemplate = &inParticleTemplates[theDestination->particle.type];
			if (theSource->particle.moves == 0
				&& theDestination->particle.moves == 0
				&& theSourceTemplate->density > theDestinationTemplate->density
				&& randomfloat() < (theSourceTemplate->density - theDestinationTemplate->density)
				)
				{
				SwapCell(theSource, theDestination);
				}
			}
		}

	// Lighter than air.
	if (theSource->particle.moves == 0)
		{
		int theDirections[] = { Neighbour_TopCenter, Neighbour_TopLeft, Neighbour_TopRight };
		shuffle(&theDirections[1], 2);
		if (!randint(0, 10))
			shuffle(theDirections, 3);
		for (int N = 0; N != 3; ++N)
			{
			SCell *theDestination = theNeighbours[theDirections[N]];
			SParticleTemplate *theDestinationTemplate = &inParticleTemplates[theDestination->particle.type];
			if (theSource->particle.moves == 0
				&& theDestination->particle.moves == 0
				&& theSourceTemplate->density < theDestinationTemplate->density
				&& randomfloat() < (theSourceTemplate->density - theDestinationTemplate->density)
				)
				{
				SwapCell(theSource, theDestination);
				}
			}
		}
		
	
	if (theSource->particle.moves == 0)
		{
		// Sliding
		int theSlidCount = 0;
		int xdelta = randomdirection();
		while ((double)random() / (double)0x7FFFFFFF < theSourceTemplate->slipperiness && theSlidCount < 5)
			{
			SCell *theDestination = CellAt(inBuffer, inBufferWidth, inBufferHeight, X + xdelta, Y);
			if (theSourceTemplate->density > inParticleTemplates[theDestination->particle.type].density)
				{
				SwapCell(theSource, theDestination);
				theSlidCount++;
				}
			}
		if (theSlidCount == 0)
			{
			xdelta *= -1;
			while ((double)random() / (double)0x7FFFFFFF < theSourceTemplate->slipperiness && theSlidCount < 5)
				{
				SCell *theDestination = CellAt(inBuffer, inBufferWidth, inBufferHeight, X + xdelta, Y);
				if (theSourceTemplate->density > inParticleTemplates[theDestination->particle.type].density)
					{
					SwapCell(theSource, theDestination);
					theSlidCount++;
					}
				}
			}
		}
	}
}
