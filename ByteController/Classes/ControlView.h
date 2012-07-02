/*
 
 ControlView.h		Copyright © 2004 Audun Wilhelmsen
 ---------------------------------------------------------------
 Custom View. Handles drawing of the ByteController buttons. Also
 handles button actions.
 Note: I've done some weird stuff to get the timers working.
 Please e-mail if you clean it up. There is actually a lot of mess
 around the whole holding-button thing.
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
#import "Skin.h"
#import "shared.h"

@interface ControlView : NSView
{	
	NSTimeInterval mouseDownTime;
	int selectedControl;
	NSTimer *_holdTimer;
	ITControl *_iTControl;
	
	id _delegate;
	
	BOOL _wasHolding;
	BOOL _isPlaying;
	
	Skin *skin;
}

- (void)loadFromBundle: (NSString *)aSkinBundle;
- (void)setSkin:(Skin *)aSkin;
- (Skin *)skin;

- (void)setITControl:(ITControl *)aControl;
- (ITControl *)iTControl;

- (void)setDelegate:(id)aDelegate;
- (id)delegate;

- (void)setIsPlaying:(BOOL)aIsPlaying;

@end
