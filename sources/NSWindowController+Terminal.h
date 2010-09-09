//
//  NSWindowController+Terminal.h
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/22/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MAHJSplitView;
@class TerminalWindowController;

@interface NSWindowController (NSWindowControllerTerminal) 

-	(MAHJSplitView*)getSplitView;
-	(void)toggleTerminal;
-	(void)toggleTerminalFocus;
-	(void)T_windowDidLoad;
-	(TerminalWindowController *)terminalController;

- (MAHJSplitView *)addConsoleProjectPlus:(NSView *)documentView terminalView:(NSView *)terminalView;
- (MAHJSplitView *)addConsoleMissingDrawer:(NSView *)documentView terminalView:(NSView *)terminalView;
- (MAHJSplitView *)addConsoleVanillaTextMate:(NSView *)documentView terminalView:(NSView *)terminalView;

@end
