//
//  HotKey.m
//  GameTest
//
//  Created by Karsten Kusche on 08.11.05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "HotKey.h"

@interface HotKey (initing)
- (id)initWithEvent:(EventRecord)theEvent;
- (id)initWithArray:(NSArray*)array;
@end


@implementation HotKey

+ (id)hotKeyFromArray:(NSArray*)array
{
	return [[self alloc] initWithArray:array];
}

+ (id)fromEvent:(EventRecord)theEvent
{
	return [[self alloc] initWithEvent:theEvent];
}

- (void)dealloc
{
	[self unRegister];
	
	[super dealloc];
}

NSString* print(unsigned char c, int kCode)
{
	if (c > 32 && c < 127)
	{
		return [NSString stringWithFormat:@"%c",(char)toupper(c)];
	}
	switch (kCode)
		// find listing at: http://developer.apple.com/documentation/mac/Text/Text-571.html#MARKER-9-12
	{
		case 0x7a:
			return [NSString stringWithString:@"F1"];
		case 0x78:
			return [NSString stringWithString:@"F2"];
		case 0x63:
			return [NSString stringWithString:@"F3"];
		case 0x76:
			return [NSString stringWithString:@"F4"];
		case 0x60:
			return [NSString stringWithString:@"F5"];
		case 0x61:
			return [NSString stringWithString:@"F6"];
		case 0x62:
			return [NSString stringWithString:@"F7"];
		case 0x64:
			return [NSString stringWithString:@"F8"];
		case 0x65:
			return [NSString stringWithString:@"F9"];
		case 0x6d:
			return [NSString stringWithString:@"F10"];
		case 0x67:
			return [NSString stringWithString:@"F11"];
		case 0x6f:
			return [NSString stringWithString:@"F12"];
		case 0x69:
			return [NSString stringWithString:@"F13"];
		case 0x6b:
			return [NSString stringWithString:@"F14"];
		case 0x71:
			return [NSString stringWithString:@"F15"];
		case 0x72:
			return [NSString stringWithString:@"Help"];
		case 0x73:
			return [NSString stringWithString:@"Home"];
		case 0x74:
			return [NSString stringWithString:@"PgUp"];
		case 0x75:
			return [NSString stringWithUTF8String:"⌦"];//forward delete
		case 0x33:
			return [NSString stringWithUTF8String:"⌫"];//backspace
		case 0x77:
			return [NSString stringWithString:@"End"];
		case 0x79:
			return [NSString stringWithString:@"PgDn"];
		case 0x31:
			return [NSString stringWithString:@"Space"];
		case 0x7e:
			return [NSString stringWithUTF8String:"↑"];//cursor up
		case 0x7d:
			return [NSString stringWithUTF8String:"↓"];//cursor down
		case 0x7b:
			return [NSString stringWithUTF8String:"←"];//cursor left
		case 0x7c:
			return [NSString stringWithUTF8String:"→"];//cursor right
		case 0x35:
			return [NSString stringWithString:@"Esc"];
		case 0x30: 
			return [NSString stringWithUTF8String:"⇥"];//tab
		case 0x39:
			return [NSString stringWithUTF8String:"⇪"];//capslock
		case 0x0a:
			return [NSString stringWithUTF8String:"^"];
	}
	return [NSString stringWithString:@"Unknown Key"];
}

- (NSString*)description
{
//	NSLog([NSString stringWithFormat:@"%s%s%s%s%@ (0x%x)",(modifiers & cmdKey ? "Cmd+":""),(modifiers & optionKey ? "Opt+":""),(modifiers & controlKey ? "Ctrl+":""),(modifiers & shiftKey ? "Shift+":""),print(charCode,keyCode),keyCode]);
	return [NSString stringWithFormat:@"%@%@%@%@%@",
		[NSString stringWithUTF8String:(modifiers & cmdKey ? "⌘+":"")], 
		[NSString stringWithUTF8String:(modifiers & optionKey ? "⌥+":"")], 
		[NSString stringWithUTF8String:(modifiers & controlKey ? "⌃+":"")], 
		[NSString stringWithUTF8String:(modifiers & shiftKey ? "⇧+":"")], 
		print(charCode,keyCode), 
		keyCode];
}

- (EventHotKeyRef)setWithID:(unsigned int)anID
{
//	EventHotKeyID hotKeyID;
	
	OSErr err;

	hotKeyID.signature = 'CCLP';
	hotKeyID.id = anID;
	//register F11 for fast paste
//	RegisterEventHotKey(
//						UInt32            inHotKeyCode,
//						UInt32            inHotKeyModifiers,
//						EventHotKeyID     inHotKeyID,
//						EventTargetRef    inTarget,
//						OptionBits        inOptions,
//						EventHotKeyRef *  outRef)        
	err=RegisterEventHotKey(keyCode, modifiers ,hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef); 
	if (err)
	{
		if (eventHotKeyExistsErr == err) 
		{
			NSRunAlertPanel(@"Error",[NSString stringWithFormat:@"this hotkey is allready in use:%@",[self description]],@"Ok",nil,nil);
		}
		//fprintf(stderr,"[-] can't register Key: %i id = %i : %@",err,anID,[self description]);
	}
	else
	{
		//NSLog(@"registered: %@ with id: %i ref: %x",[self description],anID,hotKeyRef);
	}
	return hotKeyRef;
}

- (void)unRegister
{
	//NSLog(@"%x",hotKeyRef);
	OSStatus err = UnregisterEventHotKey (hotKeyRef);
	if (err) 
	{
	//	NSLog(@"can't unregister Key: %i id = %i",err,hotKeyID.id);	
	}
	else
	{
	//	NSLog(@"unregistered: %@",[self description]);;
	}
}

- (NSArray*) asArray
{
	NSMutableArray* array = [NSMutableArray array];
	[array addObject: [NSNumber numberWithUnsignedShort:modifiers]];
	[array addObject: [NSNumber numberWithUnsignedChar:keyCode]];
	[array addObject: [NSNumber numberWithUnsignedChar:charCode]];
	return [NSArray arrayWithArray:array];
}
@end

@implementation HotKey (initing)

- (id)initWithEvent:(EventRecord)theEvent
{
	if (self = [super init])
	{
		hotKeyRef = 0;
		modifiers = theEvent.modifiers & (cmdKey | optionKey | controlKey | shiftKey);
		unsigned long  null = 0;
		keyCode = (theEvent.message & keyCodeMask)>>8;
		charCode = (KeyTranslate((int*)GetScriptManagerVariable(smKCHRCache),keyCode,&null));	
		//NSLog(@"0x%0.2x,0x%0.2x,%c, %c",keyCode,charCode,keyCode,charCode);
		//	NSLog(@"%0.8x",charCode);
	}
	return self;
}

- (id)initWithArray:(NSArray*)array
{
	if (self = [super init])
	{
		if (array == nil)
		{
			[self release];
			return nil;
		}
		hotKeyRef = 0;
		modifiers = [[array objectAtIndex:0] unsignedShortValue];
		keyCode = [[array objectAtIndex:1] unsignedCharValue];
		charCode = [[array objectAtIndex:2] unsignedCharValue];
	}
	return self;
}

@end


						
