#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface CCarbonComponentInstance : NSObject {
	ComponentInstance componentInstance;
}

- (id)init;

- (void)openDefaultComponentType:(OSType)inComponentType subType:(OSType)inComponentSubType;
- (void)close;
- (void)setComponentInstance:(ComponentInstance)inComponentInstance;
- (ComponentInstance)componentInstance;
- (ComponentInstance)detachComponentInstance;

@end
