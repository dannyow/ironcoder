/* FESQuartzView */

#import <Cocoa/Cocoa.h>

@class FESFace;
@class FESFuzzyController;

@interface FESQuartzView : NSView
{
   FESFace *face;
   NSArray *hairs;
   IBOutlet FESFuzzyController *controller;
}

-(void)setHairs:(NSArray*)aHairs;

-(void)drawInContext:(CGContextRef)context;

/**
 * Determine the offset and scale from the standard canvas.
 *
 * This corresponds to the offset and scale for the CG CTM relative to the view's coordinates, scaled first.
 *
 * @param aScale
 *        Output parameter.  If not NULL, this will be set to the scale of the CTM.
 *
 * @return The offset of the CTM.
 */
-(NSSize)offsetAndScale:(float*)aScale;

@end
