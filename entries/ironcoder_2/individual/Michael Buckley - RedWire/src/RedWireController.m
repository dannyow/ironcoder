#import "RedWireController.h"
#import "RedWireView.h"
#import "Wire.h"

@implementation RedWireController

- (id)init
{
    timeLeft = 0;
    wirePaths[0] = CGPathCreateMutable();
    CGPathMoveToPoint(wirePaths[0], NULL, 50, 200);
    CGPathAddCurveToPoint(wirePaths[0], NULL, 150, 250, 200, 200, 350, 250);
    
    wirePaths[1] = CGPathCreateMutable();
    CGPathMoveToPoint(wirePaths[1], NULL, 50, 250);
    CGPathAddCurveToPoint(wirePaths[1], NULL, 200, 200, 150, 250, 350, 200);
    
    wirePaths[2] = CGPathCreateMutable();
    CGPathMoveToPoint(wirePaths[2], NULL, 50, 500);
    CGPathAddCurveToPoint(wirePaths[2], NULL, 200, 200, 150, 450, 350, 100);
    
    wirePaths[3] = CGPathCreateMutable();
    CGPathMoveToPoint(wirePaths[3], NULL, 50, 450);
    CGPathAddCurveToPoint(wirePaths[3], NULL, 150, 350, 150, 500, 350, 450);
    
    wirePaths[4] = CGPathCreateMutable();
    CGPathMoveToPoint(wirePaths[4], NULL, 50, 300);
    CGPathAddCurveToPoint(wirePaths[4], NULL, 150, 250, 150, 300, 350, 400);
    
    wirePaths[5] = CGPathCreateMutable();
    CGPathMoveToPoint(wirePaths[5], NULL, 50, 50);
    CGPathAddCurveToPoint(wirePaths[5], NULL, 150, 250, 150, 300, 350, 300);
    
    self = [super init];
    return self;
}

- (void)cut:(int)wireNumber
{
    Wire* temp = [wires objectAtIndex:wireNumber - 1];
    [temp retain];
    if(![temp cut]){
        if([temp active]){
            [self explode];
        }else{
            // cut the wire
            --wiresLeft;
        }
        [temp cut:YES];
    }
    [temp release];
    if(wiresLeft == 1){
        [bombTimer invalidate];
        [bombTimer release];
        game = NO;
    }
}

- (void)decreaseTime
{
    if(timeLeft > -1){
        --timeLeft;
        if(timeLeft == 0){
            [self explode];
        }
    }
    [theView setNeedsDisplay:YES];
}

- (void)drawInContext:(CGContextRef) context withRect:(CGRect*) rect
{
    if(explosion){
        [self drawWhiteInContext:context withRect:rect];
    }else{
        [self drawWiresInContext:context withRect:rect];
        [self drawTimerInContext:context withRect:rect];
    }
}

