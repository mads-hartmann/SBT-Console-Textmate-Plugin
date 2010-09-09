//
//  NSWindowController+Terminal.m
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/22/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import "NSWindowController+Terminal.h"
#import "TerminalWindowController.h"
#import "Terminal.h"
#import "TextMate.h"
#import "MAHJSplitView.h"

// stuff that the textmate-windowcontrollers (OakProjectController, OakDocumentControler) implement
@interface NSWindowController (TextMate_WindowControllers_Only)

- (id)textView;
- (void)goToLineNumber:(id)newLine;
- (unsigned int)getLineHeight;
- (NSString*)filename; // that is only implemented by OakProjectController
- (NSString*)projectDirectory; // that is only implemented by OakProjectController
- (NSDictionary *)environmentVariables;// that is only implemented by OakProjectController

@end


@interface NSWindowController (Private) 

- (NSString*)SBTPath;

@end

@implementation NSWindowController (NSWindowControllerTerminal)

- (MAHJSplitView*)getSplitView
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	return (MAHJSplitView*)[ivars objectForKey:@"splitView"];
}

- (TerminalWindowController *)terminalController
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	return (TerminalWindowController*)[ivars objectForKey:@"terminalController"];
}

- (void)toggleTerminalFocus
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	MAHJSplitView *splitView = [ivars objectForKey:@"splitView"];
	if ( splitView == nil) { // closed
		[self toggleTerminal];
	}
	Terminal *instance = [Terminal instance];
	if ([[[[instance lastWindowController] window] firstResponder] isKindOfClass:OakTextView]){
		[[[instance lastWindowController] window] makeFirstResponder:[[instance lastTerminalWindowController] input]];
	} else {
		[[[instance lastWindowController] window] makeFirstResponder:[self textView]];
	}
}

- (void)toggleTerminal
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	MAHJSplitView *splitView = [ivars objectForKey:@"splitView"];
	// Creat the drawer if it doesn't exist.
	if (splitView == nil){
		// Create the content for the drawer. (hacky, but it needs an owner)
		NSString* nibPath = [[NSBundle bundleForClass:[[Terminal instance] class]] pathForResource:@"Terminal" ofType:@"nib"];
		TerminalWindowController* obj = [TerminalWindowController alloc]; 
		TerminalWindowController* controller = [obj initWithWindowNibPath:nibPath owner:obj];
		
		// setting the project path
		[controller setProjectDir:[self projectDirectory]];
		[controller setPathToSbt:[self SBTPath]];
		[ivars setObject:controller forKey:@"terminalController"];
		[[Terminal instance] setLastTerminalWindowController:controller];
		NSView *terminalView = [[controller window] contentView];
		[terminalView retain];
		NSView* documentView = [[[self window] contentView] retain];
		
		if (NSClassFromString(@"CWTMSplitView") != nil
			&& [[NSUserDefaults standardUserDefaults] boolForKey:@"ProjectPlus Sidebar Enabled"]
			&& [self isKindOfClass:OakProjectController]) {
			splitView = [self addConsoleProjectPlus:documentView terminalView:terminalView];
		} else if (NSClassFromString(@"MDSplitView") != nil) {
			splitView = [self addConsoleMissingDrawer:documentView terminalView:terminalView];
		} else { 
			splitView = [self addConsoleVanillaTextMate:documentView terminalView:terminalView];	
		}

		[terminalView release];
		
		NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
		[bindingOptions setObject:NSUnarchiveFromDataTransformerName
						   forKey:@"NSValueTransformerName"];
		[splitView bind:@"vertical"
					 toObject:[NSUserDefaultsController sharedUserDefaultsController] 
				  withKeyPath:@"values.displayConsoleVertical" 
					  options:bindingOptions];
		
		[splitView setDividerStyle:NSSplitViewDividerStyleThin];
		[splitView setDelegate:[[Terminal instance] lastTerminalWindowController]];
		[ivars setObject:splitView forKey:@"splitView"];
		[splitView release];
		[documentView release];
		[[[Terminal instance] lastTerminalWindowController] focusInputField];
	} else {
				
		BOOL isCollapsed = [splitView isSubviewCollapsed:[[splitView subviews] objectAtIndex:1]];
		if (isCollapsed) {
			[splitView setSubview:[[splitView subviews] objectAtIndex:1] isCollapsed:0];
			[[[Terminal instance] lastTerminalWindowController] focusInputField];
		} else {
			[splitView setSubview:[[splitView subviews] objectAtIndex:1] isCollapsed:1];
			[[[[Terminal instance] lastWindowController] window] makeFirstResponder:[self textView]];
		}
		[splitView resizeSubviewsWithOldSize:[splitView bounds].size]; // have to do this.
		[[[Terminal instance] lastTerminalWindowController] scrollToEndOfConsole];
	}
}

