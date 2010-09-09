//
//  MAHJSplitView.h
//  Terminal
//
//  Created by Mads Hartmann Jensen on 9/9/10.
//  Copyright 2010 Sideways Coding. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KFSplitView.h"


@interface MAHJSplitView : KFSplitView {

}

- (BOOL)sideBarOnRight;
- (void)setSideBarOnRight:(BOOL)onRight;

- (NSView*)drawerView;
- (NSView*)documentView;

- (float)minLeftWidth;
- (float)minRightWidth;

@end
