//
//  Controller.h
//  IronCoderV
//
//  Created by Jim and Krisie Turner on 3/30/07.
//  Please see the LICENSE.txt file for license information
//

#import <Cocoa/Cocoa.h>

@class SSView;

@interface Controller : NSObject
{
    IBOutlet SSView *theView;
	
	NSSound *fart1;
	NSSound *fart2;
	NSTimer *genPoopTimer;
}

-(IBAction)createPoop:(id)sender;
-(void)takeADump:(id)sender;

@end
