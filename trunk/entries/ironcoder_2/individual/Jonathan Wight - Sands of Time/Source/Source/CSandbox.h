//
//  CSandbox.h
//  FallingSand
//
//  Created by Jonathan Wight on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	Neighbour_TopLeft,
	Neighbour_TopCenter,
	Neighbour_TopRight,
	Neighbour_CenterLeft,
	Neighbour_Center,
	Neighbour_CenterRight,
	Neighbour_BottomLeft,
	Neighbour_BottomCenter,
	Neighbour_BottomRight,
	} ENeighbour;

typedef enum { 
	ParticleType_Vacuum,
	ParticleType_Air,
	ParticleType_Sand,
	ParticleType_Water,
	ParticleType_Oil,
	ParticleType_Wall,
	ParticleType_Fire,
	ParticleType_Smoke,
	ParticleType_Wax,
	ParticleType_MoltenWax,
	ParticleType_Adamantium,
	ParticleType_LENGTH
	} EParticleType;

typedef struct {
	EParticleType type;
	int moves;
	} SParticle;

typedef struct {
	SParticle particle;
	} SCell;

typedef struct {
	NSString *name;
	UInt32 color;
	float density;
	BOOL dynamic;
	float slipperiness;
	float flammability;
	float burn;
	float survivability;
	} SParticleTemplate;

@interface CSandbox : NSObject {
	size_t width;
	size_t height;
	NSMutableData *sandBuffer;
	SParticleTemplate particleTemplates[ParticleType_LENGTH];
}

- (void)setup;

- (size_t)width;
- (size_t)height;

- (NSMutableData *)sandBuffer;

- (SParticleTemplate *)particleTemplates;

- (void)update;

- (void)setCircleOf:(SCell)inCell center:(NSPoint)inCenter radius:(float)inRadius;

- (NSMutableArray *)census;

- (void)loadFromImageAtUrl:(NSURL *)inUrl;

@end
