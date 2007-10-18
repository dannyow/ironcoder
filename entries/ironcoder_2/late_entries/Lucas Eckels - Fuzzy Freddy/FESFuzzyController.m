//
//  FESFuzzyController.m
//  Fuzzy Freddy
//
//  Created by Lucas Eckels on 7/23/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "FESFuzzyController.h"
#import "FESHair.h"
#import "FESQuartzView.h"
#import "FESFuzzyConstants.h"

#include <time.h>

@implementation FESFuzzyController

/**
 * Get the default RGB colorspace.
 */
CGColorSpaceRef getTheRGBColorSpace()
{
   static CGColorSpaceRef deviceRGB = NULL;
   if (deviceRGB == NULL)
   {
      deviceRGB = CGColorSpaceCreateDeviceRGB();
   }
   
   return deviceRGB;
}


-(void)awakeFromNib
{
   
   srand(time(NULL));
   razorCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"razor"] hotSpot:RAZOR_CURSOR_HOTSPOT];
   poisonCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"poison"] hotSpot:TONIC_CURSOR_HOTSPOT];
   tonicCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"tonic"] hotSpot:TONIC_CURSOR_HOTSPOT];
   
   colors[0] = CGColorCreate(getTheRGBColorSpace(), COLOR1);
   colors[1] = CGColorCreate(getTheRGBColorSpace(), COLOR2);
   colors[2] = CGColorCreate(getTheRGBColorSpace(), COLOR3);
   colors[3] = CGColorCreate(getTheRGBColorSpace(), COLOR4);
   colors[4] = CGColorCreate(getTheRGBColorSpace(), COLOR5);
   colors[5] = CGColorCreate(getTheRGBColorSpace(), COLOR6);
   colors[6] = CGColorCreate(getTheRGBColorSpace(), COLOR7);
   colors[7] = CGColorCreate(getTheRGBColorSpace(), COLOR8);

   currentTool = FESRazorTool;
   [self makeHair];
   
   spraySound = [NSSound soundNamed:@"spray"];
   
}

-(void)dealloc;
{
   CGColorRelease(colors[0]);
   CGColorRelease(colors[1]);
   CGColorRelease(colors[2]);
   CGColorRelease(colors[3]);
   CGColorRelease(colors[4]);
   CGColorRelease(colors[5]);
   CGColorRelease(colors[6]);
   CGColorRelease(colors[7]);
   
   [poisonCursor release];
   [razorCursor release];
   [tonicCursor release];
   
   [spraySound release];
   
   [super dealloc];
}

- (IBAction)setRazor:(id)sender
{
   currentTool = FESRazorTool;
   [[fuzzyView window] invalidateCursorRectsForView:fuzzyView];
}

- (IBAction)setTonic:(id)sender
{
   currentTool = FESTonicTool;
   [[fuzzyView window] invalidateCursorRectsForView:fuzzyView];
}

- (IBAction)setPoison:(id)sender;
{
   currentTool = FESPoisonTool;
   [[fuzzyView window] invalidateCursorRectsForView:fuzzyView];
}

- (IBAction)playPause:(id)sender;
{
   if (timer == nil)
   {
      timer = [[NSTimer scheduledTimerWithTimeInterval:AGE_INTERVAL target:self selector:@selector(age:) userInfo:nil repeats:YES] retain];
   }
   else
   {
      [timer invalidate];
      [timer release];
      timer = nil;
   }
}

- (IBAction)saveAsPdf:(id)sender;
{
   BOOL paused = (timer == nil);
   
   if (paused)
   {
      [self playPause:nil];
   }

   NSSavePanel *panel = [NSSavePanel savePanel];
   [panel setRequiredFileType:@"pdf"];
   [panel setCanSelectHiddenExtension:YES];
   if ([panel runModal] == NSOKButton)
   {
      NSString *filename = [panel filename];
      
      CGRect mediaBox = CGRectMake(0, 0, CANVAS_SIZE, CANVAS_SIZE);
      
      NSURL *url = [NSURL fileURLWithPath:filename];
      CGContextRef pdfContext = CGPDFContextCreateWithURL((CFURLRef)url, &mediaBox,NULL);
      if (!pdfContext)
      {
         NSBeginAlertSheet(@"Could not save PDF",@"Okay",nil,nil,[fuzzyView window],nil,nil,nil,nil,@"Could not save the PDF.  You may not have permission to write to the directory chosen.");
      }
      else
      {
         CGContextBeginPage(pdfContext, &mediaBox);
         [fuzzyView drawInContext:pdfContext];
         CGContextEndPage(pdfContext);
         CGContextRelease(pdfContext);
      }
      
   }
   
   
   if (paused)
   {
      [self playPause:nil];
   }
}

