//
//  Person.h
//  LifeCity
//
//  Created by Steven Canfield on 31/03/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Rectangle.h"
#import <ScreenSaver/ScreenSaver.h>
#import "Building.h"
#import "Photo.h"

@interface Person : NSObject {
	@public
	float X;
	float Y;
	float Z;

	@protected
	Rectangle * head;
	Rectangle * body;
	Rectangle * leftLeg;
	Rectangle * rightLeg;
	Rectangle * leftArm;
	Rectangle * rightArm;
	
	float headWidth;
	float headHeight;
	
	NSColor *personColor;
	float personSize;
		
	float leftLegRotation;
	float rightLegRotation;
	
	BOOL leftLegGoingForward;
	BOOL rightLegGoingForward;
	
	BOOL leftLegMoving;
	
	BOOL direction;
	float speed;
	
	Building * building;
	
	NSColor * _color;
	
	Photo * face;
	
	float headRotation;
	BOOL headGoingLeft;
	
	BOOL leftArmGoingUp;
	float leftArmRotation;

	BOOL rightArmGoingUp;
	float rightArmRotation;
	
	BOOL leftArmMoving;
	
	BOOL stopDancing;

	// App Icon Stuff
	Photo * applicationIcon;
	Rectangle * appIcon;
}
- (id)initWithX:(float)x Y:(float)y Z:(float)z photo:(Photo *)photo;
- (id)initWithX:(float)x Y:(float)y Z:(float)z photo:(Photo *)photo appIcon:(Photo *)icon;
- (id)initWithX:(float)x Y:(float)y Z:(float)z photo:(Photo *)photo appIcon:(Photo *)icon personSize:(float)ps;

- (void)stopDancing;
- (void)stop;
- (void)buildBuilding;

// Handling Rotation & C
- (void)updateRightArmPosition;
@end
