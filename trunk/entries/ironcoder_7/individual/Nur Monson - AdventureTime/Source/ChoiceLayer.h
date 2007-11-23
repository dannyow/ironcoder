//
//  ChoiceLayer.h
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface ChoiceLayer : CALayer {
	CATextLayer *_text;
}

- (CATextLayer *)textLayer;

- (void)setSelected:(BOOL)willSelect;
@end