- (IBAction)openReadme:(id)sender;
{
   NSString *path = [[NSBundle mainBundle] pathForResource:@"Readme" ofType:@"rtf"];
   [[NSWorkspace sharedWorkspace] openFile:path];
}

- (IBAction)reset:(id)sender;
{
   [self makeHair];
   
}

-(void)mouseDown:(NSEvent*)event;
{
   NSPoint loc = [event locationInWindow];
   loc = [fuzzyView convertPoint:loc fromView:nil];
   loc = [self transformPoint:loc];
   
   if (currentTool == FESTonicTool)
   {
      [spraySound play];
      NSEnumerator *enumer = [hairs objectEnumerator];
      FESHair *hair;
      while (hair = [enumer nextObject])
      {
         [hair applyTonicToRegion:loc radius:TONIC_RADIUS strength:TONIC_STRENGTH];
      }
   }      
   else if (currentTool == FESPoisonTool)
   {
      [spraySound play];
      NSEnumerator *enumer = [hairs objectEnumerator];
      FESHair *hair;
      while (hair = [enumer nextObject])
      {
         [hair applyTonicToRegion:loc radius:TONIC_RADIUS strength:-TONIC_STRENGTH];
      }
   }      
   
   lastPoint = loc;
   
}

-(void)mouseDragged:(NSEvent*)event;
{
   NSPoint loc = [event locationInWindow];
   loc = [fuzzyView convertPoint:loc fromView:nil];
   loc = [self transformPoint:loc];
   if (currentTool == FESRazorTool)
   {
      NSRect rect = NSMakeRect(loc.x - RAZOR_WIDTH/2, MIN(lastPoint.y, loc.y), RAZOR_WIDTH, abs(lastPoint.y - loc.y));
      NSEnumerator *enumer = [hairs objectEnumerator];
      FESHair *hair;
      while (hair = [enumer nextObject])
      {
         [hair shave:rect];
      }
      [self dataChanged];
   }
   lastPoint = loc;
}

-(void)mouseUp:(NSEvent*)event;
{
   NSPoint loc = [event locationInWindow];
   loc = [fuzzyView convertPoint:loc fromView:nil];
   loc = [self transformPoint:loc];

   lastPoint = loc;
}

