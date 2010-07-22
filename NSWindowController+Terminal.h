//
//  NSWindowController+Terminal.h
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/22/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWindowController (NSWindowControllerTerminal) 

-	(NSDrawer*)getDrawer;
-	(void)toggleTerminal;
-	(void)toggleTerminalFocus;
-	(void)T_windowDidLoad;


@end
