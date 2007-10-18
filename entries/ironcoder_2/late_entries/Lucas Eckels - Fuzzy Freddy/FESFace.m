//
//  FESFace.m
//  Fuzzy Freddy
//
//  Created by Lucas Eckels on 7/22/06.
//  Copyright 2006 Flesh Eating Software. All rights reserved.
//

#import "FESFace.h"


@implementation FESFace

-(id)init
{
   if (self = [super init])
   {
      // load the PDF for the face
      NSString *path = [[NSBundle mainBundle] pathForResource:@"FuzzyFred" ofType:@"pdf"];
      NSURL *url = [NSURL fileURLWithPath:path];
      pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
   }
   
   return self;
}

-(void)dealloc;
{
   CGPDFDocumentRelease(pdf);
   [super dealloc];
}

-(void)draw:(CGContextRef)context;
{
   CGRect rect = CGPDFDocumentGetMediaBox(pdf,1);
   CGContextDrawPDFDocument(context,rect,pdf,1);
}

@end
