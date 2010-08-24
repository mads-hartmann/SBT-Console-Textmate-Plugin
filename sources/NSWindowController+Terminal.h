//
//  NSWindowController+Terminal.h
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/22/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KFSplitView;
@class TerminalWindowController;

@interface NSWindowController (NSWindowControllerTerminal) 

-	(KFSplitView*)getSplitView;
-	(void)toggleTerminal;
-	(void)toggleTerminalFocus;
-	(void)T_windowDidLoad;
-	(TerminalWindowController *)terminalController;


@end
