//
//  TerminalViewController.m
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/18/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import "TerminalWindowController.h"
#import "Terminal.h"

@interface TerminalWindowController (private)
- (bool)mayContainPath:(NSString *)string;
@end

@implementation TerminalWindowController

@synthesize input, output, terminalMenu, projectDir, pathToSbt;

- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner
{	
	self = [super initWithWindowNibPath:windowNibPath owner:owner];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector( readPipe: )
												 name:NSFileHandleReadCompletionNotification 
											   object:nil];
	lastAnalyzedRange = NSMakeRange(0, 0);
	return self;
}

- (void)windowDidLoad
{
	[output setString:@"> "];
}

-(void)readPipe: (NSNotification *)notification
{
    NSData *data;
    NSString *text;
	
    if( [notification object] != _fileHandleReading )
        return;
	
    data = [[notification userInfo] 
            objectForKey:NSFileHandleNotificationDataItem];

    if( _task && [data length] != 0) { // Keep reading if it isn't empty	
		text = [[NSString alloc] initWithData:data 
									 encoding:NSUTF8StringEncoding];
		[self write:text];
		[text release];
        [_fileHandleReading readInBackgroundAndNotify];
	} else { // it's done
		[self write:@"> "];
		[self analyze];
	}
}

- (void)analyze
{
	NSString *text = [[output textStorage] string];
	NSRange range = NSMakeRange(0, [text length]);	
	id myblock = ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		NSAttributedString *aString = [self createAttributedString:substring];
		[[output textStorage] replaceCharactersInRange:substringRange withAttributedString:aString];														
	};
	[text enumerateSubstringsInRange:range 
													 options:NSStringEnumerationByLines 
												usingBlock:myblock];
	lastAnalyzedRange = range;
}

- (void)focusInputField 
{
	[[[[Terminal instance] lastWindowController] window] makeFirstResponder:input];
	[[[[Terminal instance] lastTerminalWindowController] window] makeFirstResponder:input];
}

- (IBAction)enter:(id)sender
{
	NSString *str = [NSString stringWithFormat:@"%@%@", [input stringValue], @"\n"];
	[self write:str];
	if( _task && [_task isRunning]) {
		[_fileHandleWriting writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
		[_fileHandleReading readInBackgroundAndNotify];
	} else {
		NSString *command = [input stringValue];
		if ([command length] > 0)
			[self runCommand:command];
	}
	[self focusInputField];
	[input setStringValue:@""];
}


-(void)write:(NSString *)string
{
	[[output textStorage] appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
	[output scrollToEndOfDocument:self];
}

/**
 *	This methods also takes care of hightlightig a single line of text appropriately (red for errors etc.).
 *	It also creates links of any text with a path that includes the root folder of the current project
 */
-(NSAttributedString*)createAttributedString:(NSString*)string {
	NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:string];
	
	// adding the link attribute if it is applicable
	if ([self mayContainPath:string]){
		NSMutableString *path = [[NSMutableString alloc] initWithString:string];
		int i = [string rangeOfString:@"/"].location;
		[path deleteCharactersInRange:NSMakeRange(0, i)];
		
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
						range:NSMakeRange(0, [aString length])];
	}
	else if([string rangeOfString:@"[success]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor colorWithCalibratedRed:0.125 green:0.729 blue:0.149 alpha:1]
						range:NSMakeRange(0, [aString length])];
	}
	else if([string rangeOfString:@"[warn]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor colorWithCalibratedRed:0.682 green:0.647 blue:0.165 alpha:1]
						range:NSMakeRange(0, [aString length])];
	}
	else if([string rangeOfString:@"[info] =="].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor colorWithCalibratedRed:0.278 green:0.180 blue:0.882 alpha:1]
						range:NSMakeRange(0, [aString length])];
	}
	else {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:[NSColor blackColor]
						range:NSMakeRange(0, [aString length])];
	}
	return [aString autorelease];
}

-(bool)mayContainPath:(NSString *)string
{
	return (([string rangeOfString:[NSString stringWithFormat:@"[error] %@",projectDir]].location != NSNotFound) || 
			([string rangeOfString:[NSString stringWithFormat:@"[warn] %@",projectDir]].location != NSNotFound));
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
	[super dealloc];
}

@end
