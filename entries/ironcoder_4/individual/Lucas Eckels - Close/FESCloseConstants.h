/*
 *  FESCloseConstants.h
 *  Close
 *
 *  Created by Lucas Eckels on 10/28/06.
 *  Copyright 2006 Flesh Eating Software. All rights reserved.
 *
 */

#define CHARACTER_HEIGHT 64
#define CHARACTER_WIDTH 64

#define FIELD_WIDTH 10
#define FIELD_HEIGHT 10

#define TEXT_BLURRING_DURATION 1.5
#define TEXT_SIZE 50
#define LINE_WIDTH 10

#define STINK_CLOUD_DURATION 1.5

#define TRANSITION_DURATION 1.5

#define RectForSpace(x, y) \
   CGRectMake((x)*CHARACTER_WIDTH, (y)*CHARACTER_HEIGHT,CHARACTER_WIDTH,CHARACTER_HEIGHT)
