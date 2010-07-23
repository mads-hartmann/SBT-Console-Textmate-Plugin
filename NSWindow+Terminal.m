//
//  NSWindow+Terminal.m
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/22/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import "NSWindow+Terminal.h"
#import "Terminal.h"
#import "TextMate.h"

@implementation NSWindow (NSWindowTerminal)

/*
 Swizzled method: called when a window is brought to the front
 - update the main menu to show the correct menu item ("show" or "hide" minimap)
 - update the lastWindowController
 */
- (void)T_becomeMainWindow
{
	[self T_becomeMainWindow];
	NSWindowController* controller = [self windowController];
	[[Terminal instance] setLastWindowController:controller];
	if ([controller isKindOfClass:OakProjectController]) {
		NSLog(@"proj");
//		[[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTitle:@"Show/Hide Terminal"] setHidden:NO];
//		[[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTitle:@"Toggle Terminal Foucs"] setHidden:NO];
		[[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTitle:@"Terminal"] setHidden:NO];
		[[Terminal instance] setLastWindowController:controller];
	} else if ([controller isKindOfClass:OakDocumentController]){
		NSLog(@"doc");
		[[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTitle:@"Terminal"] setHidden:YES];
//		[[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTitle:@"Show/Hide Terminal"] setHidden:YES];
//		[[[[[NSApp mainMenu] itemWithTitle:@"View"] submenu] itemWithTitle:@"Toggle Terminal Foucs"] setHidden:YES];
	}
}

@end
