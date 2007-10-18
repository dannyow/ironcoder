//
//  TableColumnHackery.m
//  Process Timer
//
//  Created by Peter Hosey on 2006-07-23.
//  Copyright 2006 Peter Hosey. All rights reserved.
//

/*Explanation:
 *
 *I had my table columns bound to arrayController.arrangedObjects, but I'd get this error when I tried to edit one of the items in the table view:
 *
 *	2006-07-23 03:17:13.090 Process Timer[8283] Error setting value for key path  of object  (from bound object <NSTableColumn: 0x34a860>): [<NSCFString 0xa291483c> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key .
 *
 *I added this category, and bound the table columns to arrayController.arrangedObjects.string instead (having set the array controllers' class names to NSMutableString). Evil, but it works.
 */

@implementation NSMutableString (TableColumnHackery)

- (NSString *)string {
	return self;
}

@end
