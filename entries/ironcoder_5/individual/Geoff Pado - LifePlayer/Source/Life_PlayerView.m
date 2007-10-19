//
//Life_PlayerView.m
//Life Player
//
//Created by Geoff Pado on 3/30/07.
//Copyright (c) 2007, A Clockwork Apple. All rights reserved.
//

#import "Life_PlayerView.h"


@implementation Life_PlayerView

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
	self = [super initWithFrame:frame isPreview:isPreview];
	if (self) 
	{
		NSOpenGLPixelFormatAttribute attributes[] = 
		{ 
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADepthSize, 16,
			NSOpenGLPFAMinimumPolicy,
			NSOpenGLPFAClosestPolicy,
			0, NSOpenGLPFAColorSize, 32, NSOpenGLPFANoRecovery
		};
		
		NSOpenGLPixelFormat *format = [[[NSOpenGLPixelFormat alloc] initWithAttributes:attributes] autorelease];
		
		glView = [[ICOpenGLView alloc] initWithFrame:NSZeroRect pixelFormat:format];
		[self addSubview:glView];
		[self setUpOpenGL];
		
		NSString *photoPath = [[NSString stringWithString:@"~/Pictures/iPhoto Library/Data/"] stringByExpandingTildeInPath];
		NSDirectoryEnumerator *photoEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:photoPath];
		NSString *enumeratedPath;
		filePaths = [NSMutableArray array];
		i = 0;
		animFrame = 0;
		while (enumeratedPath = [photoEnumerator nextObject])
		{
			NSString *fullPath = [photoPath stringByAppendingPathComponent:enumeratedPath];
			NSDictionary *attrs = [[NSFileManager defaultManager] fileAttributesAtPath:fullPath traverseLink:NO];
			NSString *fileType = [attrs objectForKey:@"NSFileType"];
			if (![fileType isEqualToString:@"NSFileTypeDirectory"])
			{
				NSString *fileName = [fullPath lastPathComponent];
				if (![fileName isEqualToString:@".DS_Store"])
				{
					[filePaths addObject:[fullPath copy]];
				}
			}
		}
		
		[filePaths retain];
		//NSLog([filePaths objectAtIndex:1]);
		//NSLog([filePaths description]);
		srandom(time(NULL));
		i = random() % ([filePaths count] - 1);
		[self loadBitmap:[filePaths objectAtIndex:i] intoIndex:0];
		[self setAnimationTimeInterval:1/30.0];
 }
	return self;
}

- (void)startAnimation
{
	[super startAnimation];
}

- (void)stopAnimation
{
	[super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	[[glView openGLContext] makeCurrentContext];

	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT ); 
	glLoadIdentity(); 
	
	
	// Create the texture

   // Typical texture generation using data from the bitmap

	glTranslatef(xValue , translation, -6.0f );
	glRotatef( rotation, 0.0f, 1.0f, 0.0f );
	
   glBindTexture( GL_TEXTURE_RECTANGLE_ARB, texture[ 0 ] );
	
	glBegin(GL_QUADS);
	{
		glTexCoord2f(0.0f, texSize[ 0 ].height);						glVertex3f(-1.0f, +1.0f, 0.0f);
		glTexCoord2f(texSize[ 0 ].width, texSize[ 0 ].height);	glVertex3f(+1.0f, +1.0f, 0.0f);
		glTexCoord2f(texSize[ 0 ].width, 0.0f);						glVertex3f(+1.0f, -1.0f, 0.0f);
		glTexCoord2f(0.0f, 0.0f);											glVertex3f(-1.0f, -1.0f, 0.0f);
	}
		
	glEnd();

	glFlush(); 
}

- (void)animateOneFrame
{
	if (animFrame == -1)
	{
		//[self loadBitmap:[filePaths objectAtIndex:4] intoIndex:0];
	}
	
	if (animFrame == 0)
	{
		translation = -4.0f;
		rotation = 0.0f;
		srandom(time(NULL));
		xValue = (random() % 3) - 3;
	}
	
	else if (animFrame > 0)
	{
		translation +=0.01f;
		rotation += 0.2f;
		[self setNeedsDisplay:YES];
	}
	
	if (animFrame == 800)
	{	
		srandom(time(NULL));
		animFrame = -2;
		i = random() % ([filePaths count] - 1);
		[self loadBitmap:[filePaths objectAtIndex:i] intoIndex:0];
		[self setNeedsDisplay:NO];
	}
	
	animFrame++;
	
	
	return;
}



- (BOOL) loadBitmap:(NSString *)filename intoIndex:(int)texIndex
{
	NSLog(filename);
   BOOL success = FALSE;
   NSBitmapImageRep *theImage;
   int bitsPPixel, bytesPRow;
   unsigned char *theImageData;
   int rowNum, destRowNum;
   
   theImage = [ NSBitmapImageRep imageRepWithContentsOfFile:filename ];
   if( theImage != nil )
   {
      bitsPPixel = [ theImage bitsPerPixel ];
      bytesPRow = [ theImage bytesPerRow ];
	  glPixelStorei(GL_UNPACK_ROW_LENGTH, bytesPRow / (bitsPPixel >> 3));
      if( bitsPPixel == 24 )        // No alpha channel
         texFormat[ texIndex ] = GL_RGB;
      else if( bitsPPixel == 32 )   // There is an alpha channel
         texFormat[ texIndex ] = GL_RGBA;
      texSize[ texIndex ].width = [ theImage pixelsWide ];
      texSize[ texIndex ].height = [ theImage pixelsHigh ];
      texBytes[ texIndex ] = calloc( bytesPRow * texSize[ texIndex ].height,
                                     1 );
      if( texBytes[ texIndex ] != NULL )
      {
         success = TRUE;
         theImageData = [ theImage bitmapData ];
         destRowNum = 0;
         for( rowNum = texSize[ texIndex ].height - 1; rowNum >= 0;
              rowNum--, destRowNum++ )
         {
            // Copy the entire row in one shot
            memcpy( texBytes[ texIndex ] + ( destRowNum * bytesPRow ),
                    theImageData + ( rowNum * bytesPRow ),
                    bytesPRow );
         }
      }
   }

	glGenTextures(1, &texture[ 0 ] );
	glBindTexture( GL_TEXTURE_RECTANGLE_EXT, texture[ 0 ] );
	GLenum internalFormat = [theImage hasAlpha] ? GL_RGBA : GL_RGB;
	GLenum format = [theImage hasAlpha] ? GL_BGRA : GL_BGR;

	glTexImage2D( GL_TEXTURE_RECTANGLE_EXT, 0, internalFormat, texSize[ 0 ].width,
   		texSize[ 0 ].height, 0, internalFormat,
			GL_UNSIGNED_BYTE, texBytes[ 0 ] );

   return success;
}

- (BOOL)hasConfigureSheet
{
	return NO;
}

- (NSWindow*)configureSheet
{
	return nil;
}

- (void)setUpOpenGL
{
	[[glView openGLContext] makeCurrentContext];
	glShadeModel(GL_SMOOTH);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearDepth(1.0f);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_RECTANGLE_ARB);
	glDepthFunc(GL_LEQUAL);
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	
	rotation = 0.0f;
	translation = 0.0f;
}

- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];
	[glView setFrameSize:newSize];
	
	[[glView openGLContext] makeCurrentContext];
	
	glViewport(0, 0, (GLsizei)newSize.width, (GLsizei)newSize.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f, (GLfloat)newSize.width / (GLfloat)newSize.height, 0.1f, 100.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	[[glView openGLContext] update];
}

@end
