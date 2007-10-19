//==============================================================================
// File:      LivingWord.m
// Date:      4/1/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#import <OpenGL/glext.h>

#import "GLUtilities.h"
#import "LifeMachine.h"
#import "LivingWord.h"
#import "LivingWordsEngine.h"
#import "LivingWordsView.h"
#import "RectUtilities.h"
#import "Utilities.h"

static GLenum glReportErrorFN(const char *fnName, const char *msg) {
	GLenum err = glGetError();
	if (GL_NO_ERROR != err)
		NSLog(@"%s (%s): %s", fnName, msg, (char *)gluErrorString(err));
	
	return(err);
}

#define glReportError(a) glReportErrorFN(__PRETTY_FUNCTION__, a)

@interface LivingWord(PrivateMethods)
- (void)buildBitmap;
- (void)bindTextures;
- (void)releaseTextures;
@end

@implementation LivingWord
//==============================================================================
#pragma mark -
#pragma mark || Private ||
//==============================================================================
- (void)buildBitmapWithPath:(NSBezierPath *)path {
  NSRect bounds = [path bounds];
  float padding = 10;
  bounds = NSInsetRect(bounds, -padding, -padding);
  
  width_ = ceil(NSWidth(bounds));
  height_ = ceil(NSHeight(bounds));
  
  [bitmap_ release];
  bitmap_ = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil pixelsWide:width_ pixelsHigh:height_ bitsPerSample:8 samplesPerPixel:1 hasAlpha:NO isPlanar:NO colorSpaceName:NSCalibratedWhiteColorSpace bytesPerRow:0 bitsPerPixel:8];
  
  memset([bitmap_ bitmapData], 0x00, height_ * [bitmap_ bytesPerRow]);
  
  NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap_];
  NSGraphicsContext *previous = [NSGraphicsContext currentContext];
  [NSGraphicsContext setCurrentContext:bitmapContext];
  [[NSColor whiteColor] set];

  NSAffineTransform *xform = [NSAffineTransform transform];
  
  [xform translateXBy:padding yBy:padding];
  [path transformUsingAffineTransform:xform];
  [path setLineWidth:2];
  [path stroke];
  [NSGraphicsContext setCurrentContext:previous];

  frame_.size = NSMakeSize(width_, height_);

  [machine_ release];
  machine_ = [[LifeMachine alloc] initWithBitmap:bitmap_];
  
}

//==============================================================================
- (void)bindTexture {
  unsigned char *bitmapData = [bitmap_ bitmapData];

  glEnable(GL_TEXTURE_RECTANGLE_EXT);
  glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap_ bytesPerRow]);
  glGenTextures(1, &textureID_);
  glBindTexture(GL_TEXTURE_RECTANGLE_EXT, textureID_);
  glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_LUMINANCE, width_,
               height_, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE,
               bitmapData);
  
  // Make a copy  
  shadowBitmap_ = (unsigned short *)calloc(width_ * height_, 3);
  unsigned short *shadowPtr = shadowBitmap_;
  
  for (int j = 0; j < height_; ++j) {
    for (int i = 0; i < width_; ++i) {
      if (*bitmapData) {
        unsigned short val = *bitmapData;
        *shadowPtr = 0x00FF | val << 8;
      }
      
      ++shadowPtr;
      ++bitmapData;
    } 
  }
  
  glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
  glGenTextures(1, &pathTextureID_);
  glBindTexture(GL_TEXTURE_RECTANGLE_EXT, pathTextureID_);
  glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, GL_LUMINANCE_ALPHA, width_,
               height_, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE,
               shadowBitmap_);
  
  textureContext_ = CGLGetCurrentContext();
  glReportError("bind");
}

//==============================================================================
- (void)releaseTexture {
  if (textureID_ && textureContext_) {
    (*textureContext_->disp.delete_textures)(textureContext_->rend, 1, &textureID_);
//    (*textureContext_->disp.delete_textures)(textureContext_->rend, 1, &pathTextureID_);
    textureID_ = 0;
    pathTextureID_ = 0;
    textureContext_ = nil;
  }
}

