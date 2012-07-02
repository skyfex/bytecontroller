/*
 
 shared.m		Copyright © 2004 Audun Wilhelmsen
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

#import "shared.h"

@implementation BBTools

+ (NSString *)pathForImageResource:(NSString *)name inDirectory:(NSString *)dir
{
	NSArray *imageTypesArray = [NSImage imageUnfilteredFileTypes];
	NSEnumerator *imageTypes;
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dir];
	NSString *file;
	NSString *imageType;
	
	while (file = [dirEnum nextObject])
	{
		if ([[file stringByDeletingPathExtension] isEqualToString: name])
		{
			imageTypes = [imageTypesArray objectEnumerator];
			while (imageType = [imageTypes nextObject])
			{
				if ([[file pathExtension] caseInsensitiveCompare: imageType] == NSOrderedSame)
					return [dir stringByAppendingPathComponent: file];
			}	
		}
		
	}
	return nil;
}

+ (NSString *)pathForImageResource:(NSString *)name inBundle:(NSString *)dir
{
	// Check both ./Resources/ and ./ and ./Contents/Resources/
	NSString *returnValue = [self pathForImageResource: name inDirectory: [dir stringByAppendingPathComponent:@"Resources"]];
	if (returnValue)
		return returnValue;
	returnValue = [self pathForImageResource: name inDirectory: dir];
	if (returnValue)
		return returnValue;
	returnValue = [self pathForImageResource: name inDirectory: [dir stringByAppendingPathComponent:@"Contents/Resources"]];
	return returnValue;
}


+ (BOOL)createDirectoryTree:(NSString *)aPath
{
	NSFileManager *fileMan = [NSFileManager defaultManager];
	NSEnumerator *pathEnumerator = [[aPath pathComponents] objectEnumerator];
	NSString *pathComponent;
	NSString *fullPath = [NSString string];
	BOOL isDirectory;
	BOOL fileExists;
	
	while (pathComponent = [pathEnumerator nextObject])
	{
		fullPath = [fullPath stringByAppendingPathComponent: pathComponent];
		fileExists = [fileMan fileExistsAtPath: fullPath isDirectory: &isDirectory];
		if (!fileExists && isDirectory)
		{
			if (![fileMan createDirectoryAtPath: fullPath attributes: nil])
				return NO;
		}
	}
	return YES;
}

@end