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
	NSMenuItem* showTerminalMenuItem;
	NSWindowController* lastWindowController;
	NSMutableDictionary* iVars;
}

@property(retain) NSWindowController* lastWindowController;

+ (Terminal*)instance;
- (id)initWithPlugInController:(id <TMPlugInController>)aController;
- (void)dealloc;
- (void)installMenuItem;
- (void)uninstallMenuItem;
- (NSMutableDictionary*)getIVarsFor:(id)sender;

@end
