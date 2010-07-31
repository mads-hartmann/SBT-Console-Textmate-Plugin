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
	
	NSString *projectDir;
	NSString *pathToSbt;
	
	NSString *currentLine; 
		
}

-	(void)runCommand:(NSString *)command;
-	(void)write:(NSString *)string;
-	(void)writeSingleLine:(NSString *)string;
-	(NSAttributedString*)colorize:(NSString*)string;

-	(IBAction)clearTerminal:(id)sender;
-	(IBAction)enter:(id)sender;

@property (retain) NSString *projectDir;
@property (retain) NSString *pathToSbt;
@property (retain) NSString *currentLine;
@property (assign) IBOutlet NSTextView *output;
@property (assign) IBOutlet NSTextField *input;
@property (assign) IBOutlet	NSMenuItem *terminalMenu;


@end
