//
//  Skin.m
//  ByteController
//
//  Created by Audun Wilhelmsen on Sat Jul 10 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "Skin.h"


@implementation Skin

- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}

- (void)dealloc
{
	[_name release];
	[_author release];
	[_copyrightText release];
	[_created release];
	[_description release];
	[_note release];
	[_path release];
	
	[playImage release];
	[pauseImage release];
	[nextImage release];
	[previousImage release];
	[playImageDown release];
	[pauseImageDown release];
	[nextImageDown release];
	[previousImageDown release];
	[super dealloc];
}

#pragma mark -

+ (Skin *)skinWithPath:(NSString *)aBundlePath
{
	Skin *newSkin = [[[Skin alloc] init] autorelease];
	[newSkin loadFromBundle: aBundlePath];
	return newSkin;
}

- (void)loadFromBundle:(NSString *)aBundlePath
{
	NSDictionary *infoList = [NSDictionary dictionaryWithContentsOfFile: [aBundlePath stringByAppendingPathComponent: @"info.plist"]];
	
	_path = [aBundlePath retain];
	
	_name = [[infoList objectForKey: @"Name"] retain];
	_author = [[infoList objectForKey: @"Author"] retain];
	_copyrightText = [[infoList objectForKey: @"CopyrightText"] retain];
	_description = [[infoList objectForKey: @"Description"] retain];
	_note = [[infoList objectForKey: @"Notes"] retain];
	_created = [[infoList objectForKey: @"Created"] retain];

	
	playImage			= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"play" inBundle: aBundlePath]];
	pauseImage			= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"pause" inBundle: aBundlePath]];
	nextImage			= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"next" inBundle: aBundlePath]];
	previousImage		= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"previous" inBundle: aBundlePath]];
	playImageDown		= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"playDown" inBundle: aBundlePath]];
	pauseImageDown		= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"pauseDown" inBundle: aBundlePath]];
	nextImageDown		= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"nextDown" inBundle: aBundlePath]];
	previousImageDown	= [[NSImage alloc] initWithContentsOfFile: [BBTools pathForImageResource:@"previousDown" inBundle: aBundlePath]];
}

- (NSString *)path {
	return _path;
}

- (NSString *) name {
	if (_name) return _name;
	else return [NSString string];
}
- (NSString *) author {
	if (_author) return _author;
	else return [NSString string];
}
- (NSString *) copyrightText {
	if (_copyrightText) return _copyrightText;
	else return [NSString string];
}
- (NSDate *)   created {
	if (_created) return _created;
	else return [NSString string];
}
- (NSString *) note {
	if (_note) return _note;
	else return [NSString string];
}
- (NSString *) description{
	if (_description) return _description;
	else return [NSString string];
}

- (NSImage *)playImage				{ return playImage; }
- (NSImage *)pauseImage				{ return pauseImage; }
- (NSImage *)nextImage				{ return nextImage; }
- (NSImage *)previousImage			{ return previousImage; }

- (NSImage *)playImageDown			{ return playImageDown; }
- (NSImage *)pauseImageDown			{ return pauseImageDown; }
- (NSImage *)nextImageDown			{ return nextImageDown; }
- (NSImage *)previousImageDown		{ return previousImageDown; }

@end
