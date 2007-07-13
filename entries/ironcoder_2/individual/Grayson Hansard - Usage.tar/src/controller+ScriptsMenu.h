//
//  controller+scriptsMenu.h
//  Usage
//
//  Created by Grayson Hansard on 7/22/06.
//  Copyright 2006 From Concentrate Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <LuaObjCBridge/LuaObjCBridge.h>
#import "controller.h"

@interface controller (ScriptsMenu)

-(NSString *)pathToScriptsFolder;
-(void)buildScriptMenu;

@end
