//
//  ALifeScreenSaverView.m
//  ALifeScreenSaver
//
//  Created by Chip Coons on 3/30/07.
//  Copyright (c) 2007, GWSoftware. All rights reserved.
//

#import "ALifeScreenSaverView.h"

@implementation ALifeScreenSaverView


- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1/60.0];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)skipEntity;
{
    [self setCurrentEntity:[_controller nextEntity]];
	[self resetCounter];
	[_currentMap resetField];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    [self updateDisplay];
}


- (void)updateDisplay;
{
    NSRect rect = [self bounds];
    [super drawRect:rect];
    
    int xIndex = 0;
    int yIndex = 0;
    
    float w = rect.size.width/32.0;
    float h = rect.size.height/32.0;
    
    float x, y;
    int locValue;
    NSRect workingRect;
    
    for(xIndex=0; xIndex < [[self currentMap] width]; xIndex++){
        x = rect.origin.x + (xIndex * w);
        for(yIndex=0; yIndex <[[self currentMap] height]; yIndex++){
            y = rect.origin.y + (yIndex * h);
            locValue = [[self currentMap] valueAtLocation:NSMakePoint(xIndex,yIndex)];
            
            workingRect = NSMakeRect(x, y, w, h);
            
            [[NSColor lightGrayColor] set];
            [NSBezierPath strokeRect:workingRect];
            switch(locValue){
                case 0:{
                    [[NSColor whiteColor] set];
                    break;
                }
                case 1:{
                    [[NSColor greenColor] set];
                    break;
                }
                default:{
                    [[NSColor grayColor] set];
                    break;
                }
            }
            if(NSEqualPoints(NSMakePoint(xIndex,yIndex), [_currentEntity currentLocation])){
                [[NSColor blueColor] set];
            }
            [NSBezierPath fillRect:NSInsetRect(workingRect, 1.0, 1.0)];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)animateOneFrame
{   
    [_controller setRemainingRuntime:runCounter];
    if([self entityWillMove]){
        [_currentEntity executeStepOnMap:_currentMap];
        [_controller updateEntity:_currentEntity];
        runCounter--;
    }else{
        runCounter = -1;
    }
	
	if(runCounter < 0){
		[self setCurrentEntity:[_controller nextEntity]];
		[self resetCounter];
		[_currentMap resetField];
	}
    [self updateDisplay];
    
    return;
}


- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}


- (alifeMap*)currentMap;
{
    return _currentMap;
}

- (void)setCurrentMap:(alifeMap *)theMap;
{
    if(theMap == _currentMap)
        return;
    [theMap retain];
    [_currentMap release];
    _currentMap = theMap;
}


- (alifeEntity*)currentEntity;
{
    return _currentEntity;
}

- (void)setCurrentEntity:(alifeEntity *)theEntity;
{
    if(theEntity == _currentEntity)
        return;
    [theEntity retain];
    [_currentEntity release];
    _currentEntity = theEntity;
}


- (id)controller;
{
    return _controller;
}

- (void)setController:(id)aController;
{
    if(aController == _controller)
        return;
    
    [aController retain];
    [_controller release];
    _controller = aController;
    [self resetCounter];

}

- (void)resetCounter;
{
    if(!_controller){
        runCounter = 600;
    }else{
        runCounter = [_controller runDuration];
    }
}

- (int)count;
{
    return runCounter;
}


- (BOOL)entityWillMove;
{
    BOOL result = NO;
    NSString *genes = [[_currentEntity genes] geneAsString];
    NSCharacterSet *moveSet = [NSCharacterSet characterSetWithCharactersInString:@"5"];
    
    NSScanner *theScanner = [NSScanner scannerWithString:genes];
    while([theScanner isAtEnd] == NO){
        if([theScanner scanUpToCharactersFromSet:moveSet intoString:NULL] &&
           ([theScanner isAtEnd] == NO)){
				result = YES;
				break;
           }
    }
    
    return result;
    
}

@end
