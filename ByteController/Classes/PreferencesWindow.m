/*
 
 PreferenceWindow.m		Copyright � 2004 Audun Wilhelmsen
 ---------------------------------------------------------------
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA
 
 */


#import "PreferencesWindow.h"

@implementation PreferenceWindow

- (void)makeKeyAndOrderFront:(id)sender
{
	// Hack to make sure window comes to front.. Our window is shy ;)
	[super makeKeyAndOrderFront:sender];
	[NSApp activateIgnoringOtherApps: YES];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	if (([event modifierFlags] & NSCommandKeyMask) && ([event keyCode] == 13))
	{
		[self close];
		return YES;
	}
	return [super performKeyEquivalent:event];
}

- (void)tabView:(NSTabView *)tabView willSelectTabViewItem:(NSTabViewItem *)tabViewItem;
{
	NSRect newRect = [self frame];
	float newSize = -1;
	
	[[[[tabViewItem tabView] selectedTabViewItem] view] removeFromSuperview];
	if ([[tabViewItem identifier] isEqualToString:@"general"])
		newSize = GENERAL_HEIGHT;
	if ([[tabViewItem identifier] isEqualToString:@"hotkeys"])
		newSize = HOTKEYS_HEIGHT;
	if ([[tabViewItem identifier] isEqualToString:@"appearance"])
		newSize = APPEARANCE_HEIGHT;
	
	if (newSize == -1)
		return;
	
	newRect.origin.y = newRect.origin.y - (newSize -newRect.size.height);
	newRect.size.height = newSize;
	
	[self setFrame:newRect display:YES animate:YES];
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[tabView addSubview: [tabViewItem view]];
}

@end
