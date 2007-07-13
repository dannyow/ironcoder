#import <Cocoa/Cocoa.h>

@interface RSUIElement : NSObject
{
	// Native element is our bridge to the straight C API
	AXUIElementRef mNativeElement;
}

// Special elements
+ (id) systemWideElement;
+ (NSArray*) applicationElements;

// Generic nodes
+ (id) uiElementWithNativeRef:(AXUIElementRef)newElement;
- (id) initWithNativeRef:(AXUIElementRef)newElement;

- (NSArray*)children;

// Util
- (NSString*) userVisibleName;
- (NSString*) roleDescription;
- (BOOL) representsNativeElement:(AXUIElementRef)theElement;

@end
