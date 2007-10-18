#import "FESQuartzView.h"
#import "FESHair.h"
#import "FESFuzzyController.h"
#import "FESFuzzyConstants.h"

#include <math.h>

@implementation FESQuartzView

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
      
      face = [[FESFace alloc] init];
      
	}
	return self;
}

-(void)dealloc;
{
   [face release];
   [hairs release];
   
   [super dealloc];
}

- (void)drawRect:(NSRect)rect
{
   NSGraphicsContext *nsctx = [NSGraphicsContext currentContext];
   CGContextRef context = [nsctx graphicsPort];   
   
   float scale;
   NSSize offset = [self offsetAndScale:&scale];
   
   CGContextSaveGState(context);
   CGContextScaleCTM(context,scale,scale);
   CGContextTranslateCTM(context, offset.width, offset.height);
   
   [self drawInContext:context];
   
   CGContextRestoreGState(context);
}


-(void)drawInContext:(CGContextRef)context;
{
   [face draw:context];
   NSEnumerator *enumer = [hairs objectEnumerator];
   FESHair *hair;
   while (hair = [enumer nextObject])
   {
      [hair draw:context];
   }
}


-(void)mouseDown:(NSEvent*)event;
{
   // pass it off to the controller
   [controller mouseDown:event];

}

-(void)mouseUp:(NSEvent*)event;
{
   // pass it off to the controller
   [controller mouseUp:event];
}

-(void)mouseDragged:(NSEvent*)event;
{
   // pass it off to the controller
   [controller mouseDragged:event];
}

-(void)setHairs:(NSArray*)aHairs
{
   [hairs release];
   hairs = [aHairs retain];
   [self setNeedsDisplay:YES];
}

-(void)resetCursorRects;
{
   // Set the cursor based on the current tool.
   [self addCursorRect:[self bounds] cursor:[controller toolCursor]];
}

-(NSSize)offsetAndScale:(float*)aScale;
{
   NSSize fullView = [self bounds].size;
   
   float minDim = MIN(fullView.height, fullView.width);
   float scale = minDim / CANVAS_SIZE;

   NSSize offset;
   
   offset.width = (fullView.width / scale - CANVAS_SIZE) / 2;
   offset.height = (fullView.height / scale - CANVAS_SIZE) / 2;
   
   if (aScale != NULL)
   {
      *aScale = scale;
   }
   return offset;
}

@end
