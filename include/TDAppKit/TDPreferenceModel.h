//
//  TDPreferenceModel.h
//  Blitz
//
//  Created by Todd Ditchendorf on 3/4/18.
//  Copyright © 2018 Celestial Teapot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPreferenceModel : NSObject

+ (instancetype)fromPlist:(NSDictionary *)plist;
- (instancetype)initFromPlist:(NSDictionary *)plist;

- (NSImage *)iconImage;

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *className;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *shortTitle;
@property (nonatomic, retain) NSString *iconName;

@end