//==============================================================================
- (void)drawMainTexture {
  NSRect bounds = frame_;
  unsigned char *bitmapData = [bitmap_ bitmapData];
  
  if (!textureID_)
    [self bindTexture];
  
  // Draw Life
  glBindTexture(GL_TEXTURE_RECTANGLE_EXT, textureID_);
  glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap_ bytesPerRow]);
  glTexSubImage2D(GL_TEXTURE_RECTANGLE_EXT, 0, 0, 0, width_, height_, GL_LUMINANCE,
                  GL_UNSIGNED_BYTE, bitmapData);

  // Ensure uncolored texture
  float c[4];
  [color_ getRed:&c[0] green:&c[1] blue:&c[2] alpha:&c[3]];
  c[3] = alpha_;
  glColor4fv(c);
  
  glBegin(GL_QUADS);
  
	// Image and quads are flipped in relation to each other
	glTexCoord2f(0, height_);
	glVertex2f(NSMinX(bounds), NSMinY(bounds));
  
	glTexCoord2f(width_, height_);
	glVertex2f(NSMaxX(bounds), NSMinY(bounds));
  
	glTexCoord2f(width_, 0);
	glVertex2f(NSMaxX(bounds), NSMaxY(bounds));
  
	glTexCoord2f(0, 0);
	glVertex2f(NSMinX(bounds), NSMaxY(bounds));
  
	glEnd();  
}

//==============================================================================
- (void)drawOriginalTexture {
  NSRect bounds = frame_;

  if (!textureID_)
    [self bindTexture];

  // Draw Life
  glBindTexture(GL_TEXTURE_RECTANGLE_EXT, pathTextureID_);
  glPixelStorei(GL_UNPACK_ROW_LENGTH, [bitmap_ bytesPerRow]);
  
  float gray = 0.4;
  glColor4f(gray, gray, gray, gray);
  
  glBegin(GL_QUADS);
  
	// Image and quads are flipped in relation to each other
	glTexCoord2f(0, height_);
	glVertex2f(NSMinX(bounds), NSMinY(bounds));
  
	glTexCoord2f(width_, height_);
	glVertex2f(NSMaxX(bounds), NSMinY(bounds));
  
	glTexCoord2f(width_, 0);
	glVertex2f(NSMaxX(bounds), NSMaxY(bounds));
  
	glTexCoord2f(0, 0);
	glVertex2f(NSMinX(bounds), NSMaxY(bounds));
  
	glEnd();  
}

//==============================================================================
#pragma mark -
#pragma mark || Public ||
//==============================================================================
- (id)initWithEngine:(LivingWordsEngine *)engine {
  if (self = [super init]) {
    engine_ = engine;
    view_ = [engine view];
    alpha_ = 1.0;
  }
  
  return self;
}

//==============================================================================
- (void)setPath:(NSBezierPath *)path {
  [bitmap_ release];
  [self buildBitmapWithPath:path];
}

//==============================================================================
- (void)setAlpha:(float)alpha {
  alpha_ = alpha;
}

//==============================================================================
- (float)alpha {
  return alpha_;
}

//==============================================================================
- (void)setFrame:(NSRect)frame {
  frame_ = frame;
}

//==============================================================================
- (void)setFrameOrigin:(NSPoint)origin {
  frame_.origin = origin;
}

//==============================================================================
- (NSRect)frame {
  return frame_;
}

//==============================================================================
- (void)setPositionDelta:(NSPoint)delta {
  positionDelta_ = delta;
}

//==============================================================================
- (NSPoint)positionDelta {
  return positionDelta_;
}

//==============================================================================
- (void)setColor:(NSColor *)color {
  NSColor *rgb = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
  
  [color_ release];
  color_ = [rgb retain];
}

//==============================================================================
- (NSColor *)color {
  return color_;
}

//==============================================================================
- (void)step {
  [machine_ step];
  frame_.origin.x += positionDelta_.x;
  frame_.origin.y += positionDelta_.y;
  
  ++stepCount_;
}

//==============================================================================
- (unsigned int)stepCount {
  return stepCount_;
}

//==============================================================================
- (void)draw {
  glEnable(GL_TEXTURE_RECTANGLE_EXT);
  [self drawMainTexture];
  [self drawOriginalTexture];
  glDisable(GL_TEXTURE_RECTANGLE_EXT);

  DrawGLRect(frame_, color_);
}

//==============================================================================
#pragma mark -
#pragma mark || NSObject ||
//==============================================================================
- (void)dealloc {
  [self releaseTexture];
  [bitmap_ release];
  free(shadowBitmap_);
  [machine_ release];
  [color_ release];
	[super dealloc];
}

@end
