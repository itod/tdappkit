//  Copyright 2009 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <TDAppKit/NSEvent+TDAdditions.h>
#import <TDAppKit/TDUtils.h>

#define ESC 53
#define BACKSPACE 51
#define DELETE 117
#define RETURN 36
#define ENTER 76
#define PERIOD 47
#define TAB 48
#define SPACE 49
#define UP_ARROW 126
#define DOWN_ARROW 125
#define LEFT_ARROW 123
#define RIGHT_ARROW 124
#define LOWERCASE_Z 6
#define UPPERERCASE_Z 6

@implementation NSEvent (TDAdditions)

- (BOOL)isMouseDown {
    return (NSLeftMouseDown == [self type]);
}


- (BOOL)isMouseMoved {
    return (NSMouseMoved == [self type]);
}


- (BOOL)isMouseDragged {
    return (NSLeftMouseDragged == [self type]);
}


- (BOOL)isMouseUp {
    return (NSLeftMouseUp == [self type]);
}


- (BOOL)isKeyUp {
    return (NSKeyUp == [self type]);
}


- (BOOL)isKeyDown {
    return (NSKeyDown == [self type]);
}


- (BOOL)isKeyUpOrDown {
    return [self isKeyUp] || [self isKeyDown];
}


- (BOOL)is3rdButtonClick {
    return 2 == [self buttonNumber];
}


- (BOOL)isScrollWheel {
    return (NSScrollWheel == [self type]);
}


- (BOOL)isDoubleClick {
    return ([self clickCount] % 2 == 0);
}


- (BOOL)isCommandKeyPressed {
    return TDIsCommandKeyPressed([self modifierFlags]);
}


- (BOOL)isControlKeyPressed {
    return TDIsControlKeyPressed([self modifierFlags]);
}


- (BOOL)isShiftKeyPressed {
    return TDIsShiftKeyPressed([self modifierFlags]);
}


- (BOOL)isOptionKeyPressed {
    return TDIsOptionKeyPressed([self modifierFlags]);
}


- (BOOL)isEscKeyPressed {
    return [self isKeyUpOrDown] && ESC == [self keyCode];
}


- (BOOL)isReturnKeyPressed {
    return [self isKeyUpOrDown] && RETURN == [self keyCode];
}


- (BOOL)isEnterKeyPressed {
    return [self isKeyUpOrDown] && ENTER == [self keyCode];
}


- (BOOL)isTabKeyDown {
    return [self isKeyDown] && TAB == [self keyCode];
}


- (BOOL)isDeleteKeyDown {
    return [self isKeyDown] && (DELETE == [self keyCode] || BACKSPACE == [self keyCode]);
}


- (BOOL)isArrowKeyDown {
    if (![self isKeyDown]) return NO;
    
    NSInteger keyCode = [self keyCode];
    return (UP_ARROW == keyCode || DOWN_ARROW == keyCode || LEFT_ARROW == keyCode || RIGHT_ARROW == keyCode);
}


- (BOOL)isUpArrowKeyDown {
    return [self isKeyDown] && UP_ARROW == [self keyCode];
}


- (BOOL)isDownArrowKeyDown {
    return [self isKeyDown] && DOWN_ARROW == [self keyCode];
}


- (BOOL)isLeftArrowKeyDown {
    return [self isKeyDown] && LEFT_ARROW == [self keyCode];
}


- (BOOL)isRightArrowKeyDown {
    return [self isKeyDown] && RIGHT_ARROW == [self keyCode];
}


- (BOOL)isSpaceKeyDown {
    return [self isKeyDown] && SPACE == [self keyCode];
}


- (BOOL)isZKeyDown {
    return [self isKeyDown] && (LOWERCASE_Z == [self keyCode] || UPPERERCASE_Z == [self keyCode]);
}


- (BOOL)isCommandPeriodKeyDown {
    return [self isKeyDown] && PERIOD == [self keyCode];
}

@end
