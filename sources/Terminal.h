//
//  Terminal.h
//  Terminal
//
//  Created by Mads Hartmann Jensen 2010
//

#import <Cocoa/Cocoa.h>
@class TerminalWindowController;

@protocol TMPlugInController
- (float)version;
@end

@interface Terminal : NSObject
{
	NSMenu* windowMenu;
	NSMenu* terminalMenu;
	NSMenuItem* terminalItem;
	NSMenuItem* showTerminalMenuItem;
	NSMenuItem* toggleTerminalfocus;
	NSWindowController* lastWindowController;
	TerminalWindowController* lastTerminalWindowController;
	NSMutableDictionary* iVars;
	
	// preference related
	IBOutlet NSView* preferencesView;
	NSImage* iconImage;
	NSWindowController* prefWindowController;
}

@property(retain) NSWindowController* lastWindowController;
@property(retain) TerminalWindowController* lastTerminalWindowController;
@property(retain, readonly) NSImage* iconImage;
@property(retain, readonly) NSView* preferencesView;

+ (Terminal*)instance;
- (id)initWithPlugInController:(id <TMPlugInController>)aController;
- (void)dealloc;
- (void)installMenuItem;
- (void)uninstallMenuItem;
- (NSMutableDictionary*)getIVarsFor:(id)sender;

@end
