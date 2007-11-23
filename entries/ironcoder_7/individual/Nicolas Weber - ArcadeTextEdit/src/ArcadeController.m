//
//  ArcadeController.m
//  ArcadeTextEdit
//
//  Created by Nicolas Weber on 11/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ArcadeController.h"

#import <Quartz/Quartz.h>
#import <QuartzCore/QuartzCore.h>

#import "AnimationLayer.h"

inline int max(int a, int b)
{
    return a > b ? a : b;
}

@interface NSSound (PlayResource)

+ (void)playResource:(NSString *)name;

@end

@implementation NSSound (PlayResource)

+ (void)playResource:(NSString *)name
{
    NSString *file = [[NSBundle mainBundle] pathForResource:name ofType:@"wav"];
    NSSound *sound = [[NSSound alloc] initWithContentsOfFile:file byReference:YES];
    [sound setDelegate:sound];
    [sound play];
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
    // XXX: assert(sound == self)
    [sound release];
}

@end

@implementation ArcadeController

- (id)init
{
    if (![super init])
        return nil;

    // have to be all lower case
    keywords = [[NSSet setWithObjects: @"for", @"xx", @"arcadetextedit",
                 @"a", @"is", @"ironcoder", @"gruber", @"writing", @"some",
                 @"i", @"this", @"that", @"to", @"hello", @"mac", @"apple",
                 @"text", @"so", @"the", @"and", @"foo", @"fun", @"like",
                 @"test", @"testing", @"import", @"include", @"int",
                 @"nsstring", @"void", @"coreanimation", @"animation",
                 @"speed", @"slow", @"fast", @"quick", @"effect", @"sound",
                 @"it", @"cool", @"mario", @"nes", @"arcarde", @"retro",
                 @"snes", @"music", @"editor", @"annoying", @"you",
                 @"insanely", @"great", @"woot", @"w00t", @"hallo", @"not",
                 @"much", @"bla", @"layer", @"layerkit", @"play", @"woohoo",
                 @"while", @"stuff", @"wow", @"well",
                 nil] retain];
    
    // XXX: preload sounds
    sounds = [[NSArray alloc] initWithObjects:@"sound0", @"sound1", @"sound2",
              @"sound3", @"sound4"];
    
    score = 0;
    
    return self;
}

- (void)dealloc
{
    NSLog(@"dealloc\n");
    [keywords release];
    [sounds release];
    [background release];
    [super dealloc];
}

- (void)didBecomeMain:(NSNotification *)notification
{
    if (![background play])
        [background resume];
}

- (void)didResignMain:(NSNotification *)notification
{
    [background pause];
}

- (CGImageRef)loadImage:(NSString *)name
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString* imageName = [bundle pathForResource:@"cloud0" ofType:@"png"];
    NSImage* imageObj = [[NSImage alloc] initWithContentsOfFile:imageName];
    [imageObj autorelease];
    
    return [(NSBitmapImageRep *)[imageObj bestRepresentationForDevice:nil]
            CGImage];
}

- (void)maximizeLayer:(CALayer *)layer
{
    CAConstraint *constraint;
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMinX
                                            relativeTo:@"superlayer" attribute:kCAConstraintMinX];
    [layer addConstraint:constraint];
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMaxX
                                            relativeTo:@"superlayer" attribute:kCAConstraintMaxX];
    [layer addConstraint:constraint];
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMinY
                                            relativeTo:@"superlayer" attribute:kCAConstraintMinY];
    [layer addConstraint:constraint];
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMaxY
                                            relativeTo:@"superlayer" attribute:kCAConstraintMaxY];
    [layer addConstraint:constraint];
}

- (void)awakeFromNib
{
	  // Register for "text changed" notifications of our text storage:
	  [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(processEditing:)
        name:NSTextStorageDidProcessEditingNotification
			  object:[textView textStorage]];

    // we might have more levels in the future (XXX), each with its own
    // background music, but for now keep things simple
    NSString *file = [[NSBundle mainBundle] pathForResource:@"bg" ofType:@"mid"];
    background = [[NSSound alloc] initWithContentsOfFile:file byReference:YES];
    [background setLoops:YES];  // 10.5 only!

    // start/pause background music on window activation/deactivation
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didBecomeMain:)
        name:NSWindowDidBecomeMainNotification object:window];
    [center addObserver:self selector:@selector(didResignMain:)
        name:NSWindowDidResignMainNotification object:window];

    [textView setSelectedRange:NSMakeRange([[textView string] length], 0)];
    
    // CGCreateColorCreateGenericRGB does color space conversion -- we don't
    // want this for the background color (nes emus don't do color correction!)
