/* TimeGraphView */

#import <Cocoa/Cocoa.h>

@interface TimeGraphView : NSView
{
	// Dictionary of names -> time intervals
	NSDictionary* mNamedTimeIntervals;
	
	// An option to omit apps that fall below some threshold of total time 
	BOOL mShowsBarelyUsedApplications;
	
	// Which pattern are we using to render?
	NSString* mGraphPattern;
}

// the data that are graphed on the view consist of a name
// and associated time interval
- (NSDictionary *) namedTimeIntervals;
- (void) setNamedTimeIntervals: (NSDictionary *) theNamedTimeIntervals;

- (BOOL) showsBarelyUsedApplications;
- (void) setShowsBarelyUsedApplications: (BOOL) flag;

// A list of pattern names which may be passed to "setGraphPattern"
- (NSArray*) graphPatterns;

// The current pattern
- (NSString *) graphPattern;
- (void) setGraphPattern: (NSString *) theGraphPattern;

@end