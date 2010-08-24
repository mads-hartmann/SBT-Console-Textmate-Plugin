//
//  NSWindowController+Preferences.m
//  TextmateCONSOLE
//
//  Created by Julian Eberius on 25.02.10.
//  Copyright 2010 Julian Eberius. All rights reserved.
//

// This reuses a lot of code from Ciarán Walsh's ProjectPlus ( http://ciaranwal.sh/2008/08/05/textmate-plug-in-projectplus )
// Source: git://github.com/ciaran/projectplus.git

#import "NSWindowController+Preferences.h"
#import "Terminal.h"
#import "TextMate.h"

float ToolbarHeightForWindow(NSWindow *window)
{
  NSToolbar *toolbar;
  float toolbarHeight = 0.0;
  NSRect windowFrame;

  toolbar = [window toolbar];

  if(toolbar && [toolbar isVisible])
  {
    windowFrame   = [NSWindow contentRectForFrameRect:[window frame] styleMask:[window styleMask]];
    toolbarHeight = NSHeight(windowFrame) - NSHeight([[window contentView] frame]);
  }

  return toolbarHeight;
}

static NSString* CONSOLE_PREFERENCES_LABEL = @"SBT Console";

@implementation NSWindowController (MM_Preferences)
- (NSArray*)Console_toolbarAllowedItemIdentifiers:(id)sender
{
  return [[self Console_toolbarAllowedItemIdentifiers:sender] arrayByAddingObject:CONSOLE_PREFERENCES_LABEL];
}
- (NSArray*)Console_toolbarDefaultItemIdentifiers:(id)sender
{
  return [[self Console_toolbarDefaultItemIdentifiers:sender] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:CONSOLE_PREFERENCES_LABEL,nil]];
}
- (NSArray*)Console_toolbarSelectableItemIdentifiers:(id)sender
{
  return [[self Console_toolbarSelectableItemIdentifiers:sender] arrayByAddingObject:CONSOLE_PREFERENCES_LABEL];
}

- (NSToolbarItem*)Console_toolbar:(NSToolbar*)toolbar 
			itemForItemIdentifier:(NSString*)itemIdentifier 
		willBeInsertedIntoToolbar:(BOOL)flag
{
  NSToolbarItem *item = [self Console_toolbar:toolbar itemForItemIdentifier:itemIdentifier willBeInsertedIntoToolbar:flag];
  if([itemIdentifier isEqualToString:CONSOLE_PREFERENCES_LABEL])
    [item setImage:[[Terminal instance] iconImage]];
  return item;
}

- (void)Console_selectToolbarItem:(id)item
{
  if ([[item label] isEqualToString:CONSOLE_PREFERENCES_LABEL]) {
    if ([[self valueForKey:@"selectedToolbarItem"] isEqualToString:[item label]]) return;
    [[self window] setTitle:[item label]];
    [self setValue:[item label] forKey:@"selectedToolbarItem"];
    
    NSSize prefsSize = [[[Terminal instance] preferencesView] frame].size;
    NSRect frame = [[self window] frame];
    prefsSize.width = [[self window] contentMinSize].width;

    [[self window] setContentView:[[Terminal instance] preferencesView]];

    float newHeight = prefsSize.height + ToolbarHeightForWindow([self window]) + 22;
    frame.origin.y += frame.size.height - newHeight;
    frame.size.height = newHeight;
    frame.size.width = prefsSize.width;
    [[self window] setFrame:frame display:YES animate:YES];
  } else {
    [self Console_selectToolbarItem:item];
  }
}
@end