-(void)makeHair;
{
   [hairs release];
   
   hairs = [[NSMutableArray alloc] initWithCapacity:HAIR_COUNT];
   
   // chin
   for (unsigned int i = 0; i < CHIN_HAIR_COUNT; ++i)
   {
      NSPoint origin;
      NSPoint dst;
      double dist;
      
      BOOL matches = NO;
      while (!matches)
      {
         // to generate hairs within the chin, geneate hairs within the chin's bounding box,
         // and throw them out if they are not within the appropriate concentric circles.
         origin.x = rand() % (2 * OUTER_RADIUS) - OUTER_RADIUS;
         origin.y = rand() % OUTER_RADIUS - OUTER_RADIUS;
         
         dist = hypot(origin.x, origin.y);
         if (dist < OUTER_RADIUS && dist > INNER_RADIUS)
         {
            matches = YES;
         }
         
      }
      
      dst.x = origin.x / dist;
      dst.y = origin.y / dist;
      
      origin.x += CHIN_CENTER_X;
      origin.y += CHIN_CENTER_Y;
      
      FESHair *hair = [[FESHair alloc] initWithOrigin:origin destination:dst growth:CHIN_RATE lifetime:CHIN_LIFETIME color:colors[rand()%8]];
      
      [hairs addObject:hair];
      [hair release];
      
      
   }

   // sideburns
   for (unsigned int i = 0; i < SIDEBURN_HAIR_COUNT; ++i)
   {
      NSPoint origin;
      NSPoint dst;
      
      origin.x = rand() % (OUTER_RADIUS - INNER_RADIUS);
      origin.y = rand() % SIDEBURN_LENGTH;
               
      if (rand() % 2)
      {
         origin.x += CHIN_CENTER_X + INNER_RADIUS;
         dst.x = 1;
      }
      else
      {
         origin.x += CHIN_CENTER_X - OUTER_RADIUS;
         dst.x = -1;
      }
      
      origin.y += CHIN_CENTER_Y;
      dst.y = 0;
            
      FESHair *hair = [[FESHair alloc] initWithOrigin:origin destination:dst growth:SIDEBURN_RATE lifetime:SIDEBURN_LIFETIME color:colors[rand()%8]];
      
      [hairs addObject:hair];
      [hair release];
      
      
   }

   // moustache
   for (unsigned int i = 0; i < MOUSTACHE_HAIR_COUNT; ++i)
   {
      NSPoint origin;
      NSPoint dst;
      
      origin.x = rand() % (2*INNER_RADIUS) - INNER_RADIUS;
      origin.y = rand() % MOUSTACHE_LENGTH;
      
      if (origin.x > 0)
      {
         dst.x = 1;
      }
      else
      {
         dst.x = -1;
      }
      
      origin.x += CHIN_CENTER_X;
      origin.y += CHIN_CENTER_Y + MOUSTACHE_OFFSET;
      dst.y = 0;
      
      FESHair *hair = [[FESHair alloc] initWithOrigin:origin destination:dst growth:SIDEBURN_RATE lifetime:SIDEBURN_LIFETIME color:colors[rand()%8]];
      
      [hairs addObject:hair];
      [hair release];
      
      
   }
   
   // forehead
   for (unsigned int i = 0; i < FOREHEAD_HAIR_COUNT; ++i)
   {
      NSPoint origin;
      NSPoint dst;
      double dist;
      
      BOOL matches = NO;
      while (!matches)
      {
         // same technique as chin, above
         origin.x = rand() % (2 * OUTER_RADIUS) - OUTER_RADIUS;
         origin.y = rand() % OUTER_RADIUS;
         
         dist = hypot(origin.x, origin.y);
         if (dist < OUTER_RADIUS && dist > INNER_RADIUS)
         {
            matches = YES;
         }
         if (origin.x == 0)
         {
            matches = NO;
         }
         
      }
      
      dst.x = origin.x / dist;
      dst.y = origin.y / dist;
      
      origin.x += CHIN_CENTER_X;
      origin.y += CHIN_CENTER_Y + SIDEBURN_LENGTH;
      
      FESHair *hair = [[FESHair alloc] initWithOrigin:origin destination:dst growth:FOREHEAD_RATE lifetime:FOREHEAD_LIFETIME color:colors[rand()%8]];
      
      [hairs addObject:hair];
      [hair release];
      
   }

   [fuzzyView setHairs:hairs];
   
}

-(id)age:(NSNotification*)notification
{
   NSEnumerator *enumer = [hairs objectEnumerator];
   FESHair *hair;
   while (hair = [enumer nextObject])
   {
      [hair age:1];
   }
   [fuzzyView setNeedsDisplay:YES];
   
   return nil;
}

-(void)dataChanged;
{
   // only setNeedsDisplay if not currently playing, since it will get set at the next age interval anyways.
   if (![self isPlaying])
   {
      [fuzzyView setNeedsDisplay:YES];
   }
}

-(NSCursor*)toolCursor;
{
   switch (currentTool)
   {
      case FESRazorTool:
         return razorCursor;
         break;
      case FESPoisonTool:
         return poisonCursor;
         break;
      case FESTonicTool:
         return tonicCursor;
         break;
   };
   
   return nil;
}

-(NSPoint)transformPoint:(NSPoint)point;
{
   float scale;
   NSSize offset = [fuzzyView offsetAndScale:&scale];

   NSPoint retval;
   retval.x = (point.x / scale - offset.width);
   retval.y = (point.y / scale - offset.height);
   
   return retval;
}

-(BOOL)isPlaying;
{
   return (timer != nil);
}

@end
