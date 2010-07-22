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

// stuff that the textmate-windowcontrollers (OakProjectController, OakDocumentControler) implement
@interface NSWindowController (TextMate_WindowControllers_Only)

- (id)textView;
- (void)goToLineNumber:(id)newLine;
- (unsigned int)getLineHeight;
- (NSString*)filename; // that is only implemented by OakProjectController

@end


@implementation NSWindowController (NSWindowControllerTerminal)

/*
 Get the NSDrawer the Minimap is in. Can return nil if there is no drawer (e.g. if sidepane mode enabled)
 */
- (NSDrawer*)getDrawer
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	return (NSDrawer*)[ivars objectForKey:@"drawer"];
}

- (void)toggleTerminal
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	NSDrawer *drawer = [ivars objectForKey:@"drawer"];
	
	// Creat the drawer if it doesn't exist.
	if (drawer == nil){
		// Create the content for the drawer. (hacky, but it needs an owner)
		NSString* nibPath = [[NSBundle bundleForClass:[[Terminal instance] class]] pathForResource:@"Terminal" ofType:@"nib"];
		TerminalWindowController* obj = [TerminalWindowController alloc]; 
		TerminalWindowController* controller = [obj initWithWindowNibPath:nibPath owner:obj];
		NSView *content = [[controller window] contentView];

		// Create the drawer
		NSWindow* window=[self window];
		NSSize contentSize = NSMakeSize([window frame].size.width,100);
		drawer = [[NSDrawer alloc] initWithContentSize:contentSize
												   preferredEdge:NSMinYEdge];
		[drawer setContentView:content];
		[drawer setParentWindow:window];
		[drawer setLeadingOffset:20];
		[drawer setTrailingOffset:20];
		[ivars setObject:drawer forKey:@"drawer"];
	}	
	int state = [drawer state];
	if (state == 2) { // open
		[drawer close];
	} else if ( state == 0) { // closed
		[drawer openOnEdge:NSMinYEdge];
	}
}

- (void)T_windowDidLoad
{
	[self T_windowDidLoad];
	[[Terminal instance] setLastWindowController:self];
	
}

@end
