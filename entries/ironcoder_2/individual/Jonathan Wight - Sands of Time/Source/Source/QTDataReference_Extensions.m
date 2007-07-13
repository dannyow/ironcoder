//
//  QTDataReference_Extensions.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/29/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import "QTDataReference_Extensions.h"

@implementation QTDataReference (QTDataReference_Extensions)

+ (id)dataReferenceWithDataReferenceRecord:(DataReferenceRecord)inDataReference
{
return([[[self alloc] initWithDataReferenceRecord:inDataReference] autorelease]);
}

- (id)initWithDataReferenceRecord:(DataReferenceRecord)inDataReference
{
NSString *theDataReferenceType = NULL;
if (inDataReference.dataRefType == HandleDataHandlerSubType)
	theDataReferenceType = QTDataReferenceTypeHandle;
else if (inDataReference.dataRefType == PointerDataHandlerSubType)
	theDataReferenceType = QTDataReferenceTypePointer;
else if (inDataReference.dataRefType == rAliasType)
	theDataReferenceType = QTDataReferenceTypeFile;
else if (inDataReference.dataRefType == ResourceDataHandlerSubType)
	theDataReferenceType = QTDataReferenceTypeResource;
else if (inDataReference.dataRefType == URLDataHandlerSubType)
	theDataReferenceType = QTDataReferenceTypeURL;

return([self initWithDataRef:inDataReference.dataRef type:theDataReferenceType]);
}

- (DataReferenceRecord)dataReferenceRecord
{
DataReferenceRecord theDataReferenceRecord = { .dataRef = [self dataRef] };
NSString *theType = [self dataRefType];
if ([theType isEqual:QTDataReferenceTypeHandle])
	theDataReferenceRecord.dataRefType = HandleDataHandlerSubType;
else if ([theType isEqual:QTDataReferenceTypePointer])
	theDataReferenceRecord.dataRefType = PointerDataHandlerSubType;
else if ([theType isEqual:QTDataReferenceTypeFile])
	theDataReferenceRecord.dataRefType = rAliasType;
else if ([theType isEqual:QTDataReferenceTypeResource])
	theDataReferenceRecord.dataRefType = ResourceDataHandlerSubType;
else if ([theType isEqual:QTDataReferenceTypeURL])
	theDataReferenceRecord.dataRefType = URLDataHandlerSubType;
return(theDataReferenceRecord);
}

@end
