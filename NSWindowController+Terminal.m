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
#import "KFSplitView.h"

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

- (KFSplitView*)getSplitView
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	return (KFSplitView*)[ivars objectForKey:@"splitView"];
}

- (void)toggleTerminalFocus
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	KFSplitView *splitView = [ivars objectForKey:@"splitView"];
	if ( splitView == nil) { // closed
		[self toggleTerminal];
	}
	Terminal *instance = [Terminal instance];
	NSLog(@"%@",[[[instance lastWindowController] window] firstResponder]);
	if ([[[[instance lastWindowController] window] firstResponder] isKindOfClass:OakTextView]){
		[[[instance lastWindowController] window] makeFirstResponder:[[instance lastTerminalWindowController] input]];
	} else {
		[[[instance lastWindowController] window] makeFirstResponder:[self textView]];
	}

}

- (void)toggleTerminal
{
	NSMutableDictionary* ivars = [[Terminal instance] getIVarsFor:self];
	KFSplitView *splitView = [ivars objectForKey:@"splitView"];
	
	// Creat the drawer if it doesn't exist.
	if (splitView == nil){
		// Create the content for the drawer. (hacky, but it needs an owner)
		NSString* nibPath = [[NSBundle bundleForClass:[[Terminal instance] class]] pathForResource:@"Terminal" ofType:@"nib"];
		TerminalWindowController* obj = [TerminalWindowController alloc]; 
		TerminalWindowController* controller = [obj initWithWindowNibPath:nibPath owner:obj];
		
		// setting the project path
		[controller setProjectDir:[self projectDirectory]];
		[controller setPathToSbt:[self SBTPath]];
		[[Terminal instance] setLastTerminalWindowController:controller];
		NSView *terminalView = [[controller window] contentView];
		[terminalView retain];
		NSView* documentView = [[[self window] contentView] retain];
		
		// check whether projectplus or missingdrawer is present
		// if so, put our splitview into their splitview, not to confuse their implementation
		// (which sadly does [window contentView] to find it's own splitView)
		if (NSClassFromString(@"CWTMSplitView") != nil
			&& [[NSUserDefaults standardUserDefaults] boolForKey:@"ProjectPlus Sidebar Enabled"]
			&& [self isKindOfClass:OakProjectController]) {
			
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
			splitView = [[KFSplitView alloc] initWithFrame:[realDocumentView frame]];
			[splitView setVertical:NO];
			
			[splitView addSubview:realDocumentView];
			[splitView addSubview:terminalView];
			
			[preExistingSplitView addSubview:splitView];    
			
			[realDocumentView release];
			[originalSidePane release];
		} else { // no relevant plugins present, init in contentView of Window
			[[self window] setContentView:nil];
			splitView = [[KFSplitView alloc] initWithFrame:[documentView frame]];
			[splitView setVertical:NO];
			[splitView addSubview:documentView];
			[splitView addSubview:terminalView];			
			[[self window] setContentView:splitView];
		}
		[terminalView release];
		[splitView setDividerStyle:NSSplitViewDividerStyleThin];
		[[[splitView subviews] objectAtIndex:1] setFrameSize:NSMakeSize([[self window] frame].size.width , 200)];
		[ivars setObject:splitView forKey:@"splitView"];
		[splitView release];
		[documentView release];
	} else {
		BOOL isCollapsed = [splitView isSubviewCollapsed:[[splitView subviews] objectAtIndex:1]];
		if (isCollapsed) {
			[splitView setSubview:[[splitView subviews] objectAtIndex:1] isCollapsed:0];
		} else {
			[splitView setSubview:[[splitView subviews] objectAtIndex:1] isCollapsed:1];
		}
		[splitView resizeSubviewsWithOldSize:[splitView bounds].size]; // have to do this.
	}
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
