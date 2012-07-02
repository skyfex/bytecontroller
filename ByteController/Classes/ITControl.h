/*
 
 ITControl.h		Copyright © 2004 Audun Wilhelmsen
 ---------------------------------------------------------------
 Class for handling control of iTunes. Reports status changes
 to delegate.
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

#import <Foundation/Foundation.h>
#import <Growl/GrowlApplicationBridge.h>

typedef enum
{
    ITDefault = 0,
    ITSpotify = 1,
    ITVLC = 2
} ITType;

typedef enum
{
	ITStopped = 0,
	ITPaused = 1,
	ITPlaying = 2,
	ITFastForwarding = 3,
	ITRewinding = 4
} ITState;

/*@interface ITTrack : NSObject
{
	NSString *_title;
	NSString *_artist;
	NSString *_album;
	NSString *_composer;
	NSString *_genre;
	
	NSData  *_artwork;
	
	int _dbID;
	int _track;
	int _disc;
	int _rating;
	int _duration;
	int _year;
	int _playcount;
	
	bool _compilation;
}

@end;*/

@interface ITControl : NSObject {
	id _delegate;
    ITType _type;
    NSString *bundleIdentifier;
	ITState _currentState;
    ITState _previousState;
	bool _isLaunched;
    
    NSTimer *pollTimer;
    
    // Don't trust these
    NSString *trackName ;
    NSString *albumName ;
    NSString *artistName;
    NSString *genre;
	float trackLength;
    int rating;
    
	NSAppleScript *playpauseScript;
	NSAppleScript *playerStateScript;
	NSAppleScript *nextScript;
	NSAppleScript *previousScript;
	NSAppleScript *ffScript;
	NSAppleScript *rewindScript;
	NSAppleScript *resumeScript;
	NSAppleScript *volumeUpScript;
	NSAppleScript *volumeDownScript;
	NSAppleScript *artworkScript;
}

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

#pragma mark -

- (id)initWithType: (ITType)type;

- (ITState)playerState;

- (BOOL)isLaunched;

- (NSData*)artworkData;

- (void)play;
- (void)pause;
- (void)togglePlay;

- (void)playNext;
- (void)playPrevious;

- (void)fastForward;
- (void)rewind;
- (void)resume;

- (void)increaseVolume;
- (void)decreaseVolume;


- (NSString*)growlDescription;
- (NSString*)growlTitle;


@end
