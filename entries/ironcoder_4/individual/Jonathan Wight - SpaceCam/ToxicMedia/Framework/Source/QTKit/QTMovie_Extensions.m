//
//  QTMovie_Extensions.m
//  CoreVideoFunHouse
//
//  Created by Jonathan Wight on 06/27/2005.
//  Copyright (c) 2005 Toxic Software. All rights reserved.
//

#import "QTMovie_Extensions.h"

#import "QTDataReference_Extensions.h"

@implementation QTMovie (QTMovie_Extensions)

+ (id)movieWithTempWritableMovie
{
NSString *theTempName = [NSString stringWithCString:tmpnam(NULL) encoding:[NSString defaultCStringEncoding]];
if (theTempName == NULL) [NSException raise:NSGenericException format:@"tmpname() failed."];

Handle dataRefH = NULL;
OSType dataRefType;

// create a file data reference for our movie
OSStatus theStatus = QTNewDataReferenceFromFullPathCFString((CFStringRef)theTempName, kQTNativeDefaultPathStyle, 0, &dataRefH, &dataRefType);
if (theStatus != noErr) [NSException raise:NSGenericException format:@"QTNewDataReferenceFromFullPathCFString() failed"];

Movie theQTMovie = NULL;
DataHandler *theDataHandler = NULL;
theStatus = CreateMovieStorage(dataRefH, dataRefType, 'TVOD', smSystemScript, newMovieActive, theDataHandler, &theQTMovie);
// theStatus = GetMoviesError(); // Why use this when CreateMovieStorage returns an oserr?
if (theStatus) [NSException raise:NSGenericException format:@"CreateMovieStorage() failed"];

NSError *theError = NULL;
QTMovie *theMovie = [QTMovie movieWithQuickTimeMovie:theQTMovie disposeWhenDone:YES error:&theError];
if (theMovie == NULL || theError != NULL) [NSException raise:NSGenericException format:@"-[QTMovie movieWithQuickTimeMovie:] failed."];

// mark the movie as editable
[theMovie setAttribute:[NSNumber numberWithBool:YES] forKey:QTMovieEditableAttribute];

return(theMovie);
}

////
- (void)addMP4Image:(NSImage *)inImage
{
QTTime theCurrentTime = QTMakeTime(30, 600);

// When adding images we must provide a dictionary specifying the codec attributes
NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
	@"mp4v", QTAddImageCodecType,
	[NSNumber numberWithLong:codecLowQuality], QTAddImageCodecQuality,
	NULL];
[self addImage:inImage forDuration:theCurrentTime withAttributes:theAttributes];
}

- (BOOL)writeFlattenedToFile:(NSString *)inPath
{
NSDictionary *theAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:QTMovieFlatten];
return([self writeToFile:inPath withAttributes:theAttributes]);
}

#pragma mark -

- (QTDataReference *)defaultDataReference
{
QTDataReference *theQTDataReference = NULL;

DataReferenceRecord theDataReference;
OSStatus theStatus = GetMovieDefaultDataRef([self quickTimeMovie], &theDataReference.dataRef, &theDataReference.dataRefType);
if (theStatus != noErr) [NSException raise:NSGenericException format:@"GetMovieDefaultDataRef() failed with %d", theStatus];

if (theDataReference.dataRefType == 0)
	{
	if ([[self tracks] count] > 0)
		{
		QTTrack *theTrack = [[self tracks] objectAtIndex:0];
		Track theQTTrack = [theTrack quickTimeTrack];
		Media theMedia = GetTrackMedia(theQTTrack);
		short theCount = 0;
		theStatus = GetMediaDataRefCount(theMedia, &theCount);
		if (theStatus != noErr) [NSException raise:NSGenericException format:@"GetMediaDataRefCount() failed with %d", theStatus];
		theStatus = GetMediaDataRef(theMedia, 0, &theDataReference.dataRef, &theDataReference.dataRefType, NULL);
		if (theStatus != noErr) [NSException raise:NSGenericException format:@"GetMediaDataRef() failed with %d", theStatus];
		if (theDataReference.dataRefType == 0) [NSException raise:NSGenericException format:@"GetMediaDataRef() did not return a data reference"];
		}
	}

theQTDataReference = [QTDataReference dataReferenceWithDataReferenceRecord:theDataReference];

return(theQTDataReference);
}

- (QTMovie *)movieWithVisualContext:(QTVisualContextRef)inVisualContext
{
DataReferenceRecord theDataReference = [[self defaultDataReference] dataReferenceRecord];

// Use the DataReference to create a new Movie (that uses the same data as the passed in movie)
QTNewMoviePropertyElement theNewMovieProperties[] = {  
	{ kQTPropertyClass_DataLocation, kQTDataLocationPropertyID_DataReference, sizeof(theDataReference), &theDataReference, 0 },
	{ kQTPropertyClass_Context, kQTContextPropertyID_VisualContext, sizeof(inVisualContext), &inVisualContext, 0 },
	};
Movie theMovie = NULL;
OSStatus theStatus = NewMovieFromProperties(sizeof(theNewMovieProperties) / sizeof(theNewMovieProperties[0]), theNewMovieProperties, 0, NULL, &theMovie);
if (theStatus != noErr) [NSException raise:NSGenericException format:@"NewMovieFromProperties - failed with %d", theStatus];

// Create a new QTMovie with the Movie...
NSError *theError = NULL;
QTMovie *theNewMovie = [QTMovie movieWithQuickTimeMovie:theMovie disposeWhenDone:YES error:&theError];
if (theNewMovie == NULL) [NSException raise:NSGenericException format:@"Could not create QTMovie - %@", theError];

return(theNewMovie);
}

@end
