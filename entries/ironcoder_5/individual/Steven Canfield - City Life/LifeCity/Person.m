//
//  Person.m
//  LifeCity
//
//  Created by Steven Canfield on 31/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "Person.h"
#define legRotMax 15.0


@implementation Person
- (id)initWithX:(float)x Y:(float)y Z:(float)z photo:(Photo *)photo {
	return [self initWithX:x Y:y Z:z photo:photo appIcon:NULL];
}

- (id)initWithX:(float)x Y:(float)y Z:(float)z photo:(Photo *)photo appIcon:(Photo *)icon
{
	float ps = SSRandomFloatBetween( 0.2 , 0.40 );
	return [self initWithX:x Y:y Z:z photo:photo appIcon:icon personSize:ps];

}

- (id)initWithX:(float)x Y:(float)y Z:(float)z photo:(Photo *)photo appIcon:(Photo *)icon personSize:(float)ps;
{
	self = [super init];
	
	X = x;
	Y = y;
	Z = z;
	
	personSize = ps;
	face = [photo retain];

	personColor = [NSColor randomColor];
	
	if( icon != NULL ) {
		appIcon = [[Rectangle alloc] initWithRect:NSMakeRect(0.0,0.0,personSize / 2.0, personSize/2.0) Z:Z];
		[appIcon setTexture:icon];
	}
	
	
	/// Create a Body
	NSColor * randomColor = [NSColor randomColor];
	
	[self setColor:randomColor];
	
	body = [[Rectangle alloc] initWithRect:NSMakeRect(0.0, 0.0 ,personSize / 3.0, personSize ) Z:Z];
	[body setColor:randomColor];
	
	float aspect = (float)[photo height] / (float)[photo width];
	headWidth = personSize * 2;
	headHeight = personSize * 2 * aspect;
	head = [[Rectangle alloc] initWithRect:NSMakeRect(0.0, 0.0, headWidth, headHeight)  Z:Z];
	[head setTexture:photo];
	[head setColor:randomColor];
	
//	[body setTexture:photo];
	// Create Arms
	leftArm = [[Rectangle alloc] initWithRect:NSMakeRect( 0.0, 0.0, -personSize / 3.0, personSize / 8.0 ) Z:Z];
	rightArm = [[Rectangle alloc] initWithRect:NSMakeRect( 0.0, 0.0, personSize / 3.0, personSize / 8.0 ) Z:Z];

	leftLeg = [[Rectangle alloc] initWithRect:NSMakeRect( 0.0, 0.0, -personSize / 7.0, personSize / 1.4 ) Z:Z];
	rightLeg = [[Rectangle alloc] initWithRect:NSMakeRect( 0.0, 0.0, personSize / 7.0, personSize / 1.4 ) Z:Z];

	[leftArm setColor: randomColor];
	[rightArm setColor: randomColor];
	[leftLeg setColor: randomColor];
	[rightLeg setColor: randomColor];
	
	leftLegRotation = legRotMax;
	rightLegRotation = legRotMax;
//	legGoingForward = YES;
	leftLegMoving = YES;

	speed = SSRandomFloatBetween( 0.0025, 0.005 );
	direction = SSRandomIntBetween(0,1);
	stopDancing = NO;
	building = NULL;
	
	return self;
}

- (void)stop {
	speed = 0.0;
}

- (void)incrementLeftLegRotation {
	if( leftLegGoingForward ) {
		leftLegRotation += 2.0;
		if( leftLegRotation >= legRotMax ) {
			leftLegGoingForward = NO;
			leftLegMoving = NO;
		}
	} else {
		leftLegRotation -= 2.0;
		if( leftLegRotation <= -legRotMax ) {
			leftLegGoingForward = YES;
			leftLegMoving = NO;
		}
	}
}

- (void)incrementRightLegRotation {
	if( rightLegGoingForward ) {
		rightLegRotation += 2.0;
		if( rightLegRotation >= legRotMax ) {
			rightLegGoingForward = NO;
			leftLegMoving = YES;
		}
	} else {
		rightLegRotation -= 2.0;
		if( rightLegRotation <= -legRotMax ) {
			rightLegGoingForward = YES;
			leftLegMoving = YES;
		}
	}
}

- (void)updateLeftArmPosition {
//	BOOL leftArmGoingUp;
//	float leftArmRotation;
	if( leftArmGoingUp ) {
		leftArmRotation += 1.2;
		if( leftArmRotation >= 15.0 ) {
			leftArmGoingUp = NO;
			leftArmMoving = NO;
		}
	} else {
		leftArmRotation -= 1.2;
		if( leftArmRotation <= -15.0 ) {
			leftArmGoingUp = YES;
			leftArmMoving = NO;
		}
	
	
	}

}

