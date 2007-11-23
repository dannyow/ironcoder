//
//  AdventureEvent.h
//  AdventureTime
//
//  Created by Nur Monson on 11/10/07.
//  Copyright 2007 theidiotproject. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QTKit/QTKit.h>

@interface NSBundle (loadByFilename)
- (NSURL *)urlFromFilename:(NSString *)theFilename;
@end

@interface AdventureEvent : NSObject {
	CGImageRef _npcRight;
	CGImageRef _npcLeft;
	CGImageRef _background;
	
	NSString *_text;
	NSString *_name;
	
	QTMovie *_sound;
	
	NSMutableDictionary *_mediaDict;
	NSMutableDictionary *_description;
}

- (id)initWithDictionary:(NSDictionary *)aDict;

- (void)unloadResources;
- (void)loadResourcesFromPath:(NSString *)thePath withMediaDict:(NSDictionary *)aMediaDict;
- (NSDictionary *)mediaDict;

- (CGImageRef)npcRight;
- (void)setNPCRight:(CGImageRef)newImage;
- (CGImageRef)npcLeft;
- (void)setNPCLeft:(CGImageRef)newImage;
- (CGImageRef)background;
- (void)setBackground:(CGImageRef)newImage;
- (NSString *)text;
- (void)setText:(NSString *)newText;
- (void)setName:(NSString *)newName;
- (NSString *)name;
- (QTMovie *)sound;
@end
