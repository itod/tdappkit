//
//  TDPreferenceModel.m
//  Blitz
//
//  Created by Todd Ditchendorf on 3/4/18.
//  Copyright © 2018 Celestial Teapot. All rights reserved.
//

#import "TDPreferenceModel.h"

@interface TDPreferenceModel ()
@property (nonatomic, retain) NSImage *iconImage;
@end

@implementation TDPreferenceModel

+ (instancetype)fromPlist:(NSDictionary *)plist {
    return [[[self alloc] initFromPlist:plist] autorelease];
}


- (instancetype)initFromPlist:(NSDictionary *)plist {
    self = [super init];
    if (self) {
        self.identifier = [plist objectForKey:@"id"];
        TDAssert(_identifier);
        self.className = [plist objectForKey:@"className"];
        TDAssert(_className);

        // MUST LOAD CLASS BEFORE LOADING IMAGE
        {
            Class cls = NSClassFromString(_className);
            TDAssert(cls);
            [cls self];
            cls = Nil;
        }
        
        self.iconName = [plist objectForKey:@"iconName"];
        TDAssert(_className);

        self.title = [plist objectForKey:@"title"];
        TDAssert(_title);
        
        NSString *shortTitle = [plist objectForKey:@"shortTitle"];
        self.shortTitle = shortTitle ? shortTitle : _title;
        
        NSImage *img = [NSImage imageNamed:_iconName];
        TDAssert(img);
        self.iconImage = img;
    }
    return self;
}


- (instancetype)init {
    TDAssert(0);
    return nil;
}


- (void)dealloc {
    self.iconImage = nil;
    
    self.identifier = nil;
    self.className = nil;
    self.title = nil;
    self.shortTitle = nil;
    self.iconName = nil;

    [super dealloc];
}

@end