/** 
 *	Adds a console in the appropriate place. This expects the TextMate instance to run with
 *	the plugin Project Plus installed
 */
- (MAHJSplitView *)addConsoleProjectPlus:(NSView *)documentView terminalView:(NSView *)terminalView
{
	NSView* preExistingSplitView = documentView;
	BOOL ppSidebarIsOnRight = [[NSUserDefaults standardUserDefaults] boolForKey:@"ProjectPlus Sidebar on Right"];
	
	NSView* realDocumentView;
	NSView* originalSidePane;
	if (ppSidebarIsOnRight) {
		realDocumentView = [[preExistingSplitView subviews] objectAtIndex:0];
		originalSidePane = [[preExistingSplitView subviews] objectAtIndex:1];
	}
	else {
		realDocumentView = [[preExistingSplitView subviews] objectAtIndex:1];
		originalSidePane = [[preExistingSplitView subviews] objectAtIndex:0];
	}
	
	[originalSidePane retain];
	[realDocumentView retain];
	[realDocumentView removeFromSuperview];
	MAHJSplitView *splitView = [[MAHJSplitView alloc] initWithFrame:[realDocumentView frame]];
	
	[splitView addSubview:realDocumentView];
	[splitView addSubview:terminalView];
	
	if (ppSidebarIsOnRight)
		[preExistingSplitView addSubview:splitView];
	[preExistingSplitView addSubview:originalSidePane];
	if (!ppSidebarIsOnRight)
		[preExistingSplitView addSubview:splitView]; 
	
	[realDocumentView release];
	[originalSidePane release];
	return [splitView autorelease];
}

/** 
 *	Adds a console in the appropriate place. This expects the TextMate instance to run with
 *	the plugin MissingDrawer installed
 */
- (MAHJSplitView *)addConsoleMissingDrawer:(NSView *)documentView terminalView:(NSView *)terminalView
{
	NSView* preExistingSplitView = documentView;
	NSView* realDocumentView = [[preExistingSplitView subviews] objectAtIndex:1];
	NSView* originalSidePane = [[preExistingSplitView subviews] objectAtIndex:0];
	[originalSidePane retain];
	[realDocumentView retain];
	[realDocumentView removeFromSuperview];
	MAHJSplitView *splitView = [[MAHJSplitView alloc] initWithFrame:[realDocumentView frame]];
	
	[splitView addSubview:realDocumentView];
	[splitView addSubview:terminalView];
	
	[preExistingSplitView addSubview:originalSidePane];
	[preExistingSplitView addSubview:splitView];
	
	[realDocumentView release];
	[originalSidePane release];
	return [splitView autorelease];
}

/** 
 *	Adds a console in the appropriate place. This expects the TextMate instance to run without
 *	any plugins
 */
- (MAHJSplitView *)addConsoleVanillaTextMate:(NSView *)documentView terminalView:(NSView *)terminalView
{
	[[self window] setContentView:nil];
	MAHJSplitView *splitView = [[MAHJSplitView alloc] initWithFrame:[documentView frame]];
	[splitView addSubview:documentView];
	[splitView addSubview:terminalView];			
	[[self window] setContentView:splitView];
	return [splitView autorelease];
}


- (void)T_windowDidLoad
{
	[self T_windowDidLoad];
	if ([self isKindOfClass:OakProjectController]) {
		// find the path to SBT in the shell variables		
		[[Terminal instance] setLastWindowController:self];		
	} 
	
	
}

#pragma mark Private

- (NSString*)SBTPath {
	NSString *path = @"";
	for (NSDictionary* dic in [[OakPreferencesManager sharedInstance] shellVariables]) {
		if ([[dic objectForKey:@"variable"] isEqualTo:@"SBT_PATH"]){
			path = [dic objectForKey:@"value"];
		}
	}
	return path;
}


@end
