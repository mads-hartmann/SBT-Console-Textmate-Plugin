//
//  TerminalViewController.m
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/18/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import "TerminalWindowController.h"

@implementation TerminalWindowController

@synthesize input, output, terminalMenu, projectDir, pathToSbt, currentLine;

- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner
{	
	self = [super initWithWindowNibPath:windowNibPath owner:owner];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector( readPipe: )
												 name:NSFileHandleReadCompletionNotification 
											   object:nil];
	currentLine = [[NSString alloc] initWithString:@""];
	return self;
}

-(void)readPipe: (NSNotification *)notification
{
    NSData *data;
    NSString *text;
	
    if( [notification object] != _fileHandleReading )
        return;
	
    data = [[notification userInfo] 
            objectForKey:NSFileHandleNotificationDataItem];
    text = [[NSString alloc] initWithData:data 
								 encoding:NSUTF8StringEncoding];
	// only write if there's something interesting
	if (![text isEqualToString:@""])
		[self write:text];
	
    [text release];

    if( _task && [data length] != 0) {
		// Keep reading if it isn't empty
        [_fileHandleReading readInBackgroundAndNotify];
	}
}

- (IBAction)enter:(id)sender
{
	[self writeSingleLine:[input stringValue]];
	if( _task && [_task isRunning]) {
		NSString *stop = @"\n";
		[_fileHandleWriting writeData:[stop dataUsingEncoding:NSUTF8StringEncoding]];
		[_fileHandleReading readInBackgroundAndNotify];
	} else {
		NSString *command = [input stringValue];
		if ([command length] > 0)
			[self runCommand:command];
	}
	[input setStringValue:@""];
}


/*	
 *	Writes a message to the TextView. It will only print the message if it contains a newline char (\n).
 *	If it doesn't it adds to string to a local variable and keeps doing to untill it hits a line line.
 *	This methods also takes care of hightlightig the text appropriately (red for errors etc.).
 */
-(void)write:(NSString *)string
{
	[string retain];
	
	if([string rangeOfString:@"\n"].location == NSNotFound){
		currentLine = [currentLine stringByAppendingString:string];
	} else { // there are newlines!
		
		NSArray *lines = [string componentsSeparatedByString: @"\n"];
		
		// first finish the current line
		currentLine = [currentLine stringByAppendingString:[lines objectAtIndex:0]];
		[self writeSingleLine:currentLine];
		
		// Now add each of the rest of the lines. 
		id *objects;
		NSRange range = NSMakeRange(1, [lines count]-1);
		objects = malloc(sizeof(id) * range.length);
		[lines getObjects:objects range:range];
		
		int i;
		for (i = 0; i < range.length; i++) {
			[self writeSingleLine:(NSString*)objects[i]];
		}
		free(objects);
	}
	[string release];
}

/* 
 *	Adds colors to the string using colorize and adds the string to output
 */
-(void)writeSingleLine:(NSString *)string {

	if (![string isEqualToString:@""]){
		NSAttributedString *aString = [self colorize:[string stringByAppendingString:[[NSString alloc] initWithString:@"\n"]]];
		[[output textStorage] appendAttributedString:aString];
		[output scrollToEndOfDocument:self];
		currentLine = [[NSString alloc] initWithString:@""];
		[aString release];
	}
}

/*
 *	Takes a String and adds the color to it. If it contains the word error it will 
 *	return an NSAttributedString with NSForegroundColorAttributeName set to colorRed etc.
 */
-(NSAttributedString*)colorize:(NSString*)string {
	NSDictionary *attrs;
	if ([string rangeOfString:@"[error]"].location != NSNotFound) {
		attrs = [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName];
	}
	else if([string rangeOfString:@"[success]"].location != NSNotFound) {
		attrs = [NSDictionary dictionaryWithObject:[NSColor greenColor] forKey:NSForegroundColorAttributeName];
	}
	else if([string rangeOfString:@"[warn]"].location != NSNotFound) {
		attrs = [NSDictionary dictionaryWithObject:[NSColor yellowColor] forKey:NSForegroundColorAttributeName];
	}
	else if([string rangeOfString:@"[info] =="].location != NSNotFound) {
		attrs = [NSDictionary dictionaryWithObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
	}
	else {
		attrs = [NSDictionary dictionaryWithObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	}
	return [[NSAttributedString alloc] initWithString:string attributes:attrs];
}

-(void)runCommand:(NSString *)command
{
	[command retain];

	NSPipe *pipe = [NSPipe pipe];
	NSPipe *pipeInput = [NSPipe pipe];
	_fileHandleReading = [pipe fileHandleForReading];
	_fileHandleWriting = [pipeInput fileHandleForWriting];
	[_fileHandleReading readInBackgroundAndNotify];
	
	if (_task != nil){
		// when we're running a new command, clean up after the previous one.
		[_task release];
		_task = nil;
	}
	
	_task = [[NSTask alloc] init];
	[_task setStandardOutput: pipe];
	[_task setStandardError: pipe];
	[_task setStandardInput: pipeInput];
	NSArray *arguments = [NSArray arrayWithObjects: pathToSbt, command, nil];	
	[_task setLaunchPath: @"/bin/sh"];
	[_task setCurrentDirectoryPath:projectDir];
	[_task setArguments:arguments];
	[_task launch];
	
	[command release];
}

-	(IBAction)clearTerminal:(id)sender
{
	[output setString:@""];
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
	[super dealloc];
}

@end
