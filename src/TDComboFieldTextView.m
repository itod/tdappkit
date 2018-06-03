//
//  TDComboFieldTextView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDComboFieldTextView.h"

@interface TDComboField ()
- (void)removeListWindow;
- (void)textWasInserted:(id)insertString;
@end

@implementation TDComboFieldTextView

- (id)initWithFrame:(CGRect)r {
    self = [super initWithFrame:r];
    if (self) {

    }
    return self;
}


- (void)dealloc {
    self.comboField = nil;
    [super dealloc];
}


- (BOOL)isFieldEditor {
    return YES;
}


// <esc> was pressed. suppresses system-provided completions UI
- (NSArray *)completionsForPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    TDAssert(_comboField);
    [_comboField escape:self];
    return nil;
}


- (void)moveRight:(id)sender { [_comboField removeListWindow]; [super moveRight:sender]; }
- (void)moveLeft:(id)sender { [_comboField removeListWindow]; [super moveLeft:sender]; }
- (void)moveWordForward:(id)sender { [_comboField removeListWindow]; [super moveWordForward:sender]; }
- (void)moveWordBackward:(id)sender { [_comboField removeListWindow]; [super moveWordBackward:sender]; }
- (void)moveToBeginningOfLine:(id)sender { [_comboField removeListWindow]; [super moveToBeginningOfLine:sender]; }
- (void)moveToEndOfLine:(id)sender { [_comboField removeListWindow]; [super moveToEndOfLine:sender]; }
- (void)moveToBeginningOfParagraph:(id)sender { [_comboField removeListWindow]; [super moveToBeginningOfParagraph:sender]; }
- (void)moveToEndOfParagraph:(id)sender { [_comboField removeListWindow]; [super moveToEndOfParagraph:sender]; }
- (void)moveToEndOfDocument:(id)sender { [_comboField removeListWindow]; [super moveToEndOfDocument:sender]; }
- (void)moveToBeginningOfDocument:(id)sender { [_comboField removeListWindow]; [super moveToBeginningOfDocument:sender]; }
- (void)pageDown:(id)sender { [_comboField removeListWindow]; [super pageDown:sender]; }
- (void)pageUp:(id)sender { [_comboField removeListWindow]; [super pageUp:sender]; }
- (void)centerSelectionInVisibleArea:(id)sender { [_comboField removeListWindow]; [super centerSelectionInVisibleArea:sender]; }


- (void)moveUp:(id)sender {
    TDAssert(_comboField);
    [_comboField moveUp:sender];
}


- (void)moveDown:(id)sender {
    TDAssert(_comboField);
    [_comboField moveDown:sender];
}


//- (void)insertText:(id)string {
- (void)insertText:(id)string replacementRange:(NSRange)replacementRange {
    TDAssert(_comboField);
    [super insertText:string replacementRange:replacementRange];
    [_comboField textWasInserted:string];
}

@end
