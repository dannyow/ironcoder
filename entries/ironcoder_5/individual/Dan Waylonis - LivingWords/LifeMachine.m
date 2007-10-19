//==============================================================================
// File:      LifeMachine.m
// Date:      3/31/07
// Author:		Dan Waylonis
// Copyright:	(C) 2007 nekotech SOFTWARE
//==============================================================================
#import "LifeMachine.h"

typedef UInt16 CellCoord;
typedef UInt32 PackedCell;

// Since inserting 0, 0 would result in a NULL, offset by 1
#define PackCell(x,y) ((PackedCell)(((x + 1) << 16) | (y + 1)))
#define UnpackX(cell) ((CellCoord)((cell >> 16) & 0xFFFF) - 1)
#define UnpackY(cell) ((CellCoord)(cell & 0xFFFF) - 1)

@interface LifeMachine(PrivateMethods)
- (void)applyBirths;
- (void)applyDeaths;
@end

typedef struct MachineParams {
  unsigned char *bitmapData;
  unsigned int rowBytes;
  unsigned int width;
  unsigned int height;
  unsigned char *active;
}
MachineParams;

@implementation LifeMachine
//==============================================================================
#pragma mark -
#pragma mark || Private ||
//==============================================================================
static BOOL IsCellAlive(MachineParams *params, int x, int y) {
  // Wrap around
  if (x < 0)
    x += params->width;
  else if (x >= params->width)
    x -= params->width;
  
  if (y < 0)
    y += params->height;
  else if (y >= params->height)
    y -= params->height;
  
  return (params->bitmapData[x + y * params->rowBytes] > 0) ? YES : NO;
}

//==============================================================================
static void AddCell(PackedCell cell, NSHashTable *table) {
  NSHashInsert(table, (void *)cell);
}

//==============================================================================
static void RemoveCell(PackedCell cell, NSHashTable *table) {
  NSHashRemove(table, (void *)cell);
}

//==============================================================================
static void SetBitmapValue(MachineParams *params, int x, int y, unsigned char value) {
  params->bitmapData[x + y * params->rowBytes] = value;
}

//==============================================================================
static unsigned int CountNeighbors(MachineParams *params, int x, int y) {
  unsigned int count = 0;
  
  // Count the nearest 8 neighbors, wrapping at borders
  // Top Row
  count += IsCellAlive(params, x - 1, y - 1) ? 1 : 0;
  count += IsCellAlive(params, x, y - 1) ? 1 : 0;
  count += IsCellAlive(params, x + 1, y - 1) ? 1 : 0;
  
  // Left & Right 
  count += IsCellAlive(params, x - 1, y) ? 1 : 0;
  count += IsCellAlive(params, x + 1, y) ? 1 : 0;
  
  // Bottom Row
  count += IsCellAlive(params, x - 1, y + 1) ? 1 : 0;
  count += IsCellAlive(params, x, y + 1) ? 1 : 0;
  count += IsCellAlive(params, x + 1, y + 1) ? 1 : 0;
  
  return count;
}

//==============================================================================
- (void)updateParams:(MachineParams *)params {
  params->bitmapData = bitmapData_;
  params->rowBytes = rowBytes_;
  params->width = width_;
  params->height = height_;
  params->active = active_;
}

//==============================================================================
- (void)applyBirths {
  if (!NSCountHashTable(births_))
    return;

  NSHashEnumerator e = NSEnumerateHashTable(births_);
  PackedCell cell;
  MachineParams params;
  
  [self updateParams:&params];
  
  while ((cell = (PackedCell)NSNextHashEnumeratorItem(&e))) {
    SetBitmapValue(&params, UnpackX(cell), UnpackY(cell), lifeValue_);
    ++birthCount_;
    ++aliveCount_;
  }
      
  NSEndHashTableEnumeration(&e);
  NSResetHashTable(births_);
}

//==============================================================================
- (void)applyDeaths {
  if (!NSCountHashTable(deaths_))
    return;
  
  NSHashEnumerator e = NSEnumerateHashTable(deaths_);
  PackedCell cell;
  MachineParams params;
  
  [self updateParams:&params];
  
  while ((cell = (PackedCell)NSNextHashEnumeratorItem(&e))) {
    SetBitmapValue(&params, UnpackX(cell), UnpackY(cell), emptyValue_);
    ++deathCount_;
    --aliveCount_;
  }
  
  NSEndHashTableEnumeration(&e);
  NSResetHashTable(deaths_);
}

