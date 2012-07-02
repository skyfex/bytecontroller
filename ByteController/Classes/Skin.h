//
//  Skin.h
//  ByteController
//
//  Created by Audun Wilhelmsen on Sat Jul 10 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "shared.h"

@interface Skin : NSObject {
	NSString *_path;
	
	NSString *_name;
	NSString *_author;
	NSString *_copyrightText;
	NSDate *_created;
	NSString *_note;
	NSString *_description;
	
	NSImage *playImage;
	NSImage *pauseImage;
	NSImage *nextImage;
	NSImage *previousImage;
	
	NSImage *playImageDown;
	NSImage *pauseImageDown;
	NSImage *nextImageDown;
	NSImage *previousImageDown;
}

+ (Skin *)skinWithPath:(NSString *)aBundlePath;

- (void)loadFromBundle:(NSString *)aBundlePath;

- (NSString *) path;

- (NSString *) name;
- (NSString *) author;
- (NSString *) copyrightText;
- (NSDate *)   created;
- (NSString *) note;
- (NSString *) description;

- (NSImage *)playImage;
- (NSImage *)pauseImage;
- (NSImage *)nextImage;
- (NSImage *)previousImage;

- (NSImage *)playImageDown;
- (NSImage *)pauseImageDown;
- (NSImage *)nextImageDown;
- (NSImage *)previousImageDown;


@end
