//
//  LeController.m
//  iTunesXPlugIn
//
//  Created by August Mueller on 5/19/06.
//  Copyright 2006 Flying Meat Inc.. All rights reserved.
//

#import "LEController.h"
#import "iTunesVisualAPI.h"

#define debug NSLog
#define MAX_RESULTS 400
#define FETCH_COUNT 50
//	Another approach would be to allow changing these through NSUserDefaults
#define	SCROLL_DELAY_SECONDS	0.05	// time between animation frames
#define SCROLL_AMOUNT_PIXELS	1.00	// amount to scroll in each animation frame


//	We pad this many blank lines at the end of the text, so the visible part
//	of the text can scroll out of sight.
#define	BLANK_LINE_COUNT		50

@interface LEController (Private)
- (void)index;
- (void) startScrollingAnimation;
- (void) stopScrollingAnimation;
- (void) display;
@end


@implementation LEController

+ (id) controller {
    static LEController *me = nil;
    
    NSLog(@"%s:%d", __FUNCTION__, __LINE__);
    
    if (!me) {
        NSApplicationLoad();
        // For Cocoa-based plugins, don't use [window makeKeyAndOrderFont:]. Instead use the slightly longer: [window orderFront:self]; [window makeKeyWindow];
        me = [[LEController alloc] initWithWindowNibName:@"OverlanWin"];
        [me index];
        [me display];
    }
    
    return me;
}

- (void) index {
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    
    NSArray *ar = [NSArray arrayWithContentsOfFile:[myBundle pathForResource:@"poems" ofType:@"plist"]];
    [self setPoems:ar];
    
    [self setSkData:[NSMutableData data]];
    
    _skIndex = SKIndexCreateWithMutableData( (CFMutableDataRef)[self skData],
                                             nil,
                                             kSKIndexInverted,
                                             nil);
    
    SKLoadDefaultExtractorPlugIns();
    
    int idx = 1;
    NSEnumerator *enumerator = [ar objectEnumerator];
    NSString *poem;
    while ((poem = [enumerator nextObject])) {
        
        NSString *name = [NSString stringWithFormat:@"Poem #%d", idx];
        NSString *sidx = [NSString stringWithFormat:@"%d", idx];
        
        SKDocumentRef aDocument = SKDocumentCreate((CFStringRef)name, nil, (CFStringRef)sidx);
        
        if (!SKIndexAddDocumentWithText(_skIndex,
                                        aDocument,
                                        (CFStringRef)poem,
                                        YES)) // replaceable
        {
            NSLog(@"There was a problem adding %d to the search index", idx);
        }
        
        
        CFRelease(aDocument);
        
        idx++;
    }
    
    if (!SKIndexFlush(_skIndex)) {
        NSLog(@"A problem was encountered flushing the index.");
    }
}

- (SKIndexRef)skIndex {
    return _skIndex;
}
- (void)setSkIndex:(SKIndexRef)newSkIndex {
    _skIndex = newSkIndex;
}


- (NSMutableData *)skData {
    return _skData; 
}
- (void)setSkData:(NSMutableData *)newSkData {
    [newSkData retain];
    [_skData release];
    _skData = newSkData;
}

- (NSArray *) searchFor:(NSString*)searchTerm {
    
    searchTerm = [searchTerm stringByAppendingString:@"*"];
    
    SKIndexRef skIndex = [self skIndex];
    
    if (!skIndex) {
        NSBeep();
        NSLog(@"No index has been created");
        return nil;
    }
    
    float           _maxScore = 0.0;
    CFTimeInterval  sleepTime = 1;
    CFIndex         idx;
    CFIndex         tmpIndex;
    SKSearchRef     searchRef;
    SKDocumentID    *resultID = (SKDocumentID *) calloc(FETCH_COUNT, sizeof(SKDocumentID));
    CFStringRef     *foundNames = (CFStringRef *) calloc(FETCH_COUNT, sizeof(CFStringRef));
    float           *scoresArray= (float *) calloc(FETCH_COUNT, sizeof(float));
    NSMutableArray  *returnArray = [NSMutableArray array];
    CFStringRef     searchString = (CFStringRef)searchTerm;
    
    SKIndexFlush(skIndex);
    
    SKSearchOptions options = kSKSearchOptionDefault;//kSKSearchOptionFindSimilar;
        
    searchRef = SKSearchCreate(skIndex, searchString, options);
    [(id)searchRef autorelease];
    
    BOOL more = YES;
    
    while (more) {
        more = SKSearchFindMatches(searchRef, FETCH_COUNT, resultID, scoresArray, sleepTime, &tmpIndex);
        
        SKIndexCopyInfoForDocumentIDs(skIndex, tmpIndex, resultID, foundNames, NULL);
        
        for (idx = 0; idx < tmpIndex; idx++) {
            NSString *sidx  = (id)foundNames[idx];
            float score     = scoresArray[idx];
            
            if (score > _maxScore) {
                _maxScore = score;
            }
            
            NSMutableDictionary *d  = [NSMutableDictionary dictionaryWithObjectsAndKeys:sidx, @"sidx",
                [NSNumber numberWithFloat:score], @"originalScore",
                nil];
            
            [returnArray addObject:d];
        
            
            CFRelease(foundNames[idx]);
        }
        
    }
    
    free(resultID);
    free(foundNames);
    free(scoresArray);
    
    NSEnumerator *e = [returnArray objectEnumerator];
    NSMutableDictionary *d = 0x00;

    while ((d = [e nextObject])) {
        
        NSNumber *n = [d objectForKey:@"originalScore"];
        
        float x = ([n floatValue] / _maxScore);
        
        [d setObject:[NSNumber numberWithFloat:x] forKey:@"score"];
    }

    // now we got's to sort and fixup our scores.
    [returnArray sortUsingSelector:@selector(scoreCompare:)];
    
    return returnArray;
}

