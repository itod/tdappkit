//
//  TDPreferenceWindowController.h
//  Blitz
//
//  Created by Todd Ditchendorf on 3/4/18.
//  Copyright © 2018 Celestial Teapot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPreferenceWindowController : NSWindowController <NSToolbarDelegate>

+ (instancetype)instance;

@property (nonatomic, retain) IBOutlet NSView *containerView;
@end