//    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
//    CGFloat marioBg[] = { .373, .592, 1, 1 };
//    CGColorRef color = CGColorCreate(cs, marioBg);
//    [[window contentView] layer].backgroundColor = color;
//    CGColorRelease(color);
//    CGColorSpaceRelease(cs);
    
    NSString* bgFile = [[NSBundle mainBundle] pathForResource:@"bg0" ofType:@"qtz"];
    backgroundLayer = [QCCompositionLayer compositionLayerWithFile:bgFile];
    [self maximizeLayer:backgroundLayer];
    [[[window contentView] layer] setLayoutManager:[CAConstraintLayoutManager layoutManager]];

    
    animationLayer = [AnimationLayer layer];
    [[textView layer] setLayoutManager:[CAConstraintLayoutManager layoutManager]];
    [self maximizeLayer:animationLayer];
    [[textView layer] addSublayer:animationLayer];

    
    //[textView layer].backgroundColor = CGColorCreateGenericRGB(1, 1, 1, .3);
    //[scrollView layer].backgroundColor = CGColorCreateGenericRGB(1, 1, 1, .3);
    //[scrollView layer].transform = CATransform3DMakeRotation(2, 0, 1, 0);
    
    scoreLayer = [CATextLayer layer];
    scoreLayer.font = @"Synchro LET";
    scoreLayer.foregroundColor = CGColorCreateGenericRGB(1, 0, 0, 1);
    CAConstraint* constraint;
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMinX
                                            relativeTo:@"superlayer" attribute:kCAConstraintMinX
                                                offset:56];
    [scoreLayer addConstraint:constraint];
    constraint = [CAConstraint constraintWithAttribute:kCAConstraintMaxY
                                            relativeTo:@"superlayer" attribute:kCAConstraintMaxY
                                                offset:-15];
    [scoreLayer addConstraint:constraint];
    [self incrementScore:0];
    
    filter = [CIFilter filterWithName:@"CIBloom"];
    [filter setDefaults];
    // name the filter so we can use the keypath to animate the inputIntensity
    // attribute of the filter
    [filter setName:@"pulseFilter"];
    
    //[filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
    [filter setValue:[NSNumber numberWithFloat:0.0] forKey:@"inputIntensity"];
    [scoreLayer setFilters:[NSArray arrayWithObject:filter]];
    //[[textView layer] setFilters:[NSArray arrayWithObject:filter]];
    //[[[window contentView] layer] setFilters:[NSArray arrayWithObject:filter]];
    //[backgroundLayer setFilters:[NSArray arrayWithObject:filter]];
    
    
    // XXX: use a quartz composition for the background
    CALayer *cloud0 = [CALayer layer];
    CGImageRef image = [self loadImage:@"clouds0"];
    cloud0.contents = (id)image;
    cloud0.bounds = CGRectMake(0, 0, 1.5*CGImageGetWidth(image), 1.5*CGImageGetHeight(image));
    cloud0.position = CGPointMake(40, 80);
    
    [[[window contentView] layer] insertSublayer:backgroundLayer below:[scrollView layer]];
    [[[window contentView] layer] insertSublayer:scoreLayer below:[scrollView layer]];
}

- (NSArray *)wordsInRange:(NSRange)range forString:(NSString *)string
{
    NSCharacterSet *whitespace =
        [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:2];
    
    int location = max(range.location - 1, 0);
    
    // make sure we start at the first non-ignored character at the left of the range.
    // if we start at ignored characters, skip forward to a valid character
    while (location > 0
      && ![whitespace characterIsMember:[string characterAtIndex:location]]) {
        --location;
    }
    
    while (location < range.location + range.length
        && [whitespace characterIsMember:[string characterAtIndex:location]]) {
        ++location;
    }
    
    // at this point, we're at a valid character at the start of a word.
    // skip valid characters, and each time we hit an invalid char, insert a
    // word (only exactly one word most of the time :-P)
    int start = location;
    for (++location; location < NSMaxRange(range); ++location) {
        if ([whitespace characterIsMember:[string characterAtIndex:location]]) {
            if (![whitespace characterIsMember:[string characterAtIndex:location - 1]]) {
                NSRange wordRange = NSMakeRange(start, location - start);
                //[result addObject:[string substringWithRange:wordRange]];
                
                // Yay for Cocoa!
                [result addObject:NSStringFromRange(wordRange)];
                start = -1;
            }
        } else {
            if (start == -1) {
                start = location;
            }
        }
    }
    
    return result;
}