- (void)drawTimerInContext:(CGContextRef) context withRect:(CGRect*) rect
{
    int display[2];
    display[0] = (int) timeLeft / 10;
    display[1] = timeLeft - (display[0] * 10);
    int i;
    CGContextBeginPath(context);
    for(i = 0; i < 2; i++){
        int left = 44 * i;
        switch(display[i]){
            case 0:
                CGContextMoveToPoint(context, 164 + left, 6);
                CGContextAddLineToPoint(context, 164 + left, 23);
                CGContextMoveToPoint(context, 164 + left, 44);
                CGContextAddLineToPoint(context, 164 + left, 27);
                CGContextMoveToPoint(context, 168 + left, 4);
                CGContextAddLineToPoint(context, 194 + left , 4);
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left , 27);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                break;
        
            case 1:
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left , 27);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                break;
        
            case 2:
                CGContextMoveToPoint(context, 168 + left, 4);
                CGContextAddLineToPoint(context, 194 + left , 4);
                CGContextMoveToPoint(context, 168 + left, 25);
                CGContextAddLineToPoint(context, 194 + left , 25);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left , 27);
                CGContextMoveToPoint(context, 164 + left, 6);
                CGContextAddLineToPoint(context, 164 + left, 23);
                break;
                
            case 3:
                CGContextMoveToPoint(context, 168 + left, 4);
                CGContextAddLineToPoint(context, 194 + left , 4);
                CGContextMoveToPoint(context, 168 + left, 25);
                CGContextAddLineToPoint(context, 194 + left , 25);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left , 27);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                break;
                
            case 4:
                CGContextMoveToPoint(context, 164 + left, 44);
                CGContextAddLineToPoint(context, 164 + left, 27);
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left , 27);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                CGContextMoveToPoint(context, 168 + left, 25);
                CGContextAddLineToPoint(context, 194 + left , 25);
                break;
                
            case 5:
                CGContextMoveToPoint(context, 168 + left, 4);
                CGContextAddLineToPoint(context, 194 + left , 4);
                CGContextMoveToPoint(context, 168 + left, 25);
                CGContextAddLineToPoint(context, 194 + left , 25);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                CGContextMoveToPoint(context, 164 + left, 44);
                CGContextAddLineToPoint(context, 164 + left, 27);
                break;
        
            case 6:
                CGContextMoveToPoint(context, 168 + left, 4);
                CGContextAddLineToPoint(context, 194 + left , 4);
                CGContextMoveToPoint(context, 168 + left, 25);
                CGContextAddLineToPoint(context, 194 + left , 25);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                CGContextMoveToPoint(context, 164 + left, 44);
                CGContextAddLineToPoint(context, 164 + left, 27);
                CGContextMoveToPoint(context, 164 + left, 6);
                CGContextAddLineToPoint(context, 164 + left , 23);
                break;
                
            case 7:
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left , 27);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                break;
                
            case 8:
                CGContextMoveToPoint(context, 168 + left, 4);
                CGContextAddLineToPoint(context, 194 + left , 4);
                CGContextMoveToPoint(context, 168 + left, 25);
                CGContextAddLineToPoint(context, 194 + left , 25);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left, 27);
                CGContextMoveToPoint(context, 164 + left, 44);
                CGContextAddLineToPoint(context, 164 + left, 27);
                CGContextMoveToPoint(context, 164 + left, 6);
                CGContextAddLineToPoint(context, 164 + left , 23);
                break;
                
            case 9:
                CGContextMoveToPoint(context, 168 + left, 4);
                CGContextAddLineToPoint(context, 194 + left , 4);
                CGContextMoveToPoint(context, 168 + left, 25);
                CGContextAddLineToPoint(context, 194 + left , 25);
                CGContextMoveToPoint(context, 168 + left, 46);
                CGContextAddLineToPoint(context, 194 + left , 46);
                CGContextMoveToPoint(context, 198 + left, 6);
                CGContextAddLineToPoint(context, 198 + left , 23);
                CGContextMoveToPoint(context, 198 + left, 44);
                CGContextAddLineToPoint(context, 198 + left, 27);
                CGContextMoveToPoint(context, 164 + left, 44);
                CGContextAddLineToPoint(context, 164 + left, 27);
                break;
        }
    }
                
                
                CGContextSetLineWidth(context, 2.0);
                CGContextSetRGBStrokeColor(context, 1, 0, 0, 1);
                CGContextStrokePath(context);
}

- (void)drawWhiteInContext:(CGContextRef) context withRect:(CGRect*) rect
{
    CGContextSetRGBFillColor (context, 1, 1, 1, 1);
    CGContextFillRect(context, CGRectMake (0, 0, 400, 500));
}

