//
//  Creature.m
//  Wildcat
//
//  Created by Nur Monson on 3/31/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "Creature.h"


@implementation Creature

- (id)init
{
	if( (self = [super init]) ) {
		_position = 2.05f;
		_velocity = (Vector2D){0.0002f,0.0f};
		_bounce = NO;
		_worldSize = 10.0f;
		
		_age = 100;
		
		[self setColor:[NSColor colorWithCalibratedHue:0.5f saturation:1.0f brightness:1.0f alpha:1.0f]];
	}

	return self;
}

- (void)dealloc
{
	[_texture release];

	[super dealloc];
}

+ (TIPTexture *)sharedTexture
{
	static TIPTexture *sharedTexture = nil;
	if( sharedTexture == nil ) {
		sharedTexture = [[TIPTexture alloc] initWithPNG:[[NSBundle bundleForClass:[self class]] pathForResource:@"creature" ofType:@"png"]];
		[sharedTexture autorelease];
	}
	
	return sharedTexture;
}

- (float)position
{
	return _position;
}

- (void)setTexture:(TIPTexture *)aTexture
{
	if( aTexture == _texture )
		return;
	
	[_texture release];
	_texture = [aTexture retain];
}
- (TIPTexture *)texture
{
	return _texture;
}

- (void)setColor:(NSColor *)aColor
{
	[_color release];
	_color = [[aColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] retain];
}
- (NSColor *)color
{
	return _color;
}

- (int)age
{
	return _age;
}

- (void)randomize:(float)worldSize
{
	_worldSize = worldSize;
	_position = SSRandomFloatBetween(0.0f,_worldSize);
	_velocity = (Vector2D){SSRandomFloatBetween(-1.0f,1.0f)/(worldSize*100.0f), SSRandomFloatBetween(-1.0f,1.0f)};
	while( fabsf(_velocity.x) < 0.0002f )
		_velocity.x = SSRandomFloatBetween(-1.0f,1.0f)/(worldSize*100.0f);
	_velocity = Vector2DNormalize( _velocity );
	_bounce = SSRandomIntBetween(0,3);
	
	_age = SSRandomIntBetween(500,1000);
	[self setColor:[NSColor colorWithCalibratedHue:SSRandomFloatBetween(0.0f,1.0f) saturation:0.8f brightness:1.0f alpha:1.0f]];
}

- (void)simulate
{
	if( _age == 0 )
		return;
	
	_position += _velocity.x;
	
	if( _position < 0.0f )
		_position += _worldSize;
	else if( _position >= _worldSize )
		_position -= _worldSize;
	
	_bounce--;
	if( _bounce < 0 )
		_bounce = 3;
	
	//_age--;
}

#define HALFWIDTH 0.025f
- (void)drawWithSlope:(Vector2D)slope
{
	if( _age == 0 )
		return;
	
	glPushMatrix();
	//glScalef(1.0f,2.0f,1.0f);
	
	//if( _texture == nil )
	//	[self setTexture:[Creature sharedTexture]];
	
	if( _bounce < 2 )
		glTranslatef(0.0f,HALFWIDTH/2.0f,0.0f);
	
	if( _velocity.x > 0.0f )
		glScalef(-1.0f,1.0f,1.0f);
	
	glColor4f([_color redComponent],[_color greenComponent],[_color blueComponent],1.0f);
	glBindTexture(GL_TEXTURE_2D, [_texture textureID] );
	glBegin(GL_QUADS); {
		/*
		glTexCoord2f(0.0f,0.0f); glVertex2f(-HALFWIDTH*slope.x,-HALFWIDTH*slope.y);
		glTexCoord2f(1.0f,0.0f); glVertex2f( HALFWIDTH*slope.x, HALFWIDTH*slope.y);
		glTexCoord2f(1.0f,1.0f); glVertex2f( HALFWIDTH*slope.x-HALFWIDTH*slope.y*2.0f, HALFWIDTH*slope.y+HALFWIDTH*slope.x*2.0f);
		glTexCoord2f(0.0f,1.0f); glVertex2f(-HALFWIDTH*slope.x-HALFWIDTH*slope.y*2.0f,-HALFWIDTH*slope.y+HALFWIDTH*slope.x*2.0f);
		*/
	
		glTexCoord2f(0.0f,0.0f); glVertex2f(-HALFWIDTH, 0.0f);
		glTexCoord2f(1.0f,0.0f); glVertex2f( HALFWIDTH, 0.0f);
		glTexCoord2f(1.0f,1.0f); glVertex2f( HALFWIDTH, 2.0f*HALFWIDTH);
		glTexCoord2f(0.0f,1.0f); glVertex2f(-HALFWIDTH, 2.0f*HALFWIDTH);
	
	} glEnd();
	glPopMatrix();
}
@end
