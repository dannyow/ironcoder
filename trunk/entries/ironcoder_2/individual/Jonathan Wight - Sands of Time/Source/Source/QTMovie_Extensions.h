//
//  QTMovie_Extensions.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/27/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import <QTKit/QTKit.h>

@interface QTMovie (QTMovie_Extensions)

+ (id)movieWithTempWritableMovie;
- (void)addMP4Image:(NSImage *)inImage;
- (BOOL)writeFlattenedToFile:(NSString *)inPath;

- (QTDataReference *)defaultDataReference;

/**
 * @method movieWithVisualContext:
 * @abstract Creates a (auto-released) copy of the target using the target's data reference. No attributes are copied.
 */
- (QTMovie *)movieWithVisualContext:(QTVisualContextRef)inVisualContext;

@end
