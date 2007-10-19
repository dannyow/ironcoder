//==============================================================================
// File:      LifeMachine.h
// Date:      3/31/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
// 
// Life simulator on a 8-bit bitmap
//==============================================================================
#import <Cocoa/Cocoa.h>

@interface LifeMachine : NSObject {
  NSBitmapImageRep *bitmap_;  // The bitmap to modify
  unsigned char *bitmapData_; // The bitmap data
  unsigned int width_;        // The width in cells
  unsigned int height_;       // The height in cells
  unsigned int rowBytes_;     // Bytes per row

  unsigned char *active_;     // Bitmap of active regions
  NSHashTable *births_;       // Table of PackCells representing birth
  NSHashTable *deaths_;       // Table of PackCells representing death
  unsigned int aliveCount_;   // # of cells alive
  unsigned int birthCount_;   // # of cells created in last step
  unsigned int deathCount_;   // # of cells died in last step
  
  unsigned char lifeValue_;   // Value used to represent new life
  unsigned char emptyValue_;  // Value used when emptying a cell
}

//==============================================================================
// Public
//==============================================================================
// 8 bit per pixel bitmap.  Values will be set using life and empty values
- (id)initWithBitmap:(NSBitmapImageRep *)bitmap;

- (void)setLifeValue:(unsigned char)life;
- (unsigned char)lifeValue;   // Default 0xFF

- (void)setEmptyValue:(unsigned char)empty;
- (unsigned char)emptyValue;  // Default 0x00

// Update the bitmap
- (void)step;

// Force an update from the bitmap
- (void)updateLifeFromBitmap;

- (unsigned int)alive;
- (unsigned int)births;
- (unsigned int)deaths;

//==============================================================================
// NSObject
//==============================================================================
- (void)dealloc;

@end
