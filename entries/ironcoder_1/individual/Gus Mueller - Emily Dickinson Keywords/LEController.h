//
//  LeController.h
//  iTunesXPlugIn
//
//  Created by August Mueller on 5/19/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LEController : NSWindowController {
    
    SKIndexRef                  _skIndex;
    NSMutableData               *_skData;
    
    IBOutlet NSTextView         *textView;
    IBOutlet NSScrollView		*textScrollView;
    NSTimer						*scrollingTimer;
    NSDictionary                *currentSongInfo;
    NSArray                     *poems;
    
    NSString                    *theSearchTerm;
}

+ (id) controller;

- (SKIndexRef)skIndex;
- (void)setSkIndex:(SKIndexRef)newSkIndex;
- (NSMutableData *)skData;
- (void)setSkData:(NSMutableData *)newSkData;
- (NSArray *)poems;
- (void)setPoems:(NSArray *)newPoems;
- (NSString *)theSearchTerm;
- (void)setTheSearchTerm:(NSString *)newTheSearchTerm;


- (NSDictionary *)currentSongInfo;
- (void)setCurrentSongInfo:(NSDictionary *)newCurrentSongInfo;

@end
