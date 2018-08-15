//
//  TDPreferenceViewController.h
//  Blitz
//
//  Created by Todd Ditchendorf on 3/4/18.
//  Copyright © 2018 Celestial Teapot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDPreferenceModel;

@interface TDPreferenceViewController : NSViewController

- (instancetype)initWithModel:(TDPreferenceModel *)mod;

@property (nonatomic, retain) TDPreferenceModel *model;
@property (nonatomic, retain) IBOutlet NSResponder *initialFirstResponder;
@end