- (void)updateRightArmPosition {
//	BOOL rightArmGoingUp;
//	float rightArmRotation;
	if( rightArmGoingUp ) {
		rightArmRotation += 1.2;
		if( rightArmRotation >= 15.0 ) {
			rightArmGoingUp = NO;
			leftArmMoving = YES;
		}
	} else {
		rightArmRotation -= 1.2;
		if( rightArmRotation <= -15.0 ) {
			rightArmGoingUp = YES;
			leftArmMoving = YES;
		}
	}
}


- (void)updateHeadRotation {
	if( headGoingLeft ) {
		headRotation -= 0.5;
		if( headRotation <= -15.0 ) {
			headGoingLeft = NO;
		}
	} else {
		headRotation += 0.5;
		if( headRotation >= 15.0 ){
			headGoingLeft = YES;
		}
	}
}

- (void)draw {
	// Let's see if we have a building
	if( building != NULL ) {
		[building draw];
	}


	glPushMatrix();
	glTranslatef( X, Y, Z);
	if( direction == YES ) {
		X+= speed ;
	} else {
		X-=  speed;
	}
	
	[body draw];
	glTranslatef( 0.0 , personSize , 0.0 );
	
	glPushMatrix();
	glTranslatef( - (headWidth / 2.5), 0.0, 0.0 );
	
	glPushMatrix();
	glTranslatef( headWidth / 2.0, headHeight / 2.0, 0.0 );
	if( !stopDancing ) {
		glRotatef( headRotation, 0.0, 0.0, 1.0 );
	}
	glTranslatef( -headWidth / 2.0, -headHeight / 2.0, 0.0 );
	[head draw];
	glPopMatrix();
	
	glTranslatef( headWidth / 2.5, 0.0, 0.0 );
	glPopMatrix();
	
	
	
	glTranslatef( 0.0, -personSize / 8.0, 0.0 );
	
	glPushMatrix();
		glTranslatef( personSize / 3.0, 0.0, 0.0 );
		glRotatef( leftArmRotation, 0.0, 0.0, 1.0 );
		glTranslatef( -personSize / 3.0, 0.0, 0.0 );
		[leftArm draw];
		
		glPushMatrix();
		if( appIcon != NULL ) {
			glTranslatef( -personSize / 1.4, 0.0, 0.0 );
			[appIcon draw];
		}
		glPopMatrix();
	glPopMatrix();
	
	
	
	glTranslatef( personSize / 3.0 , 0.0, 0.0 );
	
	glPushMatrix();
		glTranslatef( -personSize / 3.0 , 0.0, 0.0 );
		glRotatef( rightArmRotation, 0.0, 0.0, 1.0 );
		glTranslatef( personSize / 3.0 , 0.0, 0.0 );
		[rightArm draw];
	glPopMatrix();
	
	glTranslatef( 0.0, personSize / 8.0, 0.0 );
	
	glTranslatef( - personSize / 3.0 , -personSize * 1.5, 0.0 );
	glPushMatrix();
	glTranslatef( -personSize / 7.0 , personSize / 1.4 , 0.0 );
	glRotatef(leftLegRotation,0.0,0.0,1.0);
	glTranslatef( personSize / 7.0, -personSize / 1.4 , 0.0 );
	[leftLeg draw];
	glPopMatrix();


	glTranslatef( personSize / 3.0 , 0.0, 0.0 );
	glPushMatrix();
	glTranslatef( -personSize / 7.0 , personSize / 1.4 , 0.0 );
	glRotatef(rightLegRotation,0.0,0.0,1.0);
	glTranslatef( personSize / 7.0, -personSize / 1.4 , 0.0 );
	[rightLeg draw];
	glPopMatrix();

	if( leftLegMoving ) { 
		[self incrementLeftLegRotation];
	} else {
		[self incrementRightLegRotation];
	}
	
	[self updateHeadRotation];
	
//	if( leftArmMoving ) {
		[self updateLeftArmPosition];
//	} else {
		[self updateRightArmPosition];
//	}
	
	glPopMatrix();
}

- (void)setColor:(NSColor *)color
{
	[_color autorelease];
	_color = [color copy];
}
- (NSColor *)color { return _color; }

- (void)stopDancing {
	stopDancing = YES;
}

- (void)buildBuilding {
	if( ! building ) {
		building = [[Building alloc] initWithX:X Y:Y Z:Z color:[self color]];
		speed = 0.0;
	}
}

- (void)quickBuild {
	if( building ) {
		[building setNumFramesToBuild:5];
	}
}

@end
