/*
 
 ControlView.m		Copyright © 2004 Audun Wilhelmsen
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

#import "ControlView.h"

#import "Application.h"

@implementation ControlView

- (int)controlUnderPos:(NSPoint)pos
{
	float prevpos = 0;
	
	float nextpos = [[skin previousImage] size].width;
	if (pos.x > prevpos && pos.x < nextpos)
	{
		if (pos.y > 0 && pos.y < [[skin previousImage] size].height)
			return 0;
		else
			return -1;
	}
	prevpos = nextpos;
	
	nextpos += [[skin playImage] size].width;
	if (pos.x > prevpos && pos.x < nextpos)
	{
		if (pos.y > 0 && pos.y < [[skin playImage] size].height)
			return 1;
		else
			return -1;
	}
	prevpos = nextpos;
	
	nextpos += [[skin nextImage] size].width;
	if (pos.x > prevpos && pos.x < nextpos)
	{
		if (pos.y > 0 && pos.y < [[skin nextImage] size].height)
			return 2;
		else
			return -1;
	}
	prevpos = nextpos;	
	
	return -1;
}

#pragma mark -

- (void)sizeToSkin
{
	float combinedWidth =   [[skin previousImage] size].width +
		[[skin playImage] size].width +
		[[skin nextImage] size].width;
	float height = [[skin playImage] size].height;
	[self setFrame:NSMakeRect(0, 0, combinedWidth, height)];	
}

- (void)loadFromBundle: (NSString *)aSkinBundle
{	
	[self setSkin: [[Skin skinWithPath: aSkinBundle] retain]];
}

- (void)setSkin:(Skin *)aSkin
{
	Skin *oldSkin = skin;
	skin = [aSkin retain];
	[oldSkin release];
	[self sizeToSkin];
}
- (Skin *)skin
{
	return skin;
}

#pragma mark -

- (id)initWithFrame:(NSRect)frameRect
{	
	if ((self = [super initWithFrame:frameRect]) != nil) 
	{
		//Initialization Code
		selectedControl = -1;
	}
	return self;
}

- (void)dealloc
{	
	[super dealloc];
}

- (void)drawRect:(NSRect)rect
{
	float pos = 0;
	
#ifdef BB_DEBUG
	NSLog(@"[ControlView drawRect:%@] BEGIN", rect);
#endif
	
	[[[Application defaultApplication] controlItem] drawStatusBarBackgroundInRect: rect
																	withHighlight: NO];
	
	// Draw Previous Song Button
	if (selectedControl == 0)
		[[skin previousImageDown] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];
	else
		[[skin previousImage] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];
	pos += [[skin previousImage] size].width;
	
	// Draw Play or Pause Button
	if (_isPlaying)
	{
		if (selectedControl == 1)
			[[skin pauseImageDown] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];
		else
			[[skin pauseImage] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];
	}
	else
	{
		if (selectedControl == 1)
			[[skin playImageDown] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];
		else
			[[skin playImage] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];
	}
	pos += [[skin playImage] size].width;
	
	// Draw Next Song Button
	if (selectedControl == 2)
		[[skin nextImageDown] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];
	else
		[[skin nextImage] compositeToPoint:NSMakePoint(pos, 0) operation:NSCompositeSourceOver];


#ifdef BB_DEBUG
	NSLog(@"[ControlView drawRect:%@] END", rect);
#endif
}

#pragma mark -

- (void)setDelegate:(id)aDelegate
{
	id oldDelegate = _delegate;
	_delegate = [aDelegate retain];
	[oldDelegate release];
}

- (id)delegate
{
	return _delegate;
}

- (void)setITControl:(ITControl *)aControl
{
	_iTControl = aControl;
}

- (ITControl *)iTControl
{
	return _iTControl;
}

- (void)setIsPlaying:(BOOL)aIsPlaying
{
	_isPlaying = aIsPlaying;
	[self setNeedsDisplay: YES];
}

- (void)popupMenu
{
	if ([_delegate respondsToSelector: @selector(shouldPopupMenu:)])
		[_delegate performSelector: @selector(shouldPopupMenu:) withObject: self];
	
	selectedControl = -1;
	[self setNeedsDisplay:YES];
}

- (void)processHold
{
	_holdTimer = nil;
	_wasHolding = YES;
	if (selectedControl == 0)
		[_iTControl rewind];
	if (selectedControl == 1)
		[self popupMenu];
	if (selectedControl == 2)
		[_iTControl fastForward];
}

#pragma mark -

- (void)mouseUp:(NSEvent *)event
{
	int pressedControl = selectedControl;
	selectedControl = -1;
	
	[self setNeedsDisplay:YES];
	
	// Invalidate Timers
	if (_holdTimer != nil)
	{
		[_holdTimer invalidate];
		_holdTimer = nil;
	}
	
	if (_wasHolding)
	{
		[_iTControl resume];
	}
	else
	{
		// Normal Click
		switch (pressedControl)
		{
			case 0:
				[_iTControl playPrevious];
				break;
			case 1:
				[_iTControl togglePlay];
				break;
			case 2:
				[_iTControl playNext];
				break;
			default:
				return;
		}
	}
	_wasHolding = false;
}

- (void)mouseDown:(NSEvent *)event
{
	// Control click
	if ([event modifierFlags] & NSControlKeyMask)
	{
		[self popupMenu];
		return; // Don't need to do more
	}
	
	NSPoint pointInWindow = [event locationInWindow];
	NSPoint pointInView = [self convertPoint:pointInWindow fromView:nil];
	selectedControl = [self controlUnderPos:pointInView];
	
	// Start timer for context menu, if we pressed play/pause.
	_holdTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(processHold) userInfo:nil repeats:NO];
	
	// Update view, to display down state.
	[self setNeedsDisplay:YES];
	
	mouseDownTime = [event timestamp];
}

- (void)mouseDragged:(NSEvent *)event
{
	NSPoint pointInWindow = [event locationInWindow];
	NSPoint pointInView = [self convertPoint:pointInWindow fromView:nil];
	int newControl = [self controlUnderPos:pointInView];
	
	// If we dragged across buttons
	if (newControl != selectedControl)
	{
		if (_holdTimer != nil)
		{
			[_holdTimer invalidate];
			_holdTimer = nil;
		}
		if (_wasHolding)
			[_iTControl resume];
		selectedControl = newControl;
		[self setNeedsDisplay:YES];
	}
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
	[self popupMenu];
}

@end
