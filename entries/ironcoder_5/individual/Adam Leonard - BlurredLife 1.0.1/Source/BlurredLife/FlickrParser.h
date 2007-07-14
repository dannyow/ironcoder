//
//  FlickrParser.h
//  BlurredLife
//
//  Created by Adam Leonard on 3/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FlickrParser : NSObject 
{
	id delegate; //MUST IMPLEMENT: flickrParser:didFindPhotoURLs:
	NSURL *_URL;
	NSMutableArray *_results;

}
- (id)initWithFlickrGroupID:(NSString *)groupID
				   delegate:(id)aDelegate;
- (void)retrievePhotoURLs;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;

-(void)informDelegateOfFailure;
@end
