
#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface CCarbonHandle : NSObject {
	Handle mHandle;
	int mLockCount;
}

+ (id)carbonHandleWithHandle:(Handle)inHandle;
+ (id)carbonHandleWithEmptyHandle;
+ (id)carbonHandleWithData:(NSData *)inData;

- (id)initWithHandle:(Handle)inHandle;

- (Handle)handle;
- (void)setHandle:(Handle)inHandle;
- (Handle)detachHandle;

- (void *)bytes;
- (size_t)length;

- (void)lock;
- (void)unlock;
- (BOOL)isLocked;

- (NSData *)data;
- (NSString *)asPascalString;

@end