//==============================================================================
#pragma mark -
#pragma mark || Public ||
//==============================================================================
- (id)initWithBitmap:(NSBitmapImageRep *)bitmap {
  if ((self = [super init])) {
    bitmap_ = [bitmap retain];
    bitmapData_ = [bitmap bitmapData];
    width_ = [bitmap_ pixelsWide];
    height_ = [bitmap_ pixelsHigh];
    rowBytes_ = [bitmap_ bytesPerRow];
    active_ = (unsigned char *)malloc(width_ * height_);

    births_ = NSCreateHashTable(NSIntHashCallBacks, 0);
    deaths_ = NSCreateHashTable(NSIntHashCallBacks, 0);
    
    [self setLifeValue:0xFF];
    [self setEmptyValue:0];
    
    [self updateLifeFromBitmap];
  }
  
  return self;
}

//==============================================================================
- (void)setLifeValue:(unsigned char)life {
  lifeValue_ = life;
}

//==============================================================================
- (unsigned char)lifeValue {
  return lifeValue_;
}

//==============================================================================
- (void)setEmptyValue:(unsigned char)empty {
  emptyValue_ = empty;
}

//==============================================================================
- (unsigned char)emptyValue {
  return emptyValue_;
}

//==============================================================================
static BOOL IsActive(MachineParams *params, int x, int y) {
  return params->active[x + y * params->width] > 0 ? YES : NO;
}

//==============================================================================
static void SetActive(MachineParams *params, int x, int y, BOOL active) {
  if (x < 0)
    x += params->width;
  else if (x >= params->width)
    x -= params->width;
  
  if (y < 0)
    y += params->height;
  else if (y >= params->height)
    y -= params->height;

  params->active[x + y * params->width] = (active ? 1 : 0);
}

//==============================================================================
static void SetActiveRegion(MachineParams *params, int x, int y) {
  
  // Set the surrounding block
  SetActive(params, x - 1, y - 1, YES);
  SetActive(params, x, y - 1, YES);
  SetActive(params, x + 1, y - 1, YES);

  SetActive(params, x - 1, y, YES);
  SetActive(params, x, y, YES);
  SetActive(params, x + 1, y, YES);

  SetActive(params, x - 1, y + 1, YES);
  SetActive(params, x, y + 1, YES);
  SetActive(params, x + 1, y + 1, YES);
}

//==============================================================================
- (void)step {
  unsigned int x, y;
  unsigned int neighbors;
  MachineParams params;
  
  [self updateParams:&params];  
  aliveCount_ = birthCount_ = deathCount_ = 0;

  for (y = 0; y < height_; ++y) {
    for (x = 0; x < width_; ++x) {
      // Skip uninteresting areas
      if (!IsActive(&params, x, y))
        continue;
      
      neighbors = CountNeighbors(&params, x, y);
      
      // Any live cell with fewer than two live neighbours dies, as if by loneliness.
      // Any live cell with more than three live neighbours dies, as if by overcrowding.
      // Any live cell with two or three live neighbours lives, unchanged, to the next generation.
      // Any dead cell with exactly three live neighbours comes to life.
      if (IsCellAlive(&params, x, y)) {
        ++aliveCount_;
        SetActiveRegion(&params, x, y);
        if ((neighbors < 2) || (neighbors > 3))
          AddCell(PackCell(x, y), deaths_);

      } else if (neighbors == 3) {
        AddCell(PackCell(x, y), births_);
        SetActiveRegion(&params, x, y);
      } else {
        SetActive(&params, x, y, NO);
      }
    }
  }
  
  // Apply the births and deaths
  [self applyBirths];
  [self applyDeaths];
}

//==============================================================================
- (void)updateLifeFromBitmap {
  unsigned int x, y;
  MachineParams params;
  
  [self updateParams:&params];  
  memset(active_, 0, width_ * height_);
  
  for (y = 0; y < height_; ++y) {
    for (x = 0; x < width_; ++x) {
      if (bitmapData_[x + y * rowBytes_] != emptyValue_) {
        SetActiveRegion(&params, x, y);
      }
    }
  }
}

//==============================================================================
- (unsigned int)alive {
  return aliveCount_;
}

//==============================================================================
- (unsigned int)births {
  return birthCount_;
}

//==============================================================================
- (unsigned int)deaths {
  return deathCount_;
}

//==============================================================================
#pragma mark -
#pragma mark || NSObject ||
//==============================================================================
- (void)dealloc {
  [bitmap_ release];
  free(active_);
  NSFreeHashTable(births_);
  NSFreeHashTable(deaths_);
	[super dealloc];
}

@end
