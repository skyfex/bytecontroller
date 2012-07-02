/*
 
 Preferences.m		Copyright © 2004 Audun Wilhelmsen
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


#import "Preferences.h"
#import "Application.h"
#import <Growl/GrowlApplicationBridge.h>

@implementation Preferences

+ (Preferences *)defaultPreferences
{
	static Preferences *defaultPreferences;
	if (defaultPreferences == nil)
		defaultPreferences = [[Preferences alloc] init];
	return defaultPreferences;
}

#pragma mark -

- (void)setObject:(id)aObject forKey:(NSString *)aKey
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:aObject forKey:aKey];
	[userDefaults synchronize];
}

- (id)objectForKey:(NSString *)aKey
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	return [userDefaults objectForKey: aKey];
}

#pragma mark -

- (void)setAutoHide:(BOOL)aHide
{
	[self setObject: [NSNumber numberWithBool: aHide] forKey:@"AutoHide"];
}
- (BOOL)autoHide
{
	return [[self objectForKey: @"AutoHide"] boolValue];
}

#pragma mark -

- (void)setShowNoti:(BOOL)shouldShow
{
    [GrowlApplicationBridge setShouldUseBuiltInNotifications: shouldShow];
    [self setObject: [NSNumber numberWithBool: shouldShow] forKey:@"ShowNoti"];
}
- (BOOL)showNoti
{
 	return [[self objectForKey: @"ShowNoti"] boolValue];   
}

- (void)setPlayer:(int)thePlayer
{
	[self setObject: [NSNumber numberWithInt: thePlayer] forKey:@"Player"];    
    [[Application defaultApplication] updatePlayerControl];
}
- (int)player
{
 	return [[self objectForKey: @"Player"] intValue];   
}

#pragma mark -

- (NSDictionary *)itemWithAppPathIn:(NSArray *)items;
{
	// Return first occurance of my app path in "items"
	
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	
	NSEnumerator *e = [items objectEnumerator];
	NSDictionary *item;
	
	while (item = [e nextObject])
	{
		if ([[item objectForKey:@"Path"] isEqualToString: appPath])
			return item;
	}
	
	return nil;
}

- (BOOL)isInLoginItems
{
	NSDictionary *loginwindow = [[NSUserDefaults standardUserDefaults] persistentDomainForName: @"loginwindow"];;
	NSArray *loginItems;
	
	//  Load "AutoLaunchedApplicationDictionary" Array. Return NO if it doesn't exist.
	if (!(loginItems = [loginwindow objectForKey:@"AutoLaunchedApplicationDictionary"]))
		return NO;
	
	if ([self itemWithAppPathIn:loginItems])
		return YES;
	return NO;
}

- (void)removeFromLoginItems
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appItem;
	NSMutableDictionary *loginwindow = [[userDefaults persistentDomainForName: @"loginwindow"] mutableCopy];
	NSMutableArray *loginItems;
	
	if (!loginwindow)
		return;
	
	//  Load "AutoLaunchedApplicationDictionary" Array. Create if it doesn't exist.
	if (!(loginItems = [[loginwindow objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy]))
		return;
	
	// Remove any earlier version of me
	if ((appItem = [self itemWithAppPathIn: loginItems]))
		[loginItems removeObject:appItem];
	
	// Update user defaults
	[loginwindow setObject:loginItems forKey:@"AutoLaunchedApplicationDictionary"];
	[userDefaults removePersistentDomainForName:@"loginwindow"];
	[userDefaults setPersistentDomain:loginwindow forName:@"loginwindow"];
	[userDefaults synchronize];
	
	[loginItems release];
	[loginwindow release];
	
}

- (void)addToLoginItems:(BOOL)hide
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *appPath = [[NSBundle mainBundle] bundlePath];
	NSDictionary *appItem;
	NSMutableDictionary *loginwindow = [[userDefaults persistentDomainForName: @"loginwindow"] mutableCopy];
	NSMutableArray *loginItems;
	
	if (!loginwindow)
		loginwindow = [NSMutableDictionary dictionaryWithCapacity:1];
	
	//  Load "AutoLaunchedApplicationDictionary" Array. Create if it doesn't exist.
	if (!(loginItems = [[loginwindow objectForKey:@"AutoLaunchedApplicationDictionary"] mutableCopy]))
		loginItems = [NSMutableArray arrayWithCapacity:1];
	
	// Remove any earlier version of me
	if ((appItem = [self itemWithAppPathIn: loginItems]) != nil)
		[loginItems removeObject:appItem];
	
	// Build item
	appItem = [[NSDictionary alloc] initWithObjectsAndKeys: 
		[NSNumber numberWithBool:hide], @"Hide",
		appPath, @"Path", nil];
	
	// Add to \"AutoLaunchedApplicationDictionary\" Array
	[loginItems addObject: appItem];
	
	// Update dictionary and user defaults
	[loginwindow setObject:loginItems forKey:@"AutoLaunchedApplicationDictionary"];
	[userDefaults removePersistentDomainForName:@"loginwindow"];
	[userDefaults setPersistentDomain:loginwindow forName:@"loginwindow"];
	[userDefaults synchronize];
	
	[appItem release];
	[loginwindow release];
	[loginItems release];
}

@end
