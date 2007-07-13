#import "RedWireView.h"


@implementation RedWireView

- (BOOL)acceptsFirstResponder
{
    [[self window] makeFirstResponder:self];
    return YES;
}

- (void)drawRect:(NSRect)rect {
    NSGraphicsContext *nsgc = [NSGraphicsContext currentContext];
    CGContextRef gc = [nsgc graphicsPort];
    
    [[NSColor blackColor] set];
    NSRectFill(NSMakeRect(0, 0, rect.size.width, rect.size.height));
    
    [rwc drawInContext:gc withRect:(CGRect*)&rect];
}

- (void)keyDown:(NSEvent*)theEvent
{
    int key = (int)[[theEvent characters] characterAtIndex:0];
    if(key > (int)'0' && key < (int) '7'){
        key = key - ((int) '0');
        [rwc cut:key];
    }
}

@end
