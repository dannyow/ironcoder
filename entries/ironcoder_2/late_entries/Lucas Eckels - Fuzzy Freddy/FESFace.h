//
//  FESFace.h
//  Fuzzy Freddy
//
//  Created by Lucas Eckels on 7/22/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FESFace : NSObject {

   CGPDFDocumentRef pdf;
}

/**
 * Draw the face
 *
 * @param context
 *        Context to draw into.
 */
-(void)draw:(CGContextRef)context;

@end
