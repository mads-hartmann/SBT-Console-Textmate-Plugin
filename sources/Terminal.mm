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

@synthesize lastWindowController, lastTerminalWindowController, iconImage, preferencesView;

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
		
		[OakWindow jr_swizzleMethod:@selector(setRepresentedFilename:) withMethod:@selector(T_setRepresentedFilename:) error:NULL];
		[OakWindow jr_swizzleMethod:@selector(becomeMainWindow) withMethod:@selector(T_becomeMainWindow) error:NULL];
		[OakProjectController jr_swizzleMethod:@selector(windowDidLoad) withMethod:@selector(T_windowDidLoad) error:NULL];		
		[OakDocumentController jr_swizzleMethod:@selector(windowDidLoad) withMethod:@selector(T_windowDidLoad) error:NULL];		
	}
	sharedInstance = self;
	
	//image
	NSString* iconPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"textmate-minimap" ofType:@"tiff"];
    iconImage = [[NSImage alloc] initByReferencingFile:iconPath];
	
	//preference
	NSString* nibPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Preferences" ofType:@"nib"];
    prefWindowController = [[NSWindowController alloc] initWithWindowNibPath:nibPath owner:self];
    [prefWindowController showWindow:self];
	
	[OakPreferencesManager jr_swizzleMethod:@selector(windowWillClose:) withMethod:@selector(Console_PrefWindowWillClose:) error:NULL];
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbarAllowedItemIdentifiers:) 
                                 withMethod:@selector(Console_toolbarAllowedItemIdentifiers:) error:NULL];
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbarDefaultItemIdentifiers:) 
                                 withMethod:@selector(Console_toolbarDefaultItemIdentifiers:) error:NULL];
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbarSelectableItemIdentifiers:) 
                                 withMethod:@selector(Console_toolbarSelectableItemIdentifiers:) error:NULL];
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) 
                                 withMethod:@selector(Console_toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) error:NULL];
    [OakPreferencesManager jr_swizzleMethod:@selector(selectToolbarItem:) withMethod:@selector(Console_selectToolbarItem:) error:NULL];
	
	
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
	[lastWindowController release];
	[iVars release];
	[sharedInstance release];
	sharedInstance = nil;
	[super dealloc];
}

- (void)installMenuItem
{
	if(windowMenu = [[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] retain])
	{
		NSArray* items = [windowMenu itemArray];
		int index = 0;
		for (NSMenuItem* item in items)
		{
			if ([[item title] isEqualToString:@"Show/Hide Project Drawer"])
			{
				index = [items indexOfObject:item]+1;
			}
		}
		
		// create the items
		showTerminalMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show/Hide Terminal" 
														  action:@selector(toggleTerminal:) keyEquivalent:@""];
		[showTerminalMenuItem setKeyEquivalent:@"1"];
		[showTerminalMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask|NSControlKeyMask];
		[showTerminalMenuItem setTarget:self];
		
		toggleTerminalfocus = [[NSMenuItem alloc] initWithTitle:@"Toggle Terminal Foucs" 
														 action:@selector(toggleTerminalFocus:) keyEquivalent:@""];
		[toggleTerminalfocus setKeyEquivalent:@"1"];
		[toggleTerminalfocus setKeyEquivalentModifierMask:NSShiftKeyMask|NSCommandKeyMask];
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
	[toggleTerminalfocus release];
	toggleTerminalfocus = nil;
	[terminalItem release];
	terminalItem = nil;
	[windowMenu release];
	windowMenu = nil;
}

@end
