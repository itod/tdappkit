//
//  TDTabbedDocumentController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedDocumentController.h>
#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDUtils.h>

@interface NSWindow ()
- (void)toggleFullScreen:(id)sender;
@end

@interface TDTabbedDocumentController ()
- (void)postLion_toggleFullScreen:(id)sender;
- (void)preLion_toggleFullScreen:(id)sender;
@end

@implementation TDTabbedDocumentController

- (Class)representedObjectClass {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return nil;
}


- (id)newRepresentedObject {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return nil;
}


#pragma mark -
#pragma mark Actions

- (IBAction)toggleFullScreen:(id)sender {
    if (TDIsLionOrLater()) {
        [self postLion_toggleFullScreen:sender];
    } else {
        [self preLion_toggleFullScreen:sender];
    }
}


- (void)postLion_toggleFullScreen:(id)sender {
    TDTabbedDocument *doc = [self frontDocument];
    if (!doc) {
        return;
    }
    NSWindow *win = [[[doc windowControllers] objectAtIndex:0] window];

    [win toggleFullScreen:nil];
}


- (void)preLion_toggleFullScreen:(id)sender {
    TDTabbedDocument *doc = [self frontDocument];
    if (!doc) {
        doc = [self openUntitledDocumentAndDisplay:YES error:nil];
    }
    NSWindow *win = [[[doc windowControllers] objectAtIndex:0] window];
    NSView *v = [win contentView];
    if ([v isInFullScreenMode]) {
        [self willExitFullScreenMode];
        [v exitFullScreenModeWithOptions:nil];
        [win makeKeyAndOrderFront:nil];
        fullScreen = NO;
        [self didExitFullScreenMode];
    } else {
        [self willEnterFullScreenMode];
        fullScreen = YES;
        NSDictionary *opts = [self fullScreenOptions];
        [v enterFullScreenMode:[win screen] withOptions:opts];
        [win orderOut:nil];
        [self didEnterFullScreenMode];
    }
}


- (IBAction)newTab:(id)sender {
    [self newDocument:sender];
}


- (id)frontDocument {
    // despite what the docs say, -currentDocument does not return a document if it is main but not key. dont trust it. :(
    //return (FUDocument *)[self currentDocument];
    
    for (NSWindow *win in [NSApp orderedWindows]) {
        NSDocument *doc = [self documentForWindow:win];
        if (doc && [doc isKindOfClass:[TDTabbedDocument class]]) {
            return doc;
        }
    }
    return nil;
}


- (BOOL)isFullScreen {
    return fullScreen;
}


- (NSDictionary *)fullScreenOptions {
    return nil;
}


- (void)willEnterFullScreenMode {

}


- (void)didEnterFullScreenMode {
    if (TDIsLionOrLater()) {
        fullScreen = YES;
    }
    
}


- (void)willExitFullScreenMode {
    
}

- (void)didExitFullScreenMode {
    if (TDIsLionOrLater()) {
        fullScreen = NO;
    }
    
    
}

@end
