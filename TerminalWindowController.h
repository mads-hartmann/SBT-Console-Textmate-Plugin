//
//  TerminalViewController.h
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/18/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//
//	This class controls the Terminal. 
//

#import <Cocoa/Cocoa.h>


@interface TerminalWindowController : NSWindowController {

	NSTextView *output;
	NSTextField	*input;
	NSMenu* windowMenu;
	NSMenuItem* terminalMenu;
	
	NSTask       *_task;
	NSFileHandle *_fileHandleReading;
	NSFileHandle *_fileHandleWriting;
	
}

-	(IBAction)enter:(id)sender;
-	(void)runCommand:(NSString *)command;
-	(IBAction)clearTerminal:(id)sender;
-	(void)write:(NSString *)string;

@property (assign) IBOutlet NSTextView *output;
@property (assign) IBOutlet NSTextField *input;
@property (assign) IBOutlet	NSMenuItem *terminalMenu;


@end
