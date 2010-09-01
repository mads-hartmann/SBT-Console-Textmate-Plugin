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

@synthesize input, output, terminalMenu, projectDir, pathToSbt, outputContainer;

- (id)initWithWindowNibPath:(NSString *)windowNibPath owner:(id)owner
{	
	self = [super initWithWindowNibPath:windowNibPath owner:owner];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector( readPipe: )
												 name:NSFileHandleReadCompletionNotification 
											   object:nil];
	lastAnalyzedRange = NSMakeRange(0, 0);
	
	
	// defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *defaultColors = [[NSMutableDictionary alloc] initWithCapacity:6];
	
	NSColor *normal		= [NSColor colorWithCalibratedWhite:0.000 alpha:1.000];
	NSColor *error		= [NSColor colorWithCalibratedRed:0.786 green:0.724 blue:0.106 alpha:1.000];
	NSColor *seperator	= [NSColor colorWithCalibratedRed:0.470 green:0.475 blue:0.488 alpha:1.000];
	NSColor *success	= [NSColor colorWithCalibratedRed:0.000 green:0.650 blue:0.004 alpha:1.000];
	NSColor *warning	= [NSColor colorWithCalibratedRed:0.517 green:0.120 blue:0.121 alpha:1.000];
	NSColor *background = [NSColor colorWithCalibratedRed:0.964 green:0.965 blue:0.995 alpha:1.000];
	
	NSData *normalD		= [NSArchiver archivedDataWithRootObject:normal];
	NSData *errorD		= [NSArchiver archivedDataWithRootObject:error];
	NSData *seperatorD	= [NSArchiver archivedDataWithRootObject:seperator];
	NSData *successD	= [NSArchiver archivedDataWithRootObject:success];
	NSData *warningD	= [NSArchiver archivedDataWithRootObject:warning];
	NSData *backgroundD = [NSArchiver archivedDataWithRootObject:background];

	[defaultColors setObject:backgroundD forKey:@"backgroundColor"];
	[defaultColors setObject:normalD forKey:@"normalColor"];
	[defaultColors setObject:warningD forKey:@"warningColor"];
	[defaultColors setObject:errorD forKey:@"errorColor"];
	[defaultColors setObject:successD forKey:@"successColor"];
	[defaultColors setObject:seperatorD forKey:@"seperatorColors"];
		
	[defaults registerDefaults:defaultColors];

	return self;
}

- (void)windowDidLoad
{

	//
	// Binding and setting defaults to the view.
	
	NSMutableDictionary *bindingOptions = [NSMutableDictionary dictionary];
	[bindingOptions setObject:NSUnarchiveFromDataTransformerName
					   forKey:@"NSValueTransformerName"];

	// set the colors
	
	[input bind: @"backgroundColor"
		   toObject: [NSUserDefaultsController sharedUserDefaultsController]
		withKeyPath:@"values.backgroundColor"
			options:bindingOptions];
	[input bind: @"textColor"
	   toObject: [NSUserDefaultsController sharedUserDefaultsController]
	withKeyPath:@"values.normalColor"
		options:bindingOptions];

	[outputContainer bind: @"backgroundColor"
		   toObject: [NSUserDefaultsController sharedUserDefaultsController]
		withKeyPath:@"values.backgroundColor"
			options:bindingOptions];
	
	// set the font
	NSString *fontName = [[NSUserDefaults standardUserDefaults] stringForKey:@"OakTextViewNormalFontName"];
	int fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"OakTextViewNormalFontSize"];
	NSFont *font = [NSFont fontWithName:fontName size:fontSize];
	[input setFont:font];
	[output setFont:font];

	[self write:@"\nWelcome. \nTo start an interactive SBT session type sbt shell. to run a single command type sbt <command> \n$ "];
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
		[self write:@"$ "];
		[self analyze];
	}
}

