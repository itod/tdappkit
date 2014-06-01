//
//  TDRegisterWindowController.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/30/11.
//  Copyright 2011 Todd Ditchendorf. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TDHintButton;

@interface TDRegisterWindowController : NSWindowController

- (id)initWithAppName:(NSString *)s licenseFileExtension:(NSString *)ext;

- (IBAction)browse:(id)sender;

@property (nonatomic, retain) IBOutlet TDHintButton *hintButton;
@property (nonatomic, retain) IBOutlet NSView *dropTargetView;

@property (nonatomic, copy) NSString *appName;
@property (nonatomic, copy) NSArray *licenseFileExtensions;
@end
