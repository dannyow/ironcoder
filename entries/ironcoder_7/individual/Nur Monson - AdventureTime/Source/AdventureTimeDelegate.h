//
//  AdventureTimeDelegate.h
//  AdventureTime
//
//  Created by Nur Monson on 11/9/07.
//  Copyright theidiotproject 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AdventureView.h"
#import "AdventureScene.h"

@interface AdventureTimeDelegate : NSObject
{
	IBOutlet AdventureView *_adventureView;
	NSDictionary *_gameDict;
	NSString *_gamePath;
	NSMutableArray *_scenes;
	AdventureScene *_currentScene;
}


@end
