//
//  TerminalViewController.m
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/18/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import "TerminalWindowController.h"

@implementation TerminalWindowController

@synthesize input, output, terminalMenu, projectDir, pathToSbt;

- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner
{	
	self = [super initWithWindowNibPath:windowNibPath owner:owner];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector( readPipe: )
												 name:NSFileHandleReadCompletionNotification 
											   object:nil];
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
	NSString *outv = [NSString stringWithFormat:@"%@%@\n",[output string],[input stringValue]];
	[output setString:outv];
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
	[output setString:outv];
}


-(void)write:(NSString *)string
{
	[string retain];
	NSString *outputValue = [NSString stringWithFormat:@"%@%@",[output string], string];
	[output setString:outputValue];
	[output scrollToEndOfDocument:self];
	[string release];
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
		// when we're running a new command, clean up after 
		//the previous one.
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
	NSLog(@"Deallocing TerminalWindowController");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

@end
