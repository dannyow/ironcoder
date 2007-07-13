/*
 *  Utilities.c
 *  FallingSand
 *
 *  Created by Jonathan Wight on 7/22/06.
 *  Copyright 2006 __MyCompanyName__. All rights reserved.
 *
 */

#include "Utilities.h"

#include <stdlib.h>

void range(int *outArray, size_t n)
{
size_t i;
for (i = 0; i != n; ++i)
	outArray[i] = i;
}

// Fisher Yates shuffle algorithm: http://www.nist.gov/dads/HTML/fisherYatesShuffle.html
void shuffle(int *array, size_t n)
{
if (n > 1)
	{
	size_t i;
	for (i = 0; i < n - 1; i++)
		{
		size_t j = randint(i, n - 1);
		int t = array[j];
		array[j] = array[i];
		array[i] = t;
		}
    }
}