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

@synthesize lastWindowController;

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
		
//		TerminalWindowController* obj = [TerminalWindowController alloc]; 
//		NSString* nibPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Terminal" ofType:@"nib"];
//		terminalWindowController = [obj initWithWindowNibPath:nibPath owner:obj];
		
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
		showTerminalMenuItem = [[NSMenuItem alloc] initWithTitle:@"Show/Hide Terminal" 
														 action:@selector(showTerminal:) keyEquivalent:@""];
		[showTerminalMenuItem setKeyEquivalent:@"$"];
		[showTerminalMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
		[showTerminalMenuItem setTarget:self];
		[showTerminalMenuItem setEnabled:true];
		[windowMenu insertItem:showTerminalMenuItem atIndex:index];
		
	}
}

- (void)showTerminal:(id)sender
{
	[lastWindowController toggleTerminal];
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
