/*
 
 ITControl.m		Copyright ¬© 2004 Audun Wilhelmsen
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

#import "ITControl.h"


@implementation ITControl

#pragma mark -

- (void)playerDidChangeState:(ITState)aState
{
	if ([_delegate respondsToSelector:@selector(playerDidChangeState:)])
		[_delegate playerDidChangeState:aState];
}

- (void)playerWasLaunched
{
	if ([_delegate respondsToSelector:@selector(playerWasLaunched)])
		[_delegate playerWasLaunched];
}
- (void)playerWasTerminated
{
	if ([_delegate respondsToSelector:@selector(playerWasTerminated)])
		[_delegate playerWasTerminated];
}

- (void)checkForStateChange
{
    
	ITState oldState = _previousState =  _currentState;
	ITState newState = [self playerState];
	
	if (newState != oldState)
	{
		[self playerDidChangeState: newState];
	}
}

- (void)checkLaunchState
{
	NSArray *launchedApps = [[NSWorkspace sharedWorkspace] runningApplications];
	NSEnumerator *appEnumerator = [launchedApps objectEnumerator];
	NSRunningApplication *application;
	BOOL newState = NO;

	while (application = [appEnumerator nextObject])
	{
        if ([application bundleIdentifier])
		if ([[application bundleIdentifier] caseInsensitiveCompare: bundleIdentifier] == NSOrderedSame) {
			newState = YES;
        }
	}
	
	_isLaunched = newState;
}

#pragma mark -

- (void)VLCpoll: (id)data
{
    [self checkForStateChange];
}

- (void)SpotifyPlayerInfo: (NSNotification *)aNotification
{
    _previousState = _currentState;
    NSDictionary *userInfo = [aNotification userInfo];
//    NSEnumerator *e = [userInfo keyEnumerator];
//    NSString *s;
//    while (s = [e nextObject]) {
//        NSLog(s);
//    }
    NSString *state = [userInfo valueForKey: @"Player State"];
    
    // TODO: Use proporties
    trackName = [userInfo valueForKey: @"Name"];
    albumName = [userInfo valueForKey: @"Album"];
    artistName = [userInfo valueForKey: @"Artist"];
    genre = @"";
    rating = 0;
    trackLength = [[userInfo valueForKey: @"Duration"] floatValue]*1000;
    
    if ([state caseInsensitiveCompare: @"Playing"] == NSOrderedSame) {
        _currentState = ITPlaying;
    }
    else if ([state caseInsensitiveCompare: @"Paused"] == NSOrderedSame) {
        _currentState = ITPaused;
    }
    else if ([state caseInsensitiveCompare: @"Stopped"] == NSOrderedSame) {
        _currentState = ITStopped;
    }
    
//    [self showGrowlNotification];
    
    [self playerDidChangeState: _currentState];
}
- (void)iTunesPlayerInfo: (NSNotification *)aNotification
{
    _previousState = _currentState;
	NSDictionary *userInfo = [aNotification userInfo];
	NSString *state = [userInfo valueForKey: @"Player State"];
	
    // TODO: These should be retained!
    trackName = [userInfo valueForKey: @"Name"];
    albumName = [userInfo valueForKey: @"Album"];
    artistName = [userInfo valueForKey: @"Artist"];
    artistName = [userInfo valueForKey: @"Genre"];
    trackLength = [[userInfo valueForKey: @"Total Time"] floatValue];
    rating = [[userInfo valueForKey: @"Rating"] intValue];
    
    if ([state caseInsensitiveCompare: @"Playing"] == NSOrderedSame) {
        _currentState = ITPlaying;
    }
    else if ([state caseInsensitiveCompare: @"Paused"] == NSOrderedSame) {
        _currentState = ITPaused;
    }
    else if ([state caseInsensitiveCompare: @"Stopped"] == NSOrderedSame) {
        _currentState = ITStopped;
    }
    
	
    NSString *newTrackURL;
    if ([userInfo objectForKey:@"Location"]) {
        newTrackURL = [userInfo objectForKey:@"Location"];
    } 
    else if ([userInfo objectForKey:@"Store URL"]) {
        newTrackURL = [userInfo objectForKey:@"Store URL"];
    }
    NSString *streamTitle = [userInfo objectForKey:@"Stream Title"];
    if(!streamTitle) streamTitle = @"";
		
    [[self delegate] showGrowlNotification];

	[self playerDidChangeState: _currentState];
}

- (void)workspaceWillLaunchApplication:(NSNotification *)aNotification
{
	BOOL oldState = _isLaunched;
	[self checkLaunchState];
	if (oldState != _isLaunched)
	{
		if (_isLaunched)
			[self playerWasLaunched];
	}
}

- (void)workspaceDidTerminateApplication:(NSNotification *)aNotification
{
	BOOL oldState = _isLaunched;
	[self checkLaunchState];
	if (oldState != _isLaunched)
	{
		if (!_isLaunched)
			[self playerWasTerminated];
	}
}



#pragma mark -

- (id)init
{
    return [self initWithType: ITDefault];
}

- (id)initWithType: (ITType)type
{        
	self = [super init];
	if (self)
	{
        _currentState = ITStopped;
        _previousState = ITStopped;
        pollTimer = nil;
        
        NSString *resourcePath = [NSString stringWithString: [[NSBundle mainBundle] resourcePath]];
        if (type==ITSpotify) {
            resourcePath = [resourcePath stringByAppendingPathComponent: @"scripts/spotify"];
            [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                                selector: @selector(SpotifyPlayerInfo:)
                                                                    name: @"com.spotify.client.PlaybackStateChanged"
                                                                  object: nil];
            bundleIdentifier = @"com.spotify.client";
        }
        else if (type==ITVLC) {
            resourcePath = [resourcePath stringByAppendingPathComponent: @"scripts/vlc"];
            pollTimer = [NSTimer scheduledTimerWithTimeInterval: 1 
                                                         target: self
                                                       selector: @selector(VLCpoll:)
                                                       userInfo: nil
                                                        repeats: YES];
            bundleIdentifier = @"org.videolan.vlc";            
        }
        else {
            resourcePath = [resourcePath stringByAppendingPathComponent: @"scripts/itunes"];
            [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                                selector: @selector(iTunesPlayerInfo:)
                                                                    name: @"com.apple.iTunes.playerInfo"
                                                                  object: nil];
            bundleIdentifier = @"com.apple.iTunes";
        }
        
        // -- Load all scripts --
		playpauseScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"playpause.scpt"]] error:nil];
		playerStateScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"playerstate.scpt"]] error:nil];
		nextScript		= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"next.scpt"]] error:nil];
		previousScript  = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"previous.scpt"]] error:nil];
		ffScript		= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"fastforward.scpt"]] error:nil];
		rewindScript	= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"rewind.scpt"]] error:nil];
		resumeScript	= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"resume.scpt"]] error:nil];
		volumeUpScript	= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"volumeup.scpt"]] error:nil];
		volumeDownScript	= [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"volumedown.scpt"]] error:nil];
		artworkScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[resourcePath stringByAppendingPathComponent:@"artwork.scpt"]] error:nil];
        
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
															   selector: @selector(workspaceWillLaunchApplication:)
																   name: @"NSWorkspaceWillLaunchApplicationNotification"
																 object: nil];
		
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
															   selector: @selector(workspaceDidTerminateApplication:)
																   name: @"NSWorkspaceDidTerminateApplicationNotification"
																 object: nil];
		
	}
	return self;    
}

- (void)dealloc
{
    if (pollTimer)
        [pollTimer invalidate];
	[playpauseScript release];
	[nextScript release];
	[previousScript release];
	[playerStateScript release];
	[ffScript release];
	[rewindScript release];
	[resumeScript release];
	[volumeUpScript release];
	[volumeDownScript release];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver: self 
                                                                  name:@"NSWorkspaceWillLaunchApplicationNotification" 
                                                                object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver: self 
                                                                  name:@"NSWorkspaceDidTerminateApplicationNotification" 
                                                                object:nil];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver: self 
                                                               name:@"com.apple.iTunes.playerInfo" 
                                                             object:nil];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver: self 
                                                               name:@"com.spotify.client.PlaybackStateChanged" 
                                                             object:nil];
	[super dealloc];
}

#pragma mark -

- (void)setDelegate:(id)aDelegate
{
	_delegate = aDelegate;
}
- (id)delegate
{
	return _delegate;
}

#pragma mark -

- (NSData*)artworkData
{
	//return [[[NSImage alloc] initWithData: [[artworkScript executeAndReturnError: nil] data]] autorelease];
	return [[artworkScript executeAndReturnError: nil] data];
}

- (ITState)playerState;
{
	_currentState =  [[playerStateScript executeAndReturnError:nil] int32Value];
	return _currentState;
}

- (BOOL)isLaunched
{
	[self checkLaunchState];
	return _isLaunched;
}

- (void)play
{
	// TODO: Fix
//	[playpauseScript executeAndReturnError:nil];
}

- (void)pause
{
	// TODO: Fix
//	[playpauseScript executeAndReturnError:nil];
}

- (void)togglePlay
{
	[playpauseScript executeAndReturnError:nil];
}

- (void)playNext
{
	[nextScript executeAndReturnError:nil];
//	[self checkForStateChange];
}

- (void)playPrevious
{
	[previousScript executeAndReturnError:nil];
	//[self checkForStateChange];
}

- (void)fastForward
{
	[ffScript executeAndReturnError:nil];
	//[self checkForStateChange];
}

- (void)rewind;
{
	[rewindScript executeAndReturnError:nil];
	//[self checkForStateChange];
}

- (void)resume
{
	[resumeScript executeAndReturnError:nil];
	//[self checkForStateChange];
}

- (void)increaseVolume
{
	[volumeUpScript executeAndReturnError:nil];
}

- (void)decreaseVolume
{
	[volumeDownScript executeAndReturnError:nil];
}

#pragma mark -

- (NSString*)growlTitle
{
    return trackName;
}

- (NSString*)growlDescription
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *template = [userDefaults valueForKey:	@"NotifyTemplate"];
	if (template == nil) template = @"[[artist]]\n[[album]]\n[[length]]\n[[rating]]";
    

    // -- Get Seconds/Minutes for Track Length --
    int seconds = (int)floorf(trackLength/1000) % 60;
    int minutes = (int)floorf(trackLength/60000);
    NSString *length = [NSString stringWithFormat: @"%.2i:%.2i", minutes, seconds];

    // -- Make Rating String --
    NSString *ratingString = @"";
    if (rating >= 20)
    ratingString = @"☆";
    if (rating >= 40)
    ratingString = @"☆☆";
    if (rating >= 60)
    ratingString = @"☆☆☆";
    if (rating >= 80)
    ratingString = @"☆☆☆☆";
    if (rating >= 100)
    ratingString = @"☆☆☆☆☆";

    // -- Make Description --

    if (artistName == nil) artistName = @"";
    if (albumName == nil) albumName = @"";
    if (genre == nil) genre = @"";

    NSMutableString *description = [template mutableCopy];
    [description replaceOccurrencesOfString: @"[[artist]]" withString: artistName 
                                   options: NSCaseInsensitiveSearch range: NSMakeRange(0, [description length])];
    [description replaceOccurrencesOfString: @"[[album]]" withString: albumName 
                                   options: NSCaseInsensitiveSearch range: NSMakeRange(0, [description length])];
    [description replaceOccurrencesOfString: @"[[length]]" withString: length 
                                   options: NSCaseInsensitiveSearch range: NSMakeRange(0, [description length])];
    [description replaceOccurrencesOfString: @"[[rating]]" withString: ratingString 
                                   options: NSCaseInsensitiveSearch range: NSMakeRange(0, [description length])];
    [description replaceOccurrencesOfString: @"[[genre]]" withString: genre 
                                   options: NSCaseInsensitiveSearch range: NSMakeRange(0, [description length])];
    [description replaceOccurrencesOfString: @"\\n" withString: @"\n" 
                                   options: NSCaseInsensitiveSearch range: NSMakeRange(0, [description length])];
    
    return description;

}

@end
