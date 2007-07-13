#import "BWCGView.h"

enum {
    kDragPoints,
    kSizeStart,	// shift
    kSizeEnd	// option
};

@interface BWCGShaderView : BWCGView
{
    NSPoint start;
    NSPoint end;

    float startRadius;
    float endRadius;
    int trackMode;

    BOOL extendStart, extendEnd;
    BOOL axialShading;

    IBOutlet NSTextField *blurbField;
}


- (IBAction) extendStart: (id) sender;
- (IBAction) extendEnd: (id) sender;
- (IBAction) changeShading: (id) sender;

@end // BWCGShaderView

