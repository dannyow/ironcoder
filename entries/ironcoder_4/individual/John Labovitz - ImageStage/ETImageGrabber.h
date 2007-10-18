//
//  ETImageGrabber.h
//  ImageStage
//
//  Created by John Labovitz on 10/27/06.
//  Copyright 2006 . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ETImageGrabber : NSObject {
	
	id _delegate;
	NSString *_query;
	NSMutableDictionary *_history;
	int _totalResultsAvailable;
	NSMutableArray *_connections;
}

- (id)initWithQuery:(NSString *)query;

- (NSMutableArray *)connections;
- (void)setConnections:(NSMutableArray *)connections;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (void)grabImage;

- (BOOL)isDownloading;

@end