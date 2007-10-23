//
//  SSView.h
//  IronCoderV
//
//  Created by Jim and Krisie Turner on 3/30/07.
//  Please see the LICENSE.txt file for license information
//

#import <Cocoa/Cocoa.h>
#import <ScreenSaver/ScreenSaver.h>


@interface SSView : ScreenSaverView 
{
	NSMutableArray *poopInPlay;
	BOOL iNeedANewPoop;
}

-(void) createANewPoop;

@end
