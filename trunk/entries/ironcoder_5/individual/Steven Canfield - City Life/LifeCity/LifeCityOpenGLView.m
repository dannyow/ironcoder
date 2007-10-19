//
//  LifeCityOpenGLView.m
//  LifeCity
//
//  Created by Steven Canfield on 30/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "LifeCityOpenGLView.h"


@implementation LifeCityOpenGLView
+ (NSOpenGLPixelFormat*) pixelFormat
{
    NSOpenGLPixelFormatAttribute attributes [] = {
		NSOpenGLPFANoRecovery,
		NSOpenGLPFAAccelerated,
		NSOpenGLPFADoubleBuffer,
		NSOpenGLPFAColorSize, 32,
		NSOpenGLPFADepthSize, 32,
		NSOpenGLPFAStencilSize, 8,
        (NSOpenGLPixelFormatAttribute)nil
    };
    return [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
}


-(id) initWithFrame: (NSRect) frameRect
{
	NSOpenGLPixelFormat * format = [LifeCityOpenGLView pixelFormat];

	self = [super initWithFrame: frameRect pixelFormat: format];
	people = [[NSMutableArray alloc] init];
	
	[[self openGLContext] makeCurrentContext];
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_DST_ALPHA);

	[self reshape];
	
	glEnable(GL_TEXTURE_RECTANGLE_ARB) ;

	photoEnum = [[PhotoEnumerator alloc] initWithContentsOfFolder:[NSString stringWithFormat:@"%@/Pictures/iPhoto Library/Data", NSHomeDirectory()]];
	appIcons = [[ApplicationIconEnumerator alloc] init];
	
	billboardPerson = [[Person alloc] initWithX:-0.04 Y:-0.35 Z:0.0 photo:[[Photo alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"singapore" ofType:@"jpg"]] appIcon:NULL personSize:0.2];
	[billboardPerson stop];
	[billboardPerson stopDancing];
	
	[people addObject:billboardPerson];
	
    return self;
}

- (void)initOpenGL {
	GLDebug(@"initOpenGL");
	glClearColor( 0.0, 0.0, 0.0, 1.0 );
	
	[self reshape];
//	person = [[Person alloc] init];
//	bldg = [[Building alloc] initWithX:0 Y:0 Z:0];

	GLDebug(@"Error = %i", glGetError() );
}

- (void) reshape {
//	glMatrixMode(GL_PROJECTION);
//	glLoadIdentity();
//	gluPerspective(45, 1, .1, 1000);
//	glMatrixMode(GL_MODELVIEW);

	glViewport( 0.0 , 0.0 , [self frame].size.width , [self frame].size.height);
	glClearColor( 0.0f , 0.0f, 0.0f, 1.0f );
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(90,  (float)([self frame].size.width /  [self frame].size.height) , 0.01, 1000.0);
	//glOrtho( -2.0 , 2.0 , -2.0, 2.0 , -20.0 , 20.0 );
	glMatrixMode(GL_MODELVIEW);
	//glLoadIdentity();
}

#define JUST_PICTURE 600
#define JUST_PEOPLE 800
#define FEW_BUILDINGS 1200
#define PAN_OUT 1800
#define RESTART 3000


- (void)drawRect:(NSRect)frame {

	static int timeStep = 0;
	timeStep++;

	[[self openGLContext] makeCurrentContext];

//	glEnable(GL_DEPTH_TEST );
//	glEnable(GL_BLEND);
//	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
	
	static float pullback = 0.0;
	if( timeStep >= 0 && timeStep <= JUST_PICTURE) {
		pullback+= 0.0004;
	} else if( timeStep >= JUST_PICTURE && timeStep <= JUST_PEOPLE ) {
		pullback += 0.0016;
	} else if( timeStep >= JUST_PEOPLE && timeStep <= FEW_BUILDINGS ) {
		pullback += 0.0032;
	} else if( timeStep >= FEW_BUILDINGS && timeStep <= PAN_OUT ) {
		pullback += 0.0032;
	} else {
		pullback += 0.0120;
	}
		
	GLDebug(@"Random numbers: %f, %i", SSRandomFloatBetween(1.0,100.0), SSRandomIntBetween(0,100) );

	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

	glLoadIdentity();
	

	glTranslatef( 0.0, 0.0, -pullback ); //  -1 * (pullback * pullback) - 0.0 );

	
	//Person * p = [[Person alloc] initWithX:0.0 Y:0.0 Z:-0.2 photo:[photoEnum nextObject]];
//	[p draw];
	BOOL addedPerson = NO;
	Person * p;
	
	if( timeStep >= JUST_PICTURE ) {
		int chance = SSRandomIntBetween( 0, 100 );
		if( (chance > 95 || [people count] == 0) && [people count] < 100 && addedPerson == NO ) {
			Photo * picture = [photoEnum nextObject];
			//NSLog(@"%i, %i", [picture width], [picture height]);
			addedPerson = YES;
			p = [[Person alloc] initWithX:SSRandomFloatBetween(-15.0, 15.0 ) Y:SSRandomFloatBetween(-0.1, 0.1 ) Z:SSRandomFloatBetween(-1.0,-0.9 ) photo: picture appIcon:[appIcons nextObject]];
			[people addObject:p];
		}
	}
	
	int personIndex;
	for( personIndex = 0; personIndex < [people count]; personIndex++ ) {
		p = [people objectAtIndex:personIndex];
		[p draw];
		if( timeStep == PAN_OUT)  {
			[p quickBuild];
		}
		if( timeStep > FEW_BUILDINGS && p->Z >= -1 * (pullback * pullback) - 0.025 ) {
			int chance = SSRandomIntBetween( 0, 10000 );
			if( chance >= 9900 ) {
				[p buildBuilding];
			}
		}
		
		if( p->X >= 20.0 || p->X <= -20.0 ) {
			[people removeObjectAtIndex:personIndex];
		}
	}
	
	//[bldg draw];
	
	if( timeStep >= RESTART ) {
		[people release];
		people = [[NSMutableArray alloc] init];
		timeStep = JUST_PEOPLE;
		pullback = 0.0;
	}
					
	[[self openGLContext] flushBuffer];
}


@end
