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
	[self setCurrentLine:[NSMutableString stringWithCapacity:256]];
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
	} else {
		[self writeSingleLine:currentLine];
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
	[[self window] makeFirstResponder:input];
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
		// there a no newlines. This most be a continuation of some earlier ouput
		if ([string length] > 0 && [[string substringToIndex:1] isEqualToString:@"["]) {
			[self writeSingleLine:currentLine];
			[currentLine setString:string];	
		} else {
			[currentLine appendString:string];
		}
	} else {
		// there are many newlines. 
		NSArray *lines = [string componentsSeparatedByString: @"\n"];
		[lines retain];
		for(NSString *line in lines) {
			if ( [line length] == 0 ||
				([line length] > 0 && 
				 [[line substringToIndex:1] isEqualToString:@"["])) 
			{
				[self writeSingleLine:currentLine];
				[currentLine setString:line];
			} else {
				[currentLine appendString:line];
			}
		}
		[lines release];
	}
	[string release];
}

/* 
 *	Adds colors to the string using colorize and adds the string to output
 */
-(void)writeSingleLine:(NSString *)string {

	[string retain];
	if (![string isEqualToString:@""]){
		
		
		NSAttributedString *aString = [self createAttributedString:[string stringByAppendingString:@"\n"]];
		[aString retain];
		[[output textStorage] appendAttributedString:aString];
		[output scrollToEndOfDocument:self];
		[currentLine setString:@""];
		[aString release];
	}
	[string release];

}

-(NSAttributedString*)createAttributedString:(NSString*)string {
	NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:string];
	
	// adding the link attribute if it is applicable
	if ([string rangeOfString:[NSString stringWithFormat:@"[error] %@",projectDir]].location != NSNotFound){
		NSMutableString *path = [[NSMutableString alloc] initWithString:string];
		[path deleteCharactersInRange:NSMakeRange(0, 8)]; // remove [error]\s
		
		NSArray *chunks = [path componentsSeparatedByString:@":"];
		[chunks retain];
		
		// get the range of the link
		NSString *linkString = [NSString stringWithFormat:@"%@:%@", [chunks objectAtIndex:0],[chunks objectAtIndex:1]];
		NSRange range = [string rangeOfString:linkString];
		
		// create the Textmate url Scheme link.
		NSString *link = [NSString stringWithFormat:@"txmt://open/?url=file://%@&line=%@&column=0",
						  [chunks objectAtIndex:0],
						  [chunks objectAtIndex:1]];
		[link retain];
		
		// add the link to the appropriate range.
		[aString addAttribute:NSLinkAttributeName value:link range:NSMakeRange(range.location, range.length)];
		
		[link release];
		[chunks release];
		[path release];
	}
	
	// adding the color attribute
	if ([string rangeOfString:@"[error]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor colorWithCalibratedRed:0.761 green:0.212 blue:0.106 alpha:1] 
						range:NSMakeRange(0, [aString length]-1)];
	}
	else if([string rangeOfString:@"[success]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor colorWithCalibratedRed:0.125 green:0.729 blue:0.149 alpha:1]
						range:NSMakeRange(0, [aString length]-1)];
	}
	else if([string rangeOfString:@"[warn]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor colorWithCalibratedRed:0.682 green:0.647 blue:0.165 alpha:1]
						range:NSMakeRange(0, [aString length]-1)];
	}
	else if([string rangeOfString:@"[info] =="].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor colorWithCalibratedRed:0.278 green:0.180 blue:0.882 alpha:1]
						range:NSMakeRange(0, [aString length]-1)];
	}
	else {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor blackColor]
						range:NSMakeRange(0, [aString length]-1)];
	}
	return [aString autorelease];
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
	NSLog(@"deallocing TerminalWindowController");
	[currentLine release];
	currentLine = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
	[super dealloc];
}

@end
