//
//  SPTemplate.m
//  SpiPhone
//
//  Created by Zac White on 8/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "SPTemplate.h"


@implementation SPTemplate

- (void)setIndex:(NSString *)newIndex{
	[index release];
	index = [newIndex retain];
}

- (NSString *)index { return index; }

- (void)setImageTemplate:(NSString *)newImageTemplate{
	[imageTemplate release];
	imageTemplate = [newImageTemplate retain];
}

- (NSString *)imageTemplate { return imageTemplate; }

- (void)setImagePage:(NSString *)newImagePage{
	[imagePage release];
	imagePage = [newImagePage retain];
}

- (NSString *)imagePage { return imagePage; }

- (NSString *)buildImagePageWithImage:(NSString *)path{
	NSMutableString *imagePageTemp = [NSMutableString stringWithString:imagePage];
	
	[imagePageTemp replaceOccurrencesOfString:@"<% url %>" withString:path options:NSCaseInsensitiveSearch range:NSMakeRange(0,[imagePageTemp length])];
	
	return [imagePageTemp description];
}

- (NSString *)buildPageWithImagesAtPath:(NSString *)path{
	//go through and construct all the necessary paths and pages given the images.
	
	NSDirectoryEnumerator *dir = [[NSFileManager defaultManager] enumeratorAtPath:path];
	
	NSMutableString *indexString = [NSMutableString stringWithString:index];
	NSMutableString *imagesString = [[NSMutableString alloc] initWithCapacity:10];
	NSString *itemPath;
	while(itemPath = [dir nextObject]){
		if([itemPath isEqualToString:@".DS_Store"]) continue;
		NSLog(@"path: %@", itemPath);
		NSMutableString *imageTemplateTemp = [NSMutableString stringWithString:imageTemplate];
		[imageTemplateTemp replaceOccurrencesOfString:@"<% url %>" withString:itemPath options:NSCaseInsensitiveSearch range:NSMakeRange(0,[imageTemplateTemp length])];
		
		//NSRange range = NSMakeRange(0, [itemPath rangeOfString:@"."].location);
		[imageTemplateTemp replaceOccurrencesOfString:@"<% link %>" withString:[itemPath stringByAppendingString:@".html"] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imageTemplateTemp length])];
		
		[imagesString appendString:imageTemplateTemp];
	}
	
	[indexString replaceOccurrencesOfString:@"<% images %>" withString:imagesString options:NSCaseInsensitiveSearch range:NSMakeRange(0, [indexString length])];
	
	[imagesString release];
	return [indexString description];
}

- (id)initWithPathToTemplateFiles:(NSString *)basePath{
	if(!(self = [super init])) return nil;
	
	[self setIndex:[NSString stringWithContentsOfFile:[basePath stringByAppendingString:@"/index.html"]]];
	[self setImageTemplate:[NSString stringWithContentsOfFile:[basePath stringByAppendingString:@"/image_template.html"]]];
	
	return self;
}

@end
