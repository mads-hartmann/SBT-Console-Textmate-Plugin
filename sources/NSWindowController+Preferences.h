// This reuses a lot of code from Julian Eberius's Textmate-Minimap ( http://github.com/JulianEberius/Textmate-Minimap )

#import <Cocoa/Cocoa.h>

@interface NSWindowController (Console_Preferences)

- (NSArray*)Console_toolbarAllowedItemIdentifiers:(id)sender;

- (NSArray*)Console_toolbarDefaultItemIdentifiers:(id)sender;

- (NSArray*)Console_toolbarSelectableItemIdentifiers:(id)sender;

- (NSToolbarItem*)Console_toolbar:(NSToolbar*)toolbar 
			itemForItemIdentifier:(NSString*)itemIdentifier 
		willBeInsertedIntoToolbar:(BOOL)flag;

- (void)Console_selectToolbarItem:(id)item;

@end