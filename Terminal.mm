//
//  Terminal.mm
//  Terminal
//
//  Created by Allan Odgaard on 2005-10-29.
//  Copyright 2005 MacroMates. All rights reserved.
//

#import "TextMate.h"
#import "JRSwizzle.h"
#import "Terminal.h"
#import "TerminalWindowController.h"
#import "NSWindowController+Terminal.h"

@implementation Terminal

@synthesize lastWindowController, lastTerminalWindowController;

static Terminal *sharedInstance = nil;

+ (Terminal*)instance
{
	@synchronized(self) {
		if (sharedInstance == nil) {
			[[self alloc] init];
		}
	}
	return sharedInstance;
}


- (id)initWithPlugInController:(id <TMPlugInController>)aController
{
	NSApp = [NSApplication sharedApplication];
	
	if(self = [super init]){
		[self installMenuItem];
		
		iVars = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
		
		[OakWindow jr_swizzleMethod:@selector(becomeMainWindow) withMethod:@selector(T_becomeMainWindow) error:NULL];
		[OakProjectController jr_swizzleMethod:@selector(windowDidLoad) withMethod:@selector(T_windowDidLoad) error:NULL];		
		[OakDocumentController jr_swizzleMethod:@selector(windowDidLoad) withMethod:@selector(T_windowDidLoad) error:NULL];		
	}
	sharedInstance = self;
	return self;
}

- (NSMutableDictionary*)getIVarsFor:(id)sender
{
	if (iVars == nil)
		return nil;
	id x = [iVars objectForKey:[NSNumber numberWithInt:[sender hash]]];
	if (x == nil) {
		NSMutableDictionary* iVarHolder = [NSMutableDictionary dictionaryWithCapacity:2];
		[iVars setObject:iVarHolder forKey:[NSNumber numberWithInt:[sender hash]]];
		return iVarHolder;
	}
	return (NSMutableDictionary*)x;
}


- (void)dealloc
{
	[self uninstallMenuItem];
	[super dealloc];
}

- (void)installMenuItem
{
	NSLog(@"istalling");
	if(windowMenu = [[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] retain])
	{
		NSArray* items = [windowMenu itemArray];
		NSLog(@"test");
		int index = 0;
		for (NSMenuItem* item in items)
		{
			if ([[item title] isEqualToString:@"Show/Hide Project Drawer"])
			{
				NSLog(@"%@",[item title]);
				index = [items indexOfObject:item]+1;
			}
		}
		
		// create the items
		showTerminalMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show/Hide Terminal" 
														  action:@selector(toggleTerminal:) keyEquivalent:@""];
		[showTerminalMenuItem setKeyEquivalent:@"$"];
		[showTerminalMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];
		[showTerminalMenuItem setTarget:self];
		
		toggleTerminalfocus = [[NSMenuItem alloc] initWithTitle:@"Toggle Terminal Foucs" 
														 action:@selector(toggleTerminalFocus:) keyEquivalent:@""];
		[toggleTerminalfocus setKeyEquivalent:@"$"];
		[toggleTerminalfocus setKeyEquivalentModifierMask:NSCommandKeyMask];
		[toggleTerminalfocus setTarget:self];
		
		terminalItem = [[NSMenuItem alloc] initWithTitle:@"Terminal" action:NULL keyEquivalent:@""];
		[terminalItem setHidden:YES];
		
		// creat the menu
		terminalMenu = [[NSMenu alloc] initWithTitle:@"Terminal"];
		[terminalMenu insertItem:showTerminalMenuItem atIndex:0];
		[terminalMenu insertItem:toggleTerminalfocus atIndex:0];
		
		// add the menu
		[windowMenu insertItem:terminalItem atIndex:index];
		[windowMenu setSubmenu:terminalMenu forItem:terminalItem];
	}
}

- (void)toggleTerminal:(id)sender
{
	[lastWindowController toggleTerminal];
}

- (void)toggleTerminalFocus:(id)sender
{
	[lastWindowController toggleTerminalFocus];
}

- (void)uninstallMenuItem
{
	[windowMenu removeItem:showTerminalMenuItem];
	[showTerminalMenuItem release];
	showTerminalMenuItem = nil;
	[windowMenu release];
	windowMenu = nil;
}

@end
