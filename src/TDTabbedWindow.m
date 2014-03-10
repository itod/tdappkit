//
//  TDTabbedWindow.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/12/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabbedWindow.h"
#import "TDTabbedDocument.h"
#import <TDAppKit/NSEvent+TDAdditions.h>

#define CLOSE_CURLY 30
#define OPEN_CURLY 33
#define LEFT_ARROW 123
#define RIGHT_ARROW 124

@interface TDTabbedWindow ()
- (BOOL)handleEvent:(NSEvent *)evt;
- (BOOL)handleGoToTabNumber:(NSEvent *)evt;
//- (BOOL)handleNextPrevTab:(NSEvent *)evt;
- (TDTabbedDocument *)tabbedDocument;
@end

@implementation TDTabbedWindow

- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    [super dealloc];
}


//- (IBAction)performClose:(id)sender {
//    [super performClose:sender];
////    [[[self windowController] document] performClose:sender];
//}
//
//
//- (void)close {
//    [[[self windowController] document] close];
//}

- (void)sendEvent:(NSEvent *)evt {
    if (![self handleEvent:evt]) {
        [super sendEvent:evt];
    }
}


// return YES if event is completely handled and should not be sent to super
- (BOOL)handleEvent:(NSEvent *)evt {
    BOOL handled = NO;
    
    if ([evt isKeyUpOrDown]) {
        // handle ⌘-1 for tabs
        if ([self handleGoToTabNumber:evt]) {
            handled = YES;
        }
        
//        // also handle ⌘-{, ⌘-} and ⎇⌘←, ⎇⌘→ tab switching
//        else if ([self handleNextPrevTab:evt]) {
//            handled = YES;
//        }
        
    }
    
    return handled;
}


- (BOOL)handleGoToTabNumber:(NSEvent *)evt {
    if ([evt isCommandKeyPressed]) {
        NSString *s = [evt characters];
        if (1 == [s length]) {
            unichar c = [s characterAtIndex:0];
            NSInteger i = c - 0x31;
            if (i >= 0 && i <= 9) {
                TDTabbedDocument *doc = [self tabbedDocument];
                NSUInteger lastIdx = [doc.tabModels count] - 1;
                if (i > lastIdx) {
                    i = lastIdx;
                }
                doc.selectedTabIndex = i;
                return YES;
            }
        }
    }
    return NO;
}


//- (BOOL)handleNextPrevTab:(NSEvent *)evt {
//    // ⌘-{, ⌘-}
//    if ([evt isCommandKeyPressed]) {
//        NSInteger keyCode = [evt keyCode];
//        if (CLOSE_CURLY == keyCode || OPEN_CURLY == keyCode) {
//            TDTabbedDocument *doc = [self tabbedDocument];
//            if (CLOSE_CURLY == keyCode) {
//                [doc selectNextTab:self];
//            } else if (OPEN_CURLY == keyCode) {
//                [doc selectPreviousTab:self];
//            }
//            return YES;
//        }
//        
//        // ⇧⌘←, ⇧⌘→
//        if ([evt isShiftKeyPressed] && (LEFT_ARROW == keyCode || RIGHT_ARROW == keyCode)) {
//            TDTabbedDocument *doc = [self tabbedDocument];
//            if (RIGHT_ARROW == keyCode) {
//                [doc selectNextTab:self];
//            } else if (LEFT_ARROW == keyCode) {
//                [doc selectPreviousTab:self];
//            }
//            return YES;
//        }
//    }
//    return NO;
//}


- (TDTabbedDocument *)tabbedDocument {
    return (TDTabbedDocument *)[[self windowController] document];
}

@end
