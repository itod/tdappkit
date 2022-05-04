//
//  TDRegisterWindowController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/30/11.
//  Copyright 2011 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDRegisterWindowController.h>
#import <TDAppKit/TDHintButton.h>
#import <TDAppKit/TDUtils.h>

@interface NSObject ()
- (BOOL)registerWithLicenseAtPath:(NSString *)path;
@end

@interface TDRegisterWindowController ()
- (void)setUpTitle;
- (void)setUpHint;
- (void)handleLicenseFilePath:(NSString *)filePath;
@end

@implementation TDRegisterWindowController

- (instancetype)initWithAppName:(NSString *)s licenseFileExtension:(NSString *)ext {
    self = [super initWithWindowNibName:@"TDRegisterWindow"];
    if (self) {
        self.appName = s;

        NSMutableSet *set = [NSMutableSet setWithObject:ext];
        [set addObject:@"xml"];
        [set addObject:@"plist"];
        
        self.licenseFileExtensions = [set allObjects];
    }
    return self;
}


- (void)dealloc {
    self.hintButton = nil;
    self.dropTargetView = nil;
    self.appName = nil;
    self.licenseFileExtensions = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark NSWindowController

- (void)awakeFromNib {
    TDAssert(_dropTargetView);
    [[self window] center];
    
    NSArray *types = [NSArray arrayWithObject:NSPasteboardTypeFileURL];
    [_dropTargetView registerForDraggedTypes:types];
    
    [self setUpTitle];
    [self setUpHint];
}


#pragma mark -
#pragma mark

- (IBAction)browse:(id)sender {
    TDAssertMainThread();
    TDAssert([_licenseFileExtensions count]);
    
	NSOpenPanel *panel = [NSOpenPanel openPanel];
    
    [panel setAllowedFileTypes:_licenseFileExtensions];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result) {
        if (NSModalResponseOK == result) {
            NSString *filePath = [[panel URL] relativePath];
            
            [self handleLicenseFilePath:filePath];
        }
    }];
}


#pragma mark -
#pragma mark NSDragginDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)dragInfo {
    TDAssert([_licenseFileExtensions count]);
    
    NSPasteboard *pboard = [dragInfo draggingPasteboard];
    NSDragOperation mask = [dragInfo draggingSourceOperationMask];
    
    if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
        if (mask & NSDragOperationGeneric) {
            NSString *filePath = [[NSURL URLFromPasteboard:pboard] path];
            if ([_licenseFileExtensions containsObject:[filePath pathExtension]]) {
                return NSDragOperationCopy;
            }
        }
    }
    
    return NSDragOperationNone;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)dragInfo {
    NSPasteboard *pboard = [dragInfo draggingPasteboard];
    
    if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
        NSString *filePath = [[NSURL URLFromPasteboard:pboard] path];
        [self handleLicenseFilePath:filePath];
        return YES;
    } else {
        return NO;
    }
}


#pragma mark -
#pragma mark Private

- (void)setUpTitle {
    TDAssert([_appName length]);
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Register %@", @""), _appName];
    [[self window] setTitle:title];
}


- (void)setUpHint {
    TDAssert(_hintButton);
    
    NSString *hint = [NSString stringWithFormat:NSLocalizedString(@"Drag your %@ license file here.", @""), _appName];
    _hintButton.hintText = hint;
    
    [_hintButton setNeedsDisplay:YES];
}


- (void)handleLicenseFilePath:(NSString *)filePath {
    if (![filePath length]) return;
        
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        if ([_licenseFileExtensions containsObject:[filePath pathExtension]]) {
            id target = NSApp;
            if (![target respondsToSelector:@selector(registerWithLicenseAtPath:)]) {
                target = [NSApp delegate];
            }
            if (target && [target respondsToSelector:@selector(registerWithLicenseAtPath:)]) {
                [target registerWithLicenseAtPath:filePath];
            } else {
                TDAssert(0);
            }
        }
    });
}

@end
