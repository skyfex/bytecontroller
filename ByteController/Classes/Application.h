/*
 
 Application.h		Copyright � 2004 Audun Wilhelmsen
 ---------------------------------------------------------------
 Application Controller. Handles initialization, termination
 and skin files.
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
#import "shared.h"
#import "ControlView.h"
#import "SkinManager.h"
#import "PreferencesDelegate.h"

#define APP_NAME @"ByteController"

@interface Application : NSObject<GrowlApplicationBridgeDelegate>
{
	ControlView *controlView;
	NSStatusItem *controlItem;
	ITControl *_iTControl;
	
	IBOutlet NSApplication *application;
	IBOutlet NSMenu *contextMenu;
	
	
	IBOutlet PreferencesDelegate *prefDelegate;
}

+ (Application *)defaultApplication;

- (ControlView*)controlView;
- (void)setControlView: (ControlView*)view;
- (void)updatePlayerControl;

- (NSStatusItem *)controlItem;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification;
- (void)applicationWillTerminate:(NSNotification *)aNotification;
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

- (void)showGrowlNotification;

- (NSDictionary *) registrationDictionaryForGrowl;
- (NSString *) applicationNameForGrowl;

@end