//
//  SkinManager.h
//  ByteController
//
//  Created by Audun Wilhelmsen on Thu Jul 01 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Shared.h"
#import "Skin.h"
//#import "Application.h"

// TOODO: Don't hardcode this shit
#define BCSkinPath @"~/Library/Application Support/ByteController/Skins/"

@interface SkinCell : NSActionCell {
	Skin *_skin;
}

- (void)setSkin:(Skin *)aSkin;
- (Skin *)skin;

@end

@interface SkinControl : NSControl {
}

- (void)setSkin:(Skin *)aSkin;
- (Skin *)skin;

@end

@interface SkinManager : NSObject {

}

- (void)updateInfo;

+ (SkinManager *)defaultManager;

- (BOOL)skinIsValid:(NSString *)aSkinBundle;
- (BOOL)skinExists:(NSString *)aSkinBundle;

- (void)setDefaultSkinPath:(NSString *)aSkinBundle;
- (void)setDefaultSkin:(Skin *)aSkin;
- (NSString *)defaultSkin;

- (BOOL)addSkin:(NSString *)aSkinBundle setDefault:(BOOL)aDefault;
- (void)removeSkin:(NSString *)aSkinBundle;

- (NSArray *)skinList;

@end