- (void) displayPoeteryFromResults:(NSArray *) ar {
    [[[textView textStorage] mutableString] setString:@""];
    
    NSEnumerator *e = [ar objectEnumerator];
    NSDictionary *info;
    while ((info = [e nextObject])) {
    	
        int poemIdx = [[info objectForKey:@"sidx"] intValue];
        
        NSMutableAttributedString *title = [[[NSMutableAttributedString alloc] init] autorelease];
        [[title mutableString] appendFormat:@"\n\n\n#%d\n", poemIdx];
        
        NSFont *f = [NSFont fontWithName:@"Zapfino" size:18];
        f = [[NSFontManager sharedFontManager] convertFont:f toHaveTrait:NSBoldFontMask];
        [title addAttribute:NSFontAttributeName value:f range:NSMakeRange(0,[title length])];
        [[textView textStorage] appendAttributedString:title];
        
        NSMutableAttributedString *poem = [[[NSMutableAttributedString alloc] init] autorelease];
        [[poem mutableString] appendString:[[self poems] objectAtIndex:poemIdx]];
        
        f = [NSFont fontWithName:@"Zapfino" size:13];
        [poem addAttribute:NSFontAttributeName value:f range:NSMakeRange(0,[poem length])];
        [poem addAttribute:NSForegroundColorAttributeName value:[NSColor disabledControlTextColor] range:NSMakeRange(0,[poem length])];
        [[textView textStorage] appendAttributedString:poem];
        
    }
    
    [self stopScrollingAnimation];
    [self startScrollingAnimation];
    
}

- (void) putUpYouSuckGoFindSomethingElseLoserDisplay {
    NSMutableAttributedString *as = [[[NSMutableAttributedString alloc] init] autorelease];
    
    [[as mutableString] appendString:@"You suck.\nEr, I mean I couldn't find anything remotely worthy of displaying here."];
    
    [as addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:14] range:NSMakeRange(0,9)];
    
    [[[textView textStorage] mutableString] setString:@""];
    [[textView textStorage] appendAttributedString:as];
    
    [self setTheSearchTerm:@""];
}

- (void) newTrack:(NSDictionary *)info searchStuff:(NSArray*)searchStuff {
    
    [self setCurrentSongInfo:info];
    
    NSMutableArray *ar = [NSMutableArray array];
    NSEnumerator *e = [searchStuff objectEnumerator];
    NSString *term;

    while ((term = [e nextObject])) {
    
        NSArray *r = [self searchFor:term];
        if ([r count]) {
            [ar addObjectsFromArray:r];
            [self setTheSearchTerm:term];
            break;
        }
    }
    
    if ([ar count]) {
        [self displayPoeteryFromResults:ar];
    }
    else {
        [self putUpYouSuckGoFindSomethingElseLoserDisplay];
    }
}

- (NSDictionary *)currentSongInfo {
    return currentSongInfo; 
}
- (void)setCurrentSongInfo:(NSDictionary *)newCurrentSongInfo {
    [newCurrentSongInfo retain];
    [currentSongInfo release];
    currentSongInfo = newCurrentSongInfo;
}

- (NSArray *)poems {
    return poems; 
}
- (void)setPoems:(NSArray *)newPoems {
    [newPoems retain];
    [poems release];
    poems = newPoems;
}


- (void) display {
    [[self window] orderFront:self];
}





//	Scroll to hide the top 'newAmount' pixels of the text
- (void) setScrollAmount: (float) newAmount
{
    //	Scroll so that (0, amount) is at the upper left corner of the scroll view
    //	(in other words, so that the top 'newAmount' scan lines of the text
    //	 is hidden).
    [[textScrollView documentView] scrollPoint: NSMakePoint (0.0, newAmount)];
    
    //	If anything overlaps the text we just scrolled, it won’t get redraw by the
    //	scrolling, so force everything in that part of the panel to redraw.
    {
        NSRect scrollViewFrame;
        
        //	Find where the scrollview’s bounds are, then convert to panel’s coordinates
        scrollViewFrame = [textScrollView bounds];
        scrollViewFrame = [[[self window] contentView] convertRect: scrollViewFrame  fromView: textScrollView];
        
        //	Redraw everything which overlaps it.
        [[[self window] contentView] setNeedsDisplayInRect: scrollViewFrame];
    }
}


