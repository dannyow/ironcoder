//
//  controller+scriptsMenu.m
//  Usage
//
//  Created by Grayson Hansard on 7/22/06.
//  Copyright 2006 From Concentrate Software. All rights reserved.
//

#import "controller+ScriptsMenu.h"


@implementation controller (ScriptsMenu)

-(NSString *)pathToScriptsFolder
{   // Stolen from Wil Shipley.
	return [[[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"Scripts"];
}

-(void)buildScriptMenu
{
	NSMenuItem *scriptMenuItem = [[[NSMenuItem alloc] initWithTitle:@"Scripts" action:nil keyEquivalent:@""] autorelease];
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"script menus"] autorelease];
	[scriptMenuItem setSubmenu:menu];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *scriptsFolderPath = [self pathToScriptsFolder];
	
	if (![fm fileExistsAtPath:[scriptsFolderPath stringByDeletingLastPathComponent]])
		[fm createDirectoryAtPath:[scriptsFolderPath stringByDeletingLastPathComponent] attributes:nil];
	if (![fm fileExistsAtPath:scriptsFolderPath])
		[fm copyPath:[[NSBundle mainBundle] pathForResource:@"Scripts" ofType:nil] toPath:scriptsFolderPath handler:nil];
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	NSMenuItem *mi = [menu addItemWithTitle:NSLocalizedString(@"Open scripts folder\\U2026", @"") 
									 action:@selector(openScriptsFolder:) keyEquivalent:@""];
	[mi setTarget:self];
	[mi setRepresentedObject:scriptsFolderPath];
	[menu addItem:[NSMenuItem separatorItem]];
	
	NSDirectoryEnumerator *e = [fm enumeratorAtPath:scriptsFolderPath];
	NSString *filename = nil;
	while (filename = [e nextObject]) 
	{
		if ([filename hasSuffix:@".scpt"] || [filename hasSuffix:@"lua"])
		{
			mi = [menu addItemWithTitle:[filename stringByDeletingPathExtension] action:@selector(runScript:) 
						  keyEquivalent:@""];
			[mi setTarget:self];
			NSString *path = [scriptsFolderPath stringByAppendingPathComponent:filename];
			[mi setRepresentedObject:path];
			NSImage *img = [ws iconForFile:path];
			[img setScalesWhenResized:YES];
			[img setSize:NSMakeSize(16.0, 16.0)];
			[mi setImage:img];
		}
	}
	
	[scriptMenuItem setImage:[[[NSImage alloc] initByReferencingFile:
		@"/System/Library/CoreServices/Menu Extras/Script Menu.menu/Contents/Resources/blackmask2.tiff"] autorelease]];
	
	[[NSApp mainMenu] insertItem:scriptMenuItem atIndex:4];
}

-(void)openScriptsFolder:(id)sender { [[NSWorkspace sharedWorkspace] openFile:[sender representedObject]]; }
-(void)runScript:(id)sender 
{
	NSString *path = [sender representedObject];

	//shift reveals in Finder, option opens in Script Editor
	if ((GetCurrentKeyModifiers() & shiftKey) != 0)
		[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];
	else if ((GetCurrentKeyModifiers() & optionKey) != 0)
		[[NSWorkspace sharedWorkspace] openFile:path];
	else
	{
		if ([path hasSuffix:@".scpt"])
		{
			NSAppleScript *as = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
			[as executeAndReturnError:nil];
			[as release];
		}
		else if ([path hasSuffix:@".lua"])
		{
			lua_State *L = lua_objc_init();
			lua_objc_pushid(L, [self processes]);
			lua_setglobal(L, "processes");
			if (luaL_loadfile(L, [path fileSystemRepresentation]) || lua_pcall(L, 0, 0, 0))
				NSLog(@"Lua error: %s", lua_tostring(L, -1));
		}
	}
}

@end
