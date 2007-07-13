//
//  BSNecklace.h
//  ShowMeYourT*ts
//
//  Created by Blake Seely on 3/4/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class BSBead;


@interface BSNecklace : NSObject {
    NSMutableArray *beads;
    BOOL caught;    
}

- (id)initWithTargetPoint:(NSPoint)target;

- (int)beadCount;
- (BSBead *)beadAtIndex:(int)index;
- (float)maxYPoint;
- (BOOL)isCaught;
- (void)setCaught:(BOOL)catch;


@end
