//
//  StatusItemExtension.m
//  LifeSaver
//
//  Created by Karsten Kusche on 01.04.07.
//  Copyright 2007 briksoftware.com. All rights reserved.
//

#import "StatusItemExtension.h"


@implementation NSStatusItem (Hack)
- (NSRect)hackFrame
{
    return [_fWindow frame];
}
@end