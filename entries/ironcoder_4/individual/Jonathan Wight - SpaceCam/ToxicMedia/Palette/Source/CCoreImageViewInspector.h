//
//  CCoreImageViewInspector.h
//  ToxicMedia
//
//  Created by Jonathan Wight on 10/20/2005.
//  Copyright Toxic Software 2005. All rights reserved.
//

#import <InterfaceBuilder/InterfaceBuilder.h>

@interface CCoreImageViewInspector : IBInspector {
	NSMutableDictionary *model;
}

- (IBAction)actionDebug:(id)inSender;

@end
