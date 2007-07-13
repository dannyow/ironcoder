//
//  QTDataReference_Extensions.h
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/29/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import <QTKit/QTKit.h>

@interface QTDataReference (QTDataReference_Extensions)

+ (id)dataReferenceWithDataReferenceRecord:(DataReferenceRecord)inDataReference;

- (id)initWithDataReferenceRecord:(DataReferenceRecord)inDataReference;

- (DataReferenceRecord)dataReferenceRecord;

@end
