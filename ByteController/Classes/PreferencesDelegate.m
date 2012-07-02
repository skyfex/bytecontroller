/*
 
 PreferencesDelegate.m		Copyright � 2004 Audun Wilhelmsen
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


#import "PreferencesDelegate.h"

@implementation PreferencesDelegate

- (ITControl*)iTControl;
{	
	return _iTControl;
}
- (void)setITControl: (ITControl*)aControl
{
	_iTControl = aControl;
}

#pragma mark -

- (void)updateSkinList
{
	NSArray *skinArray = [[SkinManager defaultManager] skinList];
	NSString *defaultSkin = [[SkinManager defaultManager] defaultSkin];
	NSString *skinPath;
	Skin *currentSkin;
	int i;
	
	[skinMatrix renewRows: [skinArray count] columns: 1];
	
	for (i=0;i<[skinArray count];i++)
	{
		skinPath = [skinArray objectAtIndex: i];
		currentSkin = [Skin skinWithPath: skinPath];
		[[skinMatrix cellAtRow: i column: 0] setSkin: currentSkin];
		if ([skinPath isEqual: defaultSkin])
			[skinMatrix selectCellAtRow: i column: 0];
	}
	[skinMatrix setNeedsDisplay: YES];
	[skinMatrix sizeToCells];
	[self updateInfo];
}

- (void)updateInfo
{
	// Update the Info Panel and Enable/Disable Remove button
	Skin *selectedSkin = [[skinMatrix selectedCell] skin];
	
	// Check whether the skin is a pre-installed skin
	if ([[selectedSkin path] hasPrefix: [[NSBundle mainBundle] bundlePath]])
		[removeButton setEnabled: NO];
	else
		[removeButton setEnabled: YES];
	
	
	NSString *dateText;
	if ([[selectedSkin created] isKindOfClass: [NSString class]])
		dateText = (NSString *)[selectedSkin created];
	else
		dateText = [[selectedSkin created] descriptionWithCalendarFormat: @"%b %d %Y" timeZone: nil locale: nil];
	[skinInfo setStringValue:
		[NSString stringWithFormat: @"%@ by %@\n%@\nCreated: %@\n\n%@\n\n%@", [selectedSkin name], [selectedSkin author],
			[selectedSkin copyrightText], dateText, 
			[selectedSkin description], [selectedSkin note]]];
}

- (void)chooseSkin:(id)sender
{
	// Action from the skinMatrix
	Skin *selectedSkin = [[sender selectedCell] skin];
	if (!selectedSkin)
		return;
	[[SkinManager defaultManager] setDefaultSkin: selectedSkin];
	[self updateInfo];
}

- (void)skinListWasUpdated:(NSNotification *)aNotification
{
	// BCSkinListWasUpdate Notification, from SkinManager
	[self updateSkinList];
}


#pragma mark -

- (IBAction)removeSkin:(id)sender
{
	// Remove... Button. Prompt dialog. Remove the selected Skin.
	if (NSRunAlertPanel(@"Are you sure you want to remove this skin?", 
						@"Removing a skin is unrecoverable, do not proceed unless you are absolutely sure you want to remove the skin.", 
						@"Remove", @"Cancel", nil) == NSAlertDefaultReturn)
		[[SkinManager defaultManager] removeSkin: [[[skinMatrix selectedCell] skin] path]];
}

- (IBAction)addSkin:(id)sender
{
	// Add... Button. Show Open dialog, add skin.
	NSOpenPanel *open = [NSOpenPanel openPanel];
	[open setCanChooseFiles: YES];
	[open setCanChooseDirectories: NO];
	[open setAllowsMultipleSelection: NO];
	
	[open beginSheetForDirectory: nil
							file: nil
						   types: [NSArray arrayWithObjects: @"bcskin", nil] 
				  modalForWindow: window
				   modalDelegate: self
				  didEndSelector: @selector(openPanelDone:returnCode:contextInfo:)
					 contextInfo: nil];
}

- (void)openPanelDone:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	// Callback from NSOpenPanel call in addSkin:
	if (returnCode == NSOKButton)
	{
		NSString *skinFile = [sheet filename];
		[[SkinManager defaultManager] addSkin: skinFile setDefault: YES];
	}
}

#pragma mark -

- (id)init
{
	if ((self = [super init]) != nil)
	{
		[[NSNotificationCenter defaultCenter] addObserver: self 
												 selector: @selector(skinListWasUpdated:) 
													 name: @"BCSkinListWasUpdated" 
												   object: nil];
		// OOops.. The new KeyField eliminated this too..
	}
	
	return self;
}

- (void)dealloc
{
	/// And this =)
	[super dealloc];
}

- (void)awakeFromNib
{

	// Place Preferences Window in center of screen
	
	NSRect windowFrame = [window frame];
	NSRect screenFrame = [[window screen] visibleFrame];
	NSRect newFrame = NSMakeRect((screenFrame.size.width / 2) - (windowFrame.size.width / 2),
								 screenFrame.origin.y + (screenFrame.size.height/2),
								 windowFrame.size.width, windowFrame.size.height);
	[window setFrame:newFrame display:NO];
	
	// Load Login Item status
	if ([[Preferences defaultPreferences] isInLoginItems])
		[startupSwitch setState: NSOnState];
	else
		[startupSwitch setState: NSOffState];
	
	// Load AutoHide item
	if ([[Preferences defaultPreferences] autoHide])
		[autoHideSwitch setState: NSOnState];
	else
		[autoHideSwitch setState: NSOffState];
    
    // 
    if ([[Preferences defaultPreferences] showNoti])
		[showNotiSwitch setState: NSOnState];
	else
		[showNotiSwitch setState: NSOffState];
	
	// Fix skin matrix
	[skinMatrix setCellClass: [SkinCell class]];
	SkinCell *prototype = [[[SkinCell alloc] init] autorelease];
	[prototype setTarget: self];
	[prototype setAction: @selector(chooseSkin:)];
	[skinMatrix setPrototype: prototype];
	[skinMatrix setAllowsEmptySelection: NO];
	[skinMatrix removeRow:0];
	[self updateSkinList];
	[self updateInfo];
    
    // Players
    [playerButton selectItemAtIndex: [[Preferences defaultPreferences] player]];
}

#pragma mark -

- (IBAction)setStartup:(id)sender
{
	if ([sender state] == NSOnState)
		[[Preferences defaultPreferences] addToLoginItems:NO];
	else
		[[Preferences defaultPreferences] removeFromLoginItems];
}

- (IBAction)setAutoHide:(id)sender
{
    [[Preferences defaultPreferences] setAutoHide: [sender state] == NSOnState];
}

- (IBAction)setShowNoti:(id)sender
{
    [[Preferences defaultPreferences] setShowNoti: ([sender state] == NSOnState)];
}
- (IBAction)setPlayer:(id)sender
{
    [[Preferences defaultPreferences] setPlayer: [playerButton indexOfSelectedItem]];
}

#pragma mark -



#pragma mark -



@end
