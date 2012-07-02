//
//  SkinManager.m
//  ByteController
//
//  Created by Audun Wilhelmsen on Thu Jul 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "SkinManager.h"

@implementation SkinCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	//NSPoint origin = cellFrame.origin;

	NSString *skinName = [_skin name];
	NSColor *nameColor = [NSColor colorWithCalibratedWhite:0.6 alpha:1.0];
	if ([self state] == NSOnState)
		nameColor = [NSColor whiteColor];
	NSDictionary *drawAttributes =
		[NSDictionary dictionaryWithObjectsAndKeys: nameColor, NSForegroundColorAttributeName,
													[NSFont systemFontOfSize: 10], NSFontAttributeName,
													nil];
	NSSize nameDrawSize = [skinName sizeWithAttributes: drawAttributes];
	
	float combinedWidth =   [[_skin previousImage] size].width +
							[[_skin playImage] size].width +
							[[_skin nextImage] size].width;
	//float skinHeight = [[_skin playImage] size].height;
	//float currentPos;
	
	
	if ([self state] == NSOnState)
	{
		[[NSColor alternateSelectedControlColor]  set];
		NSRectFill(cellFrame);
	}
	
	NSPoint imagePos;
	NSPoint textPos;
	
	imagePos.x = cellFrame.origin.x + cellFrame.size.width/2 - combinedWidth/2;
	imagePos.y = cellFrame.origin.y + cellFrame.size.height/2 + 2;
	
	textPos.x = cellFrame.origin.x + cellFrame.size.width/2 - nameDrawSize.width/2;
	textPos.y = cellFrame.origin.y + (cellFrame.size.height/2 - nameDrawSize.height/2) + 14;
	
	[skinName drawAtPoint: textPos withAttributes: drawAttributes];
	
	if ([self state] == NSOffState)
	{
		[[_skin previousImage] compositeToPoint:imagePos operation:NSCompositeSourceOver];
		imagePos.x += [[_skin previousImage] size].width;
		[[_skin playImage] compositeToPoint:imagePos operation:NSCompositeSourceOver];
		imagePos.x += [[_skin playImage] size].width;
		[[_skin nextImage] compositeToPoint:imagePos operation:NSCompositeSourceOver];
		imagePos.x += [[_skin nextImage] size].width;
	}
	else
	{
		[[_skin previousImageDown] compositeToPoint:imagePos operation:NSCompositeSourceOver];
		imagePos.x += [[_skin previousImageDown] size].width;
		[[_skin playImageDown] compositeToPoint:imagePos operation:NSCompositeSourceOver];
		imagePos.x += [[_skin playImageDown] size].width;
		[[_skin nextImageDown] compositeToPoint:imagePos operation:NSCompositeSourceOver];
		imagePos.x += [[_skin nextImageDown] size].width;
	}
}

#pragma mark -

- (void)setSkin:(Skin *)aSkin
{
	Skin *oldSkin = _skin;
	_skin = [aSkin retain];
	[oldSkin release];
}

- (Skin *)skin
{
	return _skin;
}

@end



@implementation SkinControl

- (void)setSkin:(Skin *)aSkin
{
	[[self cell] setSkin: aSkin];
}

- (Skin *)skin
{
	return [[self cell] skin];
}

#pragma mark -

- (BOOL)acceptsFirstResponder {
    return YES;		// Use me with the keyboard....
}

- (BOOL)needsPanelToBecomeKey {
    return NO;		// Clicking doesn't make us key, but tabbing to us will...
}

@end

static SkinManager *_defaultSkinManager = nil;

@implementation SkinManager

+ (SkinManager *)defaultManager
{
	return _defaultSkinManager ? _defaultSkinManager : [[SkinManager alloc] init];
}

#pragma mark -

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
	[super dealloc];
}

#pragma mark -

- (BOOL)skinIsValid:(NSString *)aSkinBundle
{
	return YES;
}
- (BOOL)skinExists:(NSString *)aSkinBundle
{
	return [[NSFileManager defaultManager] fileExistsAtPath: aSkinBundle];
	//return [self skinIsValid: aSkinBundle];
}

- (void)setDefaultSkinPath:(NSString *)aSkinBundle
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: aSkinBundle forKey: @"DefaultSkin"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BCDefaultSkinChanged" object: [Skin skinWithPath: aSkinBundle]];
}

- (void)setDefaultSkin:(Skin *)aSkin
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject: [aSkin path] forKey: @"DefaultSkin"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BCDefaultSkinChanged" object: aSkin];
}

