#import "Wire.h"


@implementation Wire

- (void)active:(BOOL)b
{
    active = b;
}

- (BOOL)active
{
    return active;
}

- (void)cut:(BOOL)c
{
    cut = c;
}

- (BOOL)cut
{
    return cut;
}

- (void)path:(int)p
{
    path = p;
}

- (int)path
{
    return path;
}

@end
