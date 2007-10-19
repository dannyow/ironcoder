//
//  LifeCarView.h
//  LifeCar
//
//  Created by Michael Bianco on 3/30/07.
//  Copyright (c) 2007, Prosit Software. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>


@interface LifeCarView : ScreenSaverView {
	NSString *_quote;
	NSImage *_chocolate;
	NSSize _imageSize;
	NSPoint _targetPoint;
	NSPoint _currentPoint;
	
	int _counter;
	NSPoint _change;
	NSPoint _start;
	NSRect _sFrame;
}

@end
