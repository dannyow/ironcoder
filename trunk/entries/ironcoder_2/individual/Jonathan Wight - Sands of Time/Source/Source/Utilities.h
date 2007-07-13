/*
 *  Utilities.h
 *  FallingSand
 *
 *  Created by Jonathan Wight on 7/22/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include <stdlib.h>

static inline long randint(long lower, long upper);
static inline signed int randomdirection(void);
static inline float randomfloat(void);

void range(int *outArray, size_t n);
void shuffle(int *array, size_t n);

static inline long randint(long lower, long upper)
{
return(random() % (upper - lower + 1) + lower);
}

static inline signed int randomdirection(void)
{
return(random() & 1 ? +1 : -1);
}

static inline float randomfloat(void)
{
return((double)random() / (double)0x7FFFFFFF);
}