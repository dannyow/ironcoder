//
//  AdventureEvent.m
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import "AdventureEvent.h"
#import "Util.h"


@implementation NSBundle (loadByFilename)
- (NSURL *)urlFromFilename:(NSString *)theFilename
{
	return [NSURL fileURLWithPath:[self pathForResource:theFilename ofType:nil]];
}
@end


@implementation AdventureEvent

- (id)init
{
	if( (self = [super init]) ) {
		_npcRight = NULL;
		_npcLeft = NULL;
		_background = NULL;
		_text = nil;
		_name = nil;
		
		_sound = nil;
		
		_description = [[NSMutableDictionary alloc] init];
		_mediaDict = nil;
	}

	return self;
}

- (void)dealloc
{
	[_name release];
	[_text release];
	[_mediaDict release];
	[self unloadResources];
	
	[_description release];

	[super dealloc];
}

- (id)initWithDictionary:(NSDictionary *)aDict
{
	if( (self = [self init]) ) {
		_description = [[NSMutableDictionary alloc] initWithDictionary:aDict];
		_text = [[_description objectForKey:@"text"] retain];
		_name = [[_description objectForKey:@"name"] retain];
	}
	
	return self;
}

- (void)unloadResources
{
	CGImageRelease(_npcRight);
	_npcRight = NULL;
	CGImageRelease(_npcLeft);
	_npcLeft = NULL;
	CGImageRelease(_background);
	_background = NULL;
	[_sound release];
	_sound = nil;
	
	[_mediaDict release];
	_mediaDict = nil;
}

- (void)loadResourcesFromPath:(NSString *)thePath withMediaDict:(NSDictionary *)aMediaDict
{
	[self unloadResources];
	CGImageSourceRef imageSource = NULL;
	_mediaDict = [[NSMutableDictionary alloc] init];
	
	NSString *npcRightFile = [_description objectForKey:@"right"];
	if( npcRightFile ) {
		_npcRight = (CGImageRef)[aMediaDict objectForKey:npcRightFile];
		if( !_npcRight ) {
			imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:[thePath stringByAppendingPathComponent:npcRightFile]], NULL);
			_npcRight = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			CFRelease(imageSource);
		} else
			CGImageRetain( _npcRight ); 
	}
	if( _npcRight )
		[_mediaDict setObject:(id)_npcRight forKey:npcRightFile];
	
	NSString *npcLeftFile = [_description objectForKey:@"left"];
	if( npcLeftFile ) {
		_npcLeft = (CGImageRef)[aMediaDict objectForKey:npcLeftFile];
		if( !_npcLeft ) {
			imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:[thePath stringByAppendingPathComponent:npcLeftFile]], NULL);
			_npcLeft = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			CFRelease(imageSource);
		} else
			CGImageRetain( _npcLeft );
	}
	if( _npcLeft )
		[_mediaDict setObject:(id)_npcLeft forKey:npcLeftFile];
	
	NSString *backgroundFile = [_description objectForKey:@"background"];
	if( backgroundFile ) {
		_background = (CGImageRef)[aMediaDict objectForKey:backgroundFile];
		if( !_background ) {
			imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:[thePath stringByAppendingPathComponent:backgroundFile]], NULL);
			_background = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
			CFRelease(imageSource);
		} else
			CGImageRetain( _background );
	}
	if( _background ) {
		[_mediaDict setObject:(id)_background forKey:backgroundFile];
		//printf("background (%s) retain count = %d\n", [backgroundFile UTF8String], (unsigned int)CFGetRetainCount(_background));
	}
	
	NSString *soundFile = [_description objectForKey:@"sound"];
	if( soundFile ) {
		_sound = [aMediaDict objectForKey:soundFile];
		if( !_sound ) {
			NSError *theError = nil;
			_sound = [[QTMovie alloc] initWithFile:[thePath stringByAppendingPathComponent:soundFile] error:&theError];
		} else
			[_sound retain];
	}
	if( _sound )
		[_mediaDict setObject:_sound forKey:soundFile];
}

- (NSDictionary *)mediaDict
{
	return [NSDictionary dictionaryWithDictionary:_mediaDict];
}


- (CGImageRef)npcRight
{
	return _npcRight;
}
- (void)setNPCRight:(CGImageRef)newImage
{
	if( newImage == _npcRight )
		return;
	
	CGImageRelease(_npcRight);
	_npcRight = CGImageRetain(newImage);
}

- (CGImageRef)npcLeft
{
	return _npcLeft;
}
- (void)setNPCLeft:(CGImageRef)newImage
{
	if( newImage == _npcLeft )
		return;
	
	CGImageRelease(_npcLeft);
	_npcLeft = CGImageRetain(newImage);
}


- (CGImageRef)background
{
	return _background;
}
- (void)setBackground:(CGImageRef)newImage
{
	if( newImage == _background )
		return;
	
	CGImageRelease(_background);
	_background = CGImageRetain(newImage);
}

- (NSString *)text
{
	return _text;
}
- (void)setText:(NSString *)newText
{
	if( newText == _text )
		return;
	
	[_text release];
	_text = [newText retain];
}
- (void)setName:(NSString *)newName
{
	if( newName == _name )
		return;

	[_name release];
	_name = [newName retain];
}
- (NSString *)name
{
	return _name;
}

- (QTMovie *)sound
{
	return _sound;
}
@end
