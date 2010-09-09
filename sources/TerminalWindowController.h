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

	NSScrollView *outputContainer;
	NSTextView *output;
	NSTextField	*input;
	NSMenu* windowMenu;
	NSMenuItem* terminalMenu;
	
	NSTask       *_task;
	NSFileHandle *_fileHandleReading;
	NSFileHandle *_fileHandleWriting;
	
	NSString *projectDir;
	NSString *pathToSbt;
	NSRange lastAnalyzedRange;
		
}

-	(void)runSBTCommand:(NSString *)command;
-	(void)write:(NSString *)string;
-	(void)focusInputField;
-	(NSAttributedString*)createAttributedString:(NSString*)string;
-	(void)analyze;
-	(void)scrollToEndOfConsole;

-	(IBAction)clearTerminal:(id)sender;
-	(IBAction)enter:(id)sender;

- (void)splitView:(id)sender resizeSubviewsWithOldSize:(NSSize)oldSize;

@property (retain) NSString *projectDir;
@property (retain) NSString *pathToSbt;
@property (assign) IBOutlet NSScrollView *outputContainer;
@property (assign) IBOutlet NSTextView *output;
@property (assign) IBOutlet NSTextField *input;
@property (assign) IBOutlet	NSMenuItem *terminalMenu;


@end