//	Scroll one frame of animation
- (void) scrollOneUnit
{
    float	currentScrollAmount;
    
    //	How far have we scrolled so far?
    currentScrollAmount = [textScrollView documentVisibleRect].origin.y;
    
    //	Scroll one unit more
    [self setScrollAmount: (currentScrollAmount + SCROLL_AMOUNT_PIXELS)];
}

//	If we don't already have a timer, start one messaging us regularly
- (void) startScrollingAnimation
{
    //	Already scrolling?
    if (scrollingTimer != nil)
        return;
    
    //	Start a timer which will send us a 'scrollOneUnit' message regularly
    scrollingTimer = [[NSTimer scheduledTimerWithTimeInterval: SCROLL_DELAY_SECONDS
                                                       target: self
                                                     selector: @selector(scrollOneUnit)
                                                     userInfo: nil
                                                      repeats: YES] retain];
}

//	Stop the timer and forget about it
- (void) stopScrollingAnimation
{
    [scrollingTimer invalidate];
    
    [scrollingTimer release];
    scrollingTimer = nil;
}




- (NSString *)theSearchTerm {
    return theSearchTerm; 
}
- (void)setTheSearchTerm:(NSString *)newTheSearchTerm {
    [newTheSearchTerm retain];
    [theSearchTerm release];
    theSearchTerm = newTheSearchTerm;
}














@end

@implementation NSDictionary (VPDocumentSKAdditionsDictionarySortBruhaha)
- (NSComparisonResult) scoreCompare:(NSDictionary *)d {
    return [[self objectForKey:@"score"] compare:[d objectForKey:@"score"]] * -1;
}
@end


void LEVisualPluginHandler(OSType message,VisualPluginMessageInfo *messageInfo,void *refCon) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // NSLog(@"message: %d", message);
    
    switch (message)
	{
        case kVisualPluginIdleMessage:
            //debug(@"idle");
            break;
            
        case kVisualPluginInitMessage:
            debug(@"init");
            [LEController controller];
            break;
        
        case kVisualPluginRenderMessage:
            debug(@"kVisualPluginRenderMessage");
            break;
        
        case kVisualPluginSetWindowMessage:
            debug(@"kVisualPluginSetWindowMessage");
            NSLog(@"%d", messageInfo->u.setWindowMessage.drawRect.top);
            NSLog(@"%d", messageInfo->u.setWindowMessage.drawRect.left);
            NSLog(@"%d", messageInfo->u.setWindowMessage.drawRect.bottom);
            NSLog(@"%d", messageInfo->u.setWindowMessage.drawRect.right);
            break;
        
        case kVisualPluginShowWindowMessage:
            NSBeep();
            NSLog(@"%d", messageInfo->u.showWindowMessage.drawRect.top);
            NSLog(@"%d", messageInfo->u.showWindowMessage.drawRect.left);
            NSLog(@"%d", messageInfo->u.showWindowMessage.drawRect.bottom);
            NSLog(@"%d", messageInfo->u.showWindowMessage.drawRect.right);
            [[LEController controller] display];
            break;
            
        case kVisualPluginConfigureMessage:
            debug(@"kVisualPluginConfigureMessage");
        
        case kVisualPluginPlayMessage:
            debug(@"kVisualPluginPlayMessage");
            if (messageInfo->u.playMessage.trackInfo != nil) {
                
                ITTrackInfo info = *messageInfo->u.playMessage.trackInfo;
                
                NSMutableDictionary *playInfo = [NSMutableDictionary dictionary];
                
                NSMutableArray *searchStuff = [NSMutableArray array];
                
                if (info.name) {
                    NSString *junk = (id)CFStringCreateWithPascalString(kCFAllocatorDefault, info.name, CFStringGetSystemEncoding());
                    [playInfo setObject:junk forKey:@"name"];
                    [searchStuff addObject:junk];
                }
                if (info.artist) {
                    NSString *junk = (id)CFStringCreateWithPascalString(kCFAllocatorDefault, info.artist, CFStringGetSystemEncoding());
                    [playInfo setObject:junk forKey:@"artist"];
                    [searchStuff addObject:junk];
                }
                if (info.fileName) {
                    
                    NSString *junk = (id)CFStringCreateWithPascalString(kCFAllocatorDefault, info.fileName, CFStringGetSystemEncoding());
                    [playInfo setObject:junk forKey:@"fileName"];
                    [searchStuff addObject:junk];
                }
                if (info.album) {
                    NSString *junk = (id)CFStringCreateWithPascalString(kCFAllocatorDefault, info.album, CFStringGetSystemEncoding());
                    [playInfo setObject:junk forKey:@"album"];
                    [searchStuff addObject:junk];
                }
                
                debug(@"playInfo: %@", playInfo);
                
                [[LEController controller] newTrack:playInfo searchStuff:searchStuff];
            }
        
            break;
    }
    
    
	//VisualPluginData *visualPluginData = (VisualPluginData*) refCon;
    
    //visualPluginData,visualPluginData->destPort,&visualPluginData->destRect,false
    
    [pool release];
}


/*
 gdb -e /Applications/iTunes.app
 b ptrace
 commands 1
 set $r3=0
 set $pc=0x90051ef0
 cont
 end
 */