- (void)analyze
{
	NSString *text = [[output textStorage] string];
	NSRange range = NSMakeRange(0, [text length]);	
	id myblock = ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
		[substring retain];
		NSAttributedString *aString = [self createAttributedString:[substring autorelease]];
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
	if( _task && [_task isRunning]) {
		[_fileHandleWriting writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
		[_fileHandleReading readInBackgroundAndNotify];
	} else {
		if( [str rangeOfString:@"sbt"].location != NSNotFound ) {
			[self write:str];
			[self runSBTCommand:str];
		} else {
			[self write:[NSString stringWithFormat:@"Unkown command (try sbt shell or sbt compile) %@$ ", str]];
		}
	}
	[self focusInputField];
	[input setStringValue:@""];
}


-(void)write:(NSString *)string
{
	NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:string];
	
	NSFont *font = [output font];
	NSString *size = [NSString stringWithFormat:@"%i", [font pointSize]];
	
	[aString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [aString length])];
	[aString addAttribute:NSFontSizeAttribute value:size range:NSMakeRange(0, [aString length])];
	
	
	[[output textStorage] appendAttributedString:aString];
	[aString release];
	[self scrollToEndOfConsole];
	if ([string rangeOfString:@"> "].location != NSNotFound  ) {
		[self analyze];
	}
		
}

- (void)scrollToEndOfConsole {
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
	
	// fetch colors from the defults
	
	NSColor * normalColor =nil;
	NSData *normalData=[[NSUserDefaults standardUserDefaults] dataForKey:@"normalColor"];
	if (normalData != nil){
		normalColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:normalData];
	}

	// warning
	NSColor * warningColor =nil;
	NSData *warningData=[[NSUserDefaults standardUserDefaults] dataForKey:@"warningColor"];
	if (warningData != nil) {
		warningColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:warningData];
	} 

	// error
	NSColor * errorColor =nil;
	NSData *errorData=[[NSUserDefaults standardUserDefaults] dataForKey:@"errorColor"];
	if (errorData != nil) {
		errorColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:errorData];
	} 
		
	// success
	NSColor * successColor =nil;
	NSData *successData=[[NSUserDefaults standardUserDefaults] dataForKey:@"successColor"];
	if (successData != nil) {
		successColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:successData];
	} 

	// seperate color
	NSColor * seperatorColor =nil;
	NSData *seperatorData=[[NSUserDefaults standardUserDefaults] dataForKey:@"seperatorColor"];
	if (seperatorData != nil) {
		seperatorColor =(NSColor *)[NSUnarchiver unarchiveObjectWithData:seperatorData];
	} 
	
	// adding the color attribute
	if ([string rangeOfString:@"[error]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:errorColor
						range:NSMakeRange(0, [aString length])];
	}
	else if([string rangeOfString:@"[success]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:successColor
						range:NSMakeRange(0, [aString length])];
	}
	else if([string rangeOfString:@"[warn]"].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:warningColor
						range:NSMakeRange(0, [aString length])];
	}
	else if([string rangeOfString:@"[info] =="].location != NSNotFound) {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:seperatorColor
						range:NSMakeRange(0, [aString length])];
	}
	else {
		[aString addAttribute:NSForegroundColorAttributeName 
						value:normalColor
						range:NSMakeRange(0, [aString length])];
	}
	

	NSFont *font = [output font];
	NSString *size = [NSString stringWithFormat:@"%i", [font pointSize]];
	
	[aString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [aString length])];
	[aString addAttribute:NSFontSizeAttribute value:size range:NSMakeRange(0, [aString length])];
	
	return [aString autorelease];
}

-(bool)mayContainPath:(NSString *)string
{
	return (([string rangeOfString:[NSString stringWithFormat:@"[error] %@",projectDir]].location != NSNotFound) || 
			([string rangeOfString:[NSString stringWithFormat:@"[warn] %@",projectDir]].location != NSNotFound));
}

-(void)runSBTCommand:(NSString*)command
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
	NSArray *splits = [command componentsSeparatedByString:@" "];
	NSArray *commands = [splits subarrayWithRange:NSMakeRange(1, [splits count]-1)];
	NSMutableArray *arguments = [NSMutableArray arrayWithObject:pathToSbt];
	[arguments addObjectsFromArray:commands];
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
