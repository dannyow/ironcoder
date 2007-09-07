//
//  SPTemplate.h
//  SpiPhone
//
//  Created by Zac White on 8/8/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SPTemplate : NSObject {
	NSString *index;
	NSString *imageTemplate;
	NSString *imagePage;
}

- (void)setIndex:(NSString *)newIndex;
- (NSString *)index;
- (void)setImageTemplate:(NSString *)newImageTemplate;
- (NSString *)imageTemplate;
- (void)setImagePage:(NSString *)newImagePage;
- (NSString *)imagePage;

- (NSString *)buildPageWithImagesAtPath:(NSString *)path;
- (NSString *)buildImagePageWithImage:(NSString *)path;
- (id)initWithPathToTemplateFiles:(NSString *)basePath;

@end
