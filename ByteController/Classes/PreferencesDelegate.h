/*
 
 PreferencesDelegate.h		Copyright � 2004 Audun Wilhelmsen
 ---------------------------------------------------------------
 Controller for our preferences window. Handles user defaults
 and hot keys.
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

#import <Cocoa/Cocoa.h>
#import "ITControl.h"
#import "SkinManager.h"
#import "Preferences.h"



@interface PreferencesDelegate : NSObject
{
    IBOutlet NSWindow *window;
	
	IBOutlet NSButton *startupSwitch;
	IBOutlet NSButton *autoHideSwitch;
    IBOutlet NSButton *showNotiSwitch;
	
    IBOutlet NSPopUpButton *playerButton;
	
	IBOutlet NSMatrix *skinMatrix;
	IBOutlet NSTextField *skinInfo;
	IBOutlet NSButton *removeButton;

	ITControl *_iTControl;
}

- (void)updateInfo;

- (ITControl*)iTControl;
- (void)setITControl: (ITControl*)aControl;

- (IBAction)removeSkin:(id)sender;
- (IBAction)addSkin:(id)sender;

- (IBAction)setStartup:(id)sender;
- (IBAction)setAutoHide:(id)sender;
- (IBAction)setShowNoti:(id)sender;
- (IBAction)setPlayer:(id)sender;

//Window Delegate Methods

@end
