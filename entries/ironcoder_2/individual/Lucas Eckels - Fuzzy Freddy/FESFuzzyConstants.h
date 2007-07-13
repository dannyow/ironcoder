/*
 *  FESFuzzyConstants.h
 *  Fuzzy Freddy
 *
 *  Created by Lucas Eckels on 7/23/06.
 *  Copyright 2006 Flesh Eating Software. All rights reserved.
 *
 */

// The point where a hair goes from a point of stubble to a bspline 
#define STUBBLE_LIMIT 6 
// The percent (0-100) that a hair dies on any given age increment
#define DEATH_PROBABILITY 1
// Set to 1 to allow hair to fall out
#define USE_DEATH 0 

// The interval between hair aging
#define AGE_INTERVAL 0.1

// Number of hairs to generate for various parts of the face
#define CHIN_HAIR_COUNT 200
#define FOREHEAD_HAIR_COUNT 200
#define SIDEBURN_HAIR_COUNT 100
#define MOUSTACHE_HAIR_COUNT 75
#define HAIR_COUNT (CHIN_HAIR_COUNT + FOREHEAD_HAIR_COUNT + SIDEBURN_HAIR_COUNT + MOUSTACHE_HAIR_COUNT)

// Starting growth rate for various parts of the face
#define CHIN_RATE 1
#define SIDEBURN_RATE 1
#define FOREHEAD_RATE 1
#define MOUSTACHE_RATE 1

// Modifies the chances of a hair dying for various parts of the body
#define STANDARD_LIFETIME 1
#define CHIN_LIFETIME STANDARD_LIFETIME
#define SIDEBURN_LIFETIME STANDARD_LIFETIME
#define FOREHEAD_LIFETIME STANDARD_LIFETIME
#define MOUSTACHE_LIFETIME STANDARD_LIFETIME

// Radius of effect of the tonic/poison
#define TONIC_RADIUS 30
// Growth rate delta per tonic/poison application
#define TONIC_STRENGTH 0.25
// Width of the razor
#define RAZOR_WIDTH 44

// Geometry definition of the face
#define CHIN_CENTER_X 344
#define CHIN_CENTER_Y 294
#define OUTER_RADIUS 144
#define INNER_RADIUS 100
#define SIDEBURN_LENGTH 163
#define MOUSTACHE_LENGTH 30
#define MOUSTACHE_OFFSET -10

#define CANVAS_SIZE 720

// Hotspot definitions for custom cursors
#define RAZOR_CURSOR_HOTSPOT NSMakePoint(25, 7)
#define TONIC_CURSOR_HOTSPOT NSMakePoint(50, 25)

// Shades of brown
#define COLOR1 (float[4]){ 0.368, 0.266, 0.090, 1.000 }
#define COLOR2 (float[4]){ 0.439, 0.322, 0.196, 1.000 }
#define COLOR3 (float[4]){ 0.318, 0.243, 0.122, 1.000 }
#define COLOR4 (float[4]){ 0.357, 0.235, 0.055, 1.000 }
#define COLOR5 (float[4]){ 0.627, 0.435, 0.157, 1.000 }
#define COLOR6 (float[4]){ 0.259, 0.169, 0.024, 1.000 }
#define COLOR7 (float[4]){ 0.667, 0.514, 0.325, 1.000 }
#define COLOR8 (float[4]){ 0.298, 0.180, 0.051, 1.000 }

