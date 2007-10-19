/*
 *  CrepuscularLife_UserPrefs.h
 *  Crepuscular Life
 *
 *  Created by Josh Freeman on 3/31/07.
 *  Copyright 2007 Twilight Edge Software. All rights reserved.
 *
 */
 
 typedef enum
{
	gliderFrequencyTypeGenerationsPerGlider = 0,
	gliderFrequencyTypeGlidersPerGeneration

} GliderFrequencyType;


#define kCREPLIFEPrefsKeyGenSpeed			@"GenSpeed"
#define kCREPLIFEPrefsKeyGliderFreqType		@"GliderFType"
#define kCREPLIFEPrefsKeyGlidersPerGen		@"GlidersPerGen"
#define kCREPLIFEPrefsKeyGensPerGlider		@"GensPerGlider"


#define PREFS_DOMAIN					@"com.twilightedge.creplife"
#define DEFAULT_GEN_SPEED				30
#define DEFAULT_GLIDERS_PER_GEN			2
#define DEFAULT_GENS_PER_GLIDER			2
#define DEFAULT_GLIDER_FREQ_TYPE		gliderFrequencyTypeGlidersPerGeneration

