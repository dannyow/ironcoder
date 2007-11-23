//
//  AnimationView.h
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>


@interface AnimationLayer : CALayer {

    CATextLayer *textLayer;

    NSMutableArray *layerQueue;
}

- (void)addString:(NSAttributedString *)string atPosition:(NSPoint)point;


@end
