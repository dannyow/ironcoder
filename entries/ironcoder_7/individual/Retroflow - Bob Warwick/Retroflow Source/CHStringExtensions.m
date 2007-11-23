#import "CHStringExtensions.h"

@implementation NSString ( CHStringExtensions ) 

- (NSComparisonResult)compareWithoutThe:(NSString *)inputString {

	// Compares strings alphabetically, disregarding any starting "The "
	// Example: "The Weakerthans" comes after "Treble Charger"

	NSMutableString *selfStringWithoutThe =  [NSMutableString stringWithString:self];
	if ([[[selfStringWithoutThe substringWithRange:NSMakeRange(0, 4)] lowercaseString] isEqualTo:@"the "]) {
		[selfStringWithoutThe replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
	};

	NSMutableString *inputStringWithoutThe = [NSMutableString stringWithString:inputString];
	if ([[[inputStringWithoutThe substringWithRange:NSMakeRange(0, 4)] lowercaseString] isEqualTo:@"the "]) {
		[inputStringWithoutThe replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
	};

	return [selfStringWithoutThe compare:inputStringWithoutThe];
}

@end
