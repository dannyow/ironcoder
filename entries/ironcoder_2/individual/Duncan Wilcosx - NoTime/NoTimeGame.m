//
//  NoTimeGame.m
//  NoTime
//
//  Created by Duncan Wilcox on 7/22/06.
//  Copyright 2006 Duncan Wilcox. All rights reserved.
//

#import "NoTimeGame.h"

#define NO_DATA 1
#define HAVE_DATA 2

@interface NoTimeGame (internal)
- (void)play;
- (void)process;
@end

@implementation NoTimeGame

#pragma mark ---- game state

#define G_INIT 0
#define G_MAIN_LOOP 10
#define G_LOST 20
#define G_END 30

- (void)showText:(NSString *)text
{
	[data setValue:text forKey:@"text"];
	[data setValue:[NSNumber numberWithFloat:2] forKey:@"textAlpha"];
	lastAlpha = [NSDate timeIntervalSinceReferenceDate];
}

- (void)process
{
	@synchronized (data)
	{
		switch(gamestate)
		{
			case G_INIT :
				// initialization
				if([NSDate timeIntervalSinceReferenceDate] - start < 4)
					[data setValue:[NSNumber numberWithInt:0] forKey:@"play"];
				else
				{
					bonus1taken = NO;
					bonus2taken = NO;
					bonus3taken = NO;
					bonus4taken = NO;
					[data setValue:[NSNumber numberWithBool:YES] forKey:@"showBonus1"];
					[data setValue:[NSNumber numberWithBool:YES] forKey:@"showBonus2"];
					[data setValue:[NSNumber numberWithBool:YES] forKey:@"showBonus3"];
					[data setValue:[NSNumber numberWithBool:YES] forKey:@"showBonus4"];
					[data setValue:[NSNumber numberWithBool:YES] forKey:@"showIRCMonster"];
					[data setValue:[NSNumber numberWithBool:YES] forKey:@"showNewsMonster"];
					[data setValue:[NSNumber numberWithInt:1] forKey:@"play"];
					[data setValue:[NSValue valueWithPoint:NSMakePoint(30, 40)] forKey:@"characterPosition"];
					[data setValue:[NSValue valueWithPoint:NSMakePoint(0, 0)] forKey:@"farPosition"];
					[data setValue:[NSValue valueWithPoint:NSMakePoint(0, 0)] forKey:@"nearPosition"];
					gamestate = G_MAIN_LOOP;
				}
				break;

			case G_MAIN_LOOP :
			{
				// countdown
				float left = 30 - ([NSDate timeIntervalSinceReferenceDate] - start) + 4 + bonus;
				[data setValue:[NSNumber numberWithFloat:left] forKey:@"countdown"];
				if(left < 0)
				{
					gamestate = G_LOST;
				}
				
				// text fade
				float ta = [[data valueForKey:@"textAlpha"] floatValue];
				if(ta > 0 && [NSDate timeIntervalSinceReferenceDate] - lastAlpha > .1)
				{
					lastAlpha = [NSDate timeIntervalSinceReferenceDate];
					[data setValue:[NSNumber numberWithFloat:ta - .1] forKey:@"textAlpha"];
				}
				
				// character motion
				NSPoint p = [[data valueForKey:@"characterPosition"] pointValue];
				NSPoint f = [[data valueForKey:@"farPosition"] pointValue];
				NSPoint n = [[data valueForKey:@"nearPosition"] pointValue];
				int motion = 0;
				if([[data valueForKey:@"left"] intValue])
				{
					p.x -= .5;
					motion = -1;
				}
				if([[data valueForKey:@"right"] intValue])
				{
					p.x += .5;
					motion = 1;
				}
				if([[data valueForKey:@"jump"] intValue] && motion != 3 && motion != -3)
					motion *= 2;
				if([[data valueForKey:@"fire"] intValue] && motion != 2 && motion != -2)
				{
					motion *= 3;
					if(motion != 0)
					{
						if(p.x > 450 && p.x < 500)
						{
							IRCMonsterKilled = YES;
							[data setValue:[NSNumber numberWithBool:NO] forKey:@"showIRCMonster"];
						}
						if(p.x > 650 && p.x < 700)
						{
							NewsMonsterKilled = YES;
							[data setValue:[NSNumber numberWithBool:NO] forKey:@"showNewsMonster"];
						}
					}
				}
				if(p.x < 30)
					p.x = 30;
				if(p.x + n.x > 50)
					n.x -= (p.x + n.x) - 50;
				if(p.x + n.x < 30)
					n.x += 30 - (p.x + n.x);
				f.x = n.x / 2;
				
				// events
				if((int)p.x != lastEventPos)
				{
					lastEventPos = (int)p.x;
					int effectiveMotion = [[data valueForKey:@"effectiveMotion"] intValue];
					switch(lastEventPos)
					{
						case 30 :
							[self showText:@"Run, coder, run!"];
							break;
							
						case 70 :
							[self showText:@"Press 'f' to fire"];
							break;

						case 120 :
							[self showText:@"Press space to jump"];
							break;
							
						case 160 :
							[self showText:@"Jump to catch the iron!"];
							break;
							
						case 200 :
							if((effectiveMotion == 2 || effectiveMotion == -2) && ! bonus1taken)
							{
								bonus1taken = YES;
								[data setValue:[NSNumber numberWithBool:NO] forKey:@"showBonus1"];
								bonus += 5;
								[self showText:@"5 second bonus!"];
							}
							break;
							
						case 400 :
							if((effectiveMotion == 2 || effectiveMotion == -2) && ! bonus2taken)
							{
								[data setValue:[NSNumber numberWithBool:NO] forKey:@"showBonus2"];
								bonus2taken = YES;
								bonus += 5;
								[self showText:@"5 second bonus!"];
							}
							break;

						case 450 :
							[self showText:@"Watch the time wasting IRC monster!"];
							break;
							
						case 500 :
							if(! IRCMonsterKilled)
							{
								[self showText:@"Ouch!"];
								motion = 0;
								p.x -= 10;
							}
							break;
							
						case 600 :
							if((effectiveMotion == 2 || effectiveMotion == -2) && ! bonus3taken)
							{
								[data setValue:[NSNumber numberWithBool:NO] forKey:@"showBonus3"];
								bonus3taken = YES;
								bonus += 5;
								[self showText:@"5 second bonus!"];
							}
							break;
							
						case 650 :
							[self showText:@"Shoot the time wasting news monster!"];
							break;
							
						case 700 :
							if(! NewsMonsterKilled)
							{
								[self showText:@"Ouch!"];
								motion = 0;
								p.x -= 10;
							}
							break;
							
						case 800 :
							if((effectiveMotion == 2 || effectiveMotion == -2) && ! bonus4taken)
							{
								[data setValue:[NSNumber numberWithBool:NO] forKey:@"showBonus4"];
								bonus4taken = YES;
								bonus += 5;
								[self showText:@"5 second bonus!"];
							}
							break;
							
						case 1000 :
						{
							[self showText:@"W00t!"];
							end = [NSDate timeIntervalSinceReferenceDate];
							motion = 5;
							gamestate = G_END;
							break;
						}
					}
				}
				
				[data setValue:[NSValue valueWithPoint:p] forKey:@"characterPosition"];
				[data setValue:[NSValue valueWithPoint:f] forKey:@"farPosition"];
				[data setValue:[NSValue valueWithPoint:n] forKey:@"nearPosition"];
				[data setValue:[NSNumber numberWithInt:motion] forKey:@"motion"];
				break;
				
				case G_LOST :
				{
					[self showText:@"You have to perfect your ability!"];
					[data setValue:[NSNumber numberWithInt:4] forKey:@"motion"];
					end = [NSDate timeIntervalSinceReferenceDate];
					gamestate = G_END;
					break;
				}
					
				case G_END :
				{
					if([NSDate timeIntervalSinceReferenceDate] - end > 4)
					{
						start = [NSDate timeIntervalSinceReferenceDate];
						gamestate = G_INIT;
					}
					break;
				}
			}
		}
	}
}

