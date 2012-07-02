/*
 
 Application.m		Copyright � 2004 Audun Wilhelmsen
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


#import "Application.h"

static Application *_defaultBCApplication = nil;

@implementation Application

- (void)awakeFromNib
{
	_defaultBCApplication = self;
}

+ (Application *)defaultApplication
{
	return _defaultBCApplication;
}

#pragma mark -
#pragma mark ControlView delegation
#pragma mark -

- (void)shouldPopupMenu:(id)aSender
{
    NSEvent *fakeEvent;
    fakeEvent = [NSEvent mouseEventWithType: NSRightMouseUp 
                                   location: NSMakePoint(0, -4)
                              modifierFlags: 0
                                  timestamp: 0 
                               windowNumber: [[controlView window] windowNumber] 
                                    context: [NSGraphicsContext currentContext]
                                eventNumber: 0 
                                 clickCount: 1 
                                   pressure: 0];
    [NSMenu popUpContextMenu: contextMenu withEvent: fakeEvent forView: controlView]; 
}

#pragma mark -
#pragma mark ITControl delegation
#pragma mark -


- (void)playerDidChangeState:(ITState)aState
{
	if (aState == ITPaused)
		[controlView setIsPlaying:NO];
	else if (aState == ITStopped)
		[controlView setIsPlaying:NO];
	else
		[controlView setIsPlaying:YES];
}

- (void)playerWasLaunched
{
	if ([[Preferences defaultPreferences] autoHide])
	{
		if (!controlItem)
		{
			controlItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength];
			[controlItem retain];
			[controlItem setView: controlView];
		}
	}
}
- (void)playerWasTerminated
{
	if ([[Preferences defaultPreferences] autoHide])
	{
		if (controlItem)
		{
			[[NSStatusBar systemStatusBar] removeStatusItem: controlItem];
			controlItem = nil;
		}
	}
}

#pragma mark -
#pragma mark Set/Get
#pragma mark -

- (ControlView*)controlView
{
	return controlView;
}

- (void)setControlView: (ControlView*)view
{
	controlView = view;
	[controlView setITControl: _iTControl];
	[controlView setDelegate: self];
	
	[self playerDidChangeState: [_iTControl playerState]];
	
	[prefDelegate setITControl:_iTControl];
}

- (NSStatusItem *)controlItem
{
	return controlItem;
}

- (void)updatePlayerControl
{
    if (_iTControl) [_iTControl release];
    _iTControl = [[ITControl alloc] initWithType: [[Preferences defaultPreferences] player]];
    [_iTControl setDelegate: self];
    if (controlView) [controlView setITControl: _iTControl];
    [self playerDidChangeState: [_iTControl playerState]];
}

#pragma mark -
#pragma mark Application Delegation
#pragma mark -

- (void)defaultSkinChanged:(NSNotification *)aNotification
{
	Skin *defaultSkin;
	
	if ([aNotification object])
		defaultSkin = [aNotification object];
	else
		defaultSkin = [Skin skinWithPath: [[SkinManager defaultManager] defaultSkin]];
	[controlView setSkin: defaultSkin];
}

- (void)testStuff:(NSNotification *)aNotification
{
	NSLog(@"%@: %@", [aNotification name], [aNotification object]);
}


- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{	
	// ---- Initialization ----
	NSStatusBar *bar = [NSStatusBar systemStatusBar];
	
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(defaultSkinChanged:) 
												 name: @"BCDefaultSkinChanged"
											   object: nil];
	
    controlView = nil;
    
	// Set up iTunes Controller Object
    _iTControl = nil;
    [self updatePlayerControl];
	
	// Set up Controller View
	[self setControlView: [[ControlView alloc] initWithFrame:NSMakeRect(0,0,10,10)]];
	[controlView loadFromBundle: [[SkinManager defaultManager] defaultSkin]];
	
	// If we want to auto-hide and iTunes is closed, return here
	if ([[Preferences defaultPreferences] autoHide])
		if (![_iTControl isLaunched])
			return;
    
    // Fix Notifications
    [GrowlApplicationBridge setShouldUseBuiltInNotifications: [[Preferences defaultPreferences] showNoti]];
	
	// Set up bar item
	controlItem = [bar statusItemWithLength:NSVariableStatusItemLength];
	[controlItem retain];
	[controlItem setView: controlView];
	[controlItem setMenu: contextMenu];
    
    // Growl 
    
    [GrowlApplicationBridge setGrowlDelegate:self];

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	// ---- Finalization ----
	
	[[NSStatusBar systemStatusBar] removeStatusItem: controlItem];
	[[SkinManager defaultManager] release];
	[_iTControl release];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSString *extension = [filename pathExtension];
	
	// Load Skin Files
	if ([extension caseInsensitiveCompare:@"bcskin"] == NSOrderedSame)
	{
		[[SkinManager defaultManager] addSkin: filename setDefault: YES];
		//[controlView loadFromBundle: [[SkinManager defaultManager] defaultSkin]];
		return YES;
	}
	
	return NO;
}

- (BOOL)application:(NSApplication *)sender openFileWithoutUI:(NSString *)filename
{
	// Note: Dunno if we need this.. But perhaps?
	return [self application:sender openFile:filename];
}


- (void)orderFrontHelpPanel:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile: [[NSBundle mainBundle] pathForResource:@"readme" ofType:@"rtfd"]];
}

#pragma mark -


- (void)showGrowlNotification
{

    if ([_iTControl playerState] == ITPlaying) {
//        NSString *note = ((_previousState == ITStopped) || (_previousState == ITPaused)) ? @"Started Playing" : @"Changed Tracks";
        NSString *note = @"Changed Tracks";
        NSDictionary *noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  note, GROWL_NOTIFICATION_NAME,
                                  APP_NAME,                     GROWL_APP_NAME,
                                  [_iTControl growlTitle],                    GROWL_NOTIFICATION_TITLE,
                                  [_iTControl growlDescription],                  GROWL_NOTIFICATION_DESCRIPTION,
                                  APP_NAME,                     GROWL_NOTIFICATION_IDENTIFIER,
                                  [_iTControl artworkData],			  GROWL_NOTIFICATION_ICON_DATA,
                                  nil];
        [GrowlApplicationBridge notifyWithDictionary:noteDict];
    }
}

- (NSDictionary *) registrationDictionaryForGrowl
{
	NSArray *nameArray = [NSArray arrayWithObjects: @"Changed Tracks", @"Started Playing", nil];
	return [NSDictionary dictionaryWithObjectsAndKeys:
            APP_NAME,       GROWL_APP_NAME,
            nameArray,		GROWL_NOTIFICATIONS_ALL,
            nameArray,		GROWL_NOTIFICATIONS_DEFAULT,
            nil];
}

- (NSString *) applicationNameForGrowl {
	return APP_NAME;
}

@end
