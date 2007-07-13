#import <Cocoa/Cocoa.h>


@interface Wire : NSObject {
    BOOL active;
    BOOL cut;
    int path;
}

// Setters and getters;
- (void)active:(BOOL)b;
- (BOOL)active;
- (void)cut:(BOOL)c;
- (BOOL)cut;
- (void)path:(int)p;
- (int)path;

@end