- (void)drawWiresInContext:(CGContextRef) context withRect:(CGRect*) rect
{
    if(game){
    float rgb[4] = {0, 0, 0, 100};
    CGColorSpaceRef black = CGColorCreate(CGColorSpaceCreateDeviceRGB(), rgb);
    Wire* temp = [wires objectAtIndex:0];
    if(![temp cut]){
        CGLayerRef layer = CGLayerCreateWithContext(context, CGSizeMake(400, 500), NULL);
        CGContextRef lContext = CGLayerGetContext(layer);
        CGContextSaveGState(lContext);
        CGContextSetShadowWithColor (lContext, CGSizeMake(-5, 5), 2, black);
        CGContextAddPath(lContext, wirePaths[[temp path]]);
        CGContextSetLineWidth(lContext, 4.0);
        CGContextSetRGBStrokeColor(lContext, 1, 0, 0, 1);
        CGContextStrokePath(lContext);
        CGContextDrawLayerAtPoint(context, CGPointZero, layer);
    }
    
    temp = [wires objectAtIndex:1];
    if(![temp cut]){
        CGLayerRef layer = CGLayerCreateWithContext(context, CGSizeMake(400, 500), NULL);
        CGContextRef lContext = CGLayerGetContext(layer);
        CGContextSaveGState(lContext);
        CGContextSetShadowWithColor (lContext, CGSizeMake(-5, 5), 2, black);
        CGContextAddPath(lContext, wirePaths[[temp path]]);
        CGContextSetLineWidth(lContext, 4.0);
        CGContextSetRGBStrokeColor(lContext, 0, 0, 1, 1);
        CGContextStrokePath(lContext);
        CGContextDrawLayerAtPoint(context, CGPointZero, layer);
    }
    
    temp = [wires objectAtIndex:2];
    if(![temp cut]){
        CGLayerRef layer = CGLayerCreateWithContext(context, CGSizeMake(400, 500), NULL);
        CGContextRef lContext = CGLayerGetContext(layer);
        CGContextSaveGState(lContext);
        CGContextSetShadowWithColor (lContext, CGSizeMake(-5, 5), 2, black);
        CGContextAddPath(lContext, wirePaths[[temp path]]);
        CGContextSetLineWidth(lContext, 4.0);
        CGContextSetRGBStrokeColor(lContext, 0, 1, 0, 1);
        CGContextStrokePath(lContext);
        CGContextDrawLayerAtPoint(context, CGPointZero, layer);
    }
    
    temp = [wires objectAtIndex:3];
    if(![temp cut]){
        CGLayerRef layer = CGLayerCreateWithContext(context, CGSizeMake(400, 500), NULL);
        CGContextRef lContext = CGLayerGetContext(layer);
        CGContextSaveGState(lContext);
        CGContextSetShadowWithColor (lContext, CGSizeMake(-5, 5), 2, black);
        CGContextAddPath(lContext, wirePaths[[temp path]]);
        CGContextSetLineWidth(lContext, 4.0);
        CGContextSetRGBStrokeColor(lContext, .5, .5, .5, 1);
        CGContextStrokePath(lContext);
        CGContextDrawLayerAtPoint(context, CGPointZero, layer);
    }
    
    temp = [wires objectAtIndex:4];
    if(![temp cut]){
        CGLayerRef layer = CGLayerCreateWithContext(context, CGSizeMake(400, 500), NULL);
        CGContextRef lContext = CGLayerGetContext(layer);
        CGContextSaveGState(lContext);
        CGContextSetShadowWithColor (lContext, CGSizeMake(-5, 5), 2, black);
        CGContextAddPath(lContext, wirePaths[[temp path]]);
        CGContextSetLineWidth(lContext, 4.0);
        CGContextSetRGBStrokeColor(lContext, .5, 0, .5, 1);
        CGContextStrokePath(lContext);
        CGContextDrawLayerAtPoint(context, CGPointZero, layer);
    }
    
    temp = [wires objectAtIndex:5];
    if(![temp cut]){
        CGLayerRef layer = CGLayerCreateWithContext(context, CGSizeMake(400, 500), NULL);
        CGContextRef lContext = CGLayerGetContext(layer);
        CGContextSaveGState(lContext);
        CGContextSetShadowWithColor (lContext, CGSizeMake(-5, 5), 2, black);
        CGContextAddPath(lContext, wirePaths[[temp path]]);
        CGContextSetLineWidth(lContext, 4.0);
        CGContextSetRGBStrokeColor(lContext, 0, .5, .5, 1);
        CGContextStrokePath(lContext);
        CGContextDrawLayerAtPoint(context, CGPointZero, layer);
    }
    
    [theView setNeedsDisplay:YES];
    }
}

- (void)explode
{
    [bombTimer invalidate];
    [bombTimer release];
    explosion = YES;
    game = NO;
    [theView setNeedsDisplay:YES];
}

- (IBAction)reset:(id)sender
{
    timeLeft = 30;
    wiresLeft = 6;
    if(game == YES){
        [bombTimer invalidate];
        [bombTimer release];
    }
    game = YES;
    explosion = NO;
    bombTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 
                                                  target:self
                                                selector:@selector(decreaseTime)
                                                userInfo:NULL repeats:YES]
                                                    retain];
    
    int activeWire, i;
    [wires release];
    wires = [[NSMutableArray alloc] initWithCapacity:6];
    srandom(time(NULL));
    activeWire = random() % 6;
    int randArray[6] = {0, 0, 0, 0, 0, 0};
    for(i = 0; i < 6; i++){
        Wire* temp = [[Wire alloc] init];
        if(i == activeWire){
            [temp active:YES];
        }
        
        int r = random() % 6;
        while(randArray[r] == 1){
            r = random() % 6;
        }
        randArray[r] = 1;
        [temp path:r];
        [wires addObject:temp];
        [temp release];
    }
    [theView setNeedsDisplay:YES];
}

@end