- (NSString *)defaultSkin
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *defaultSkin = [userDefaults objectForKey: @"DefaultSkin"];
	if (!defaultSkin || [defaultSkin isEqual: @""] || ![self skinExists: defaultSkin])
		defaultSkin = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"skins/Default.bcskin"];

	return defaultSkin;
}   
 
- (BOOL)addSkin:(NSString *)aSkinBundle setDefault:(BOOL)aDefault
{
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSString *sourcePath = [aSkinBundle stringByExpandingTildeInPath];
	
	// TODO: return false if Skin is invalid
	
	NSString *fileName =  [aSkinBundle lastPathComponent];
	
	// [BCSkinPath => expand tile] + filename
	NSString *destinationPath = [[BCSkinPath stringByExpandingTildeInPath] stringByAppendingPathComponent: fileName];
	
	// Make sure destination directory exists
	if (![BBTools createDirectoryTree: [BCSkinPath stringByExpandingTildeInPath]])
	{
		// Creating Directory tree failed
		NSRunAlertPanel(@"Failed to install skin.", 
						@"ByteController was unable to create the directory needed to install the skin. Try checking your permissions.",
						@"OK", nil, nil);
		return NO;
	}
	
	// Check for previously installed skins
	if ([fileMan fileExistsAtPath: destinationPath])
	{
		int dialogResult = NSRunAlertPanel(@"A skin with this filename already exists.", 
										   @"You can replace the previously installed skin, or rename the new skin.",
										   @"Replace", @"Rename", @"Cancel");
		
		// Perform the right action.
		switch (dialogResult)
		{
			case NSAlertDefaultReturn: 				// Replace the old skin:
			{
				if (![fileMan removeFileAtPath: destinationPath handler: nil])
				{
					NSRunAlertPanel(@"Failed to install skin.", 
									@"ByteController could not replace the previously installed skin. Try checking your permissions.",
									@"OK", nil, nil);
					return NO;
				}
				break;
			}
			case NSAlertAlternateReturn:				// Find a new name:
			{
				NSString *newPath = destinationPath;
				while ([fileMan fileExistsAtPath: newPath])
				{
					newPath = [NSString stringWithFormat: @"%@x.%@", [newPath stringByDeletingPathExtension], [newPath pathExtension]];
				}
				destinationPath = newPath;
				NSLog(@"New Path: %@", destinationPath);
				break;
			}
			default:
			case NSAlertOtherReturn:			// Cancel
				return NO;
		}
	}
	
	// Copy the skin bundle
	if (![fileMan copyPath: sourcePath 
					toPath: destinationPath 
				   handler: nil])
	{
		NSRunAlertPanel(@"Failed to install skin.", 
						@"Failed to copy the skin file. Check your permissions.",
						@"OK", nil, nil);
		return NO;
	}
	
	if (aDefault)
		[self setDefaultSkinPath: destinationPath];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BCSkinListWasUpdated" object:self];
	return YES;
}

- (void)removeSkin:(NSString *)aSkinBundle
{
	if ([aSkinBundle hasPrefix: [[NSBundle mainBundle] bundlePath]])
	{	
		NSRunAlertPanel(@"Cannot delete skin.",
						@"The skin you selected is a pre-installed skin, and cannot be deleted.",
						@"OK", nil, nil);
		return;
	}
	[[NSFileManager defaultManager] removeFileAtPath: aSkinBundle handler: nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"BCSkinListWasUpdated" object:self];
}

// -- Nested Functions has been depracted. Quick hack to un-nest this function --
void appendFilesInDirectory(NSMutableArray *skinList, NSString *currentDir, NSDirectoryEnumerator *dir)
{
    NSString *file;

    [dir skipDescendents];
    while (file = [dir nextObject])
    {
        if ([[file pathExtension] caseInsensitiveCompare: @"bcskin"] == NSOrderedSame)
            [skinList addObject: [currentDir stringByAppendingPathComponent: file]];
    }
}

- (NSArray *)skinList
{
	NSMutableArray *skinList = [[[NSMutableArray alloc] init] autorelease];
	NSString *currentDir;
	
	currentDir = [BCSkinPath stringByExpandingTildeInPath];
	appendFilesInDirectory(skinList, currentDir, [[NSFileManager defaultManager] enumeratorAtPath: currentDir]);
	currentDir = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"skins"];
	appendFilesInDirectory(skinList, currentDir, [[NSFileManager defaultManager] enumeratorAtPath: currentDir]);
	
	return skinList;
}

@end
