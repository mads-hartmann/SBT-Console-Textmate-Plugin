//
//  NSWindow+Terminal.h
//  Terminal
//
//  Created by Mads Hartmann Jensen on 7/22/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWindow (NSWindowTerminal) 

// called when the user switches windows
- (void)T_becomeMainWindow;
- (void)T_setRepresentedFilename:(NSString*)aPath;

@end
