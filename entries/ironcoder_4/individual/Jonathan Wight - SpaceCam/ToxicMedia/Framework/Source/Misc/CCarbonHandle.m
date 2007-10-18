
#import "CCarbonHandle.h"

@implementation CCarbonHandle

+ (id)carbonHandleWithHandle:(Handle)inHandle
{
return([[[self alloc] initWithHandle:inHandle] autorelease]);
}

+ (id)carbonHandleWithEmptyHandle
{
return([self carbonHandleWithHandle:NewHandle(0L)]);
}

+ (id)carbonHandleWithData:(NSData *)inData
{
Handle theHandle = NewHandle([inData length]);
HLock(theHandle);
memcpy(*theHandle, [inData bytes], [inData length]);
HUnlock(theHandle);
return([self carbonHandleWithHandle:theHandle]);
}

- (id)initWithHandle:(Handle)inHandle
{
if ((self = [super init]) != NULL)
	{
	mHandle = NULL;
	mLockCount = 0;
	[self setHandle:inHandle];
	}
return(self);
}

- (void)dealloc
{
[self setHandle:NULL];
[super dealloc];
}

- (Handle)handle
{
return(mHandle);
}

- (void)setHandle:(Handle)inHandle
{
if (mHandle == inHandle)
	return;
if (mHandle != NULL)
	{
	DisposeHandle(mHandle);
	mHandle = NULL;
	mLockCount = 0;
	}
if (inHandle != NULL)
	{
	mHandle = inHandle;
	mLockCount = HGetState(mHandle) & kHandleLockedMask ? 1 : 0;
	}
}

- (Handle)detachHandle
{
Handle theDetachedHandle = mHandle;
mHandle = NULL;
mLockCount = 0;
return(theDetachedHandle);
}

- (void *)bytes
{
return(*mHandle);
}

- (size_t)length
{
NSAssert(mHandle != NULL, @"-[CCarbonHandle length] no handle");
return(GetHandleSize(mHandle));
}

- (void)lock
{
NSAssert(mHandle != NULL, @"-[CCarbonHandle lock] no handle");
++mLockCount;
if (mLockCount == 1)
	HLock(mHandle);
}

- (void)unlock
{
NSAssert(mHandle != NULL, @"-[CCarbonHandle unlock] no handle");
--mLockCount;
if (mLockCount == 0)
	HUnlock(mHandle);
}

- (BOOL)isLocked
{
return(mLockCount >= 1);
}

- (NSData *)data
{
return([NSData dataWithBytesNoCopy:[self bytes] length:[self length] freeWhenDone:NO]);
}

- (NSString *)asPascalString;
{
NSData *theData = [self data];
const unsigned char *theCharacters = [theData bytes];

NSData *theStringData = [NSData dataWithBytes:&theCharacters[1] length:theCharacters[0]];

return([[[NSString alloc] initWithData:theStringData encoding:NSMacOSRomanStringEncoding] autorelease]);
}

@end
