#import "relativity.h"
#import <math.h>
#import <Cocoa/Cocoa.h>


double lorentzFactor(double speed, double speedOfLight)
{
	if (speedOfLight == 0)	{
		NSLog(@"The speed of light is 0?  No way!");
		return 1;
	}
	double tmp = sqrt(1 - pow(speed, 2)/pow(speedOfLight, 2));
	return tmp;
}