#pragma mark ---- thread stuff

- (id)init
{
	playLock = [[NSConditionLock alloc] initWithCondition:NO_DATA];
	termLock = [[NSConditionLock alloc] initWithCondition:NO_DATA];
	data = [[NSMutableDictionary alloc] init];
	[NSThread detachNewThreadSelector:@selector(play) toTarget:self withObject:nil];
	start = [NSDate timeIntervalSinceReferenceDate];
	return self;
}

- (void)dealloc
{
	[data release];
	[playLock release];
	[termLock release];
	[super dealloc];
}

- (void)play
{
	[NSThread setThreadPriority:[NSThread threadPriority] * 0.9];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	done = NO;
	gamestate = G_INIT;
	while(YES)
	{
		if([playLock lockWhenCondition:HAVE_DATA beforeDate:[NSDate dateWithTimeIntervalSinceNow:1./60.]])
			[playLock unlockWithCondition:NO_DATA];
		if(done)
			break;
		[self process];
	}
	[termLock unlockWithCondition:HAVE_DATA];
	[pool release];
}

- (void)stop
{
	done = YES;
	[playLock lock];
	[playLock unlockWithCondition:HAVE_DATA];
	[termLock lockWhenCondition:HAVE_DATA];
}

#pragma mark ---- value i/o

- (id)valueForKey:(NSString *)key
{
	id value;
	@synchronized (data)
	{
		value = [[data valueForKey:key] copy];
	}
	return [value autorelease];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
	@synchronized (data)
	{
		[data setValue:value forKey:key];
	}
}

@end
