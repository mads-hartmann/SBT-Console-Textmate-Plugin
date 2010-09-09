// Code inherited from Ciarán Walsh's ProjectPlus ( http://ciaranwal.sh/2008/08/05/textmate-plug-in-projectplus )

#import "MAHJSplitView.h"

@implementation MAHJSplitView


- (BOOL)sideBarOnRight;
{
	return YES;
}

- (void)setSideBarOnRight:(BOOL)onRight;
{
	
}

- (NSView*)drawerView
{
	return [[self subviews] objectAtIndex:1];
}

- (NSView*)documentView
{
	
	return [[self subviews] objectAtIndex:0];
	
}

#define MIN_DRAWER_VIEW_WIDTH   90
#define MIN_DOCUMENT_VIEW_WIDTH 400

- (float)minLeftWidth
{
	return [self sideBarOnRight] ? MIN_DOCUMENT_VIEW_WIDTH : MIN_DRAWER_VIEW_WIDTH;
}

- (float)minRightWidth
{
	return [self sideBarOnRight] ? MIN_DRAWER_VIEW_WIDTH : MIN_DOCUMENT_VIEW_WIDTH;
}
@end