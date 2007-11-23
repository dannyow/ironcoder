//
//  ATLandscape.h
//  AdventureTime
//
//  Created by Nur Monson on 11/9/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface ATLandscape : CALayer {
	CALayer *_npcRight;
	CALayer *_npcLeft;
	CATextLayer *_textBox;
	
	// landscape content is the background
}

- (CALayer *)npcRight;
- (CALayer *)npcLeft;

- (void)setTextBox:(CATextLayer *)newTextLayer;
- (CATextLayer *)textBox;

@end