- (NSPoint)viewCoordinatesOfGlyph:(NSUInteger)glyphIndex
{
    // assumes the text container's origin has its default value
    
    NSLayoutManager *layoutManager = [textView layoutManager];
    //NSLog(@"%@\n", [textView string]);

    // textStorage:edited:range:changeInLength:invalidatedRange: is called
    // on the text view's layoutmanagers _after_ we're invoked. so
    // this is not yet done when processEditing is called, so the glyph index
    // might be invalid (when pasting into a previously empty text view for
    // example). force layout (this method was introduced in 10.5! how did you
    // do that before?)
    // ...doesn't seem to help anyways. well, it works as long as you don't
    // paste text :-P
    //[layoutManager ensureGlyphsForCharacterRange:NSMakeRange(glyphIndex, 1)];
    //[layoutManager ensureLayoutForCharacterRange:NSMakeRange(glyphIndex, 1)];
    
    NSRect lineFragmentRect =
        [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex
            effectiveRange:NULL];

    NSPoint layoutLocation = [layoutManager locationForGlyphAtIndex:glyphIndex];
    
    // Here layoutLocation is the location (in container coordinates) where
    // the glyph was laid out.
    layoutLocation.x += lineFragmentRect.origin.x;
    layoutLocation.y += lineFragmentRect.origin.y;
    return layoutLocation;
}

- (void)incrementScore:(int)dScore
{
    score += dScore;
    
    scoreLayer.string = [NSString stringWithFormat:@"Score: %d", score];

    CABasicAnimation* anim = [CABasicAnimation animation];
    if (dScore < 10) {
        // the score should glow while you're typing
        anim.keyPath = @"filters.pulseFilter.inputIntensity";
        anim.fromValue = [NSNumber numberWithFloat: 1.0];
        anim.toValue = [NSNumber numberWithFloat: 0.0];
        anim.duration = 1.5;
        [scoreLayer addAnimation:anim forKey:@"typingAnim"];
    } else {
        // it should be a bit bigger when typing keywords
        anim.keyPath = @"transform.scale";
        anim.fromValue = [NSNumber numberWithFloat: 1.2];
        anim.toValue = [NSNumber numberWithFloat: 1.0];
        anim.duration = .4;
        [scoreLayer addAnimation:anim forKey:@"growingAnim"];
    }

}

- (void)processEditing:(NSNotification *)notification
{
    NSTextStorage *textStorage = [notification object];
    NSRange range = [textStorage editedRange];
    NSString *text = [textStorage string];
    
    if (range.length == 0) {
        // backspace
        return;
    }
    
    // sure sign i'm running out of time:
    [self incrementScore:7];
    
    // check if there's a whitespace in the inserted range. if so,
    // scan backwards through the text until we leave the range. check all words
    // discovered that way.
    // better yet, start at the left of range. that's slower for very long
    // words, but that won't happen often and this is just a fun app after all.
    
    NSArray *words = [self wordsInRange:range forString:text];
    
    // for each detected word, see if it's a word that should be highlighted.
    // if so, schedule an animation for it.
    
    NSEnumerator *e = [words objectEnumerator];
    NSString *wordRangeString;
    while (wordRangeString = [e nextObject]) {
        
        // Yay for Cocoa!
        NSRange wordRange = NSRangeFromString(wordRangeString);
        
        NSString *word = [text substringWithRange:wordRange];
        //NSLog(@"%@ %@\n", wordRangeString, word);
        
        // TODO: adding spaces after an already existing word re-adds it.
        // oh well, good enough for now.
        if ([keywords containsObject:[word lowercaseString]]) {
            NSPoint loc = [self viewCoordinatesOfGlyph:wordRange.location];

            // this doesn't quite work if the string wraps over several lines
            // in the text view. but that's extremely unlikely, and it's not
            // really a problem anyways if the effect is a bit off... :-P
            
            // animation layer has (0, 0) in the lower left corner, the text
            // view has (0, 0) in the upper left corner -- flip vertically
            loc.y = [textView frame].size.height - loc.y - 1;            

            [animationLayer addString:[textStorage attributedSubstringFromRange:wordRange]
                atPosition:loc];
            [NSSound playResource:[sounds objectAtIndex:rand()%5]];
            
            [self incrementScore:100];
        }
    }
}

@end
