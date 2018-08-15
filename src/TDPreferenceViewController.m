//
//  TDPreferenceViewController.m
//  Blitz
//
//  Created by Todd Ditchendorf on 3/4/18.
//  Copyright © 2018 Celestial Teapot. All rights reserved.
//

#import "TDPreferenceViewController.h"

#import <TDAppKit/TDUtils.h>

@interface TDPreferenceViewController ()

@end

@implementation TDPreferenceViewController

- (instancetype)initWithModel:(TDPreferenceModel *)mod {
    self = [super init];
    if (self) {
        self.model = mod;
    }
    return self;
}


- (void)dealloc {
    self.model = nil;
    self.initialFirstResponder = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark NSViewController

- (void)viewDidLoad {
    TDAssertMainThread();
    [super viewDidLoad];

    TDPerformOnMainThreadAfterDelay(0.0, ^{
        TDAssert(self.view.window);
        
        if (self.initialFirstResponder) {
            [self.view.window makeFirstResponder:self.initialFirstResponder];
        }
    });
}

@end
