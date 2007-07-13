//
//  CFallingSandWindowController.h
//  FallingSand
//
//  Created by Jonathan Wight on 7/22/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CFallingSandView;
@class CSandboxRenderer;
@class QTMovie;
@class CSandbox;

@interface CFallingSandWindowController : NSWindowController {
	IBOutlet CFallingSandView *outletSandboxView;
	CSandbox *sandbox;
	CSandboxRenderer *renderer;
	
	BOOL writeMovie;
	QTMovie *movie;
}

+ (CFallingSandWindowController *)instance;

- (CSandbox *)sandbox;
- (CSandboxRenderer *)renderer;

- (NSArray *)particleTemplates;
- (int)currentParticle;
- (void)setCurrentParticle:(int)inCurrentParticle;

- (float)penRadius;
- (void)setPenRadius:(float)inPenRadius;

- (QTMovie *)movie;

- (IBAction)actionSaveScreen:(id)inSender;
- (IBAction)actionLoadScreen:(id)inSender;

@end
