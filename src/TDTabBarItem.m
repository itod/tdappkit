//  Copyright 2010 Todd Ditchendorf
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

#import <TDAppKit/TDTabBarItem.h>

@implementation TDTabBarItem

- (id)initWithTitle:(NSString *)aTitle image:(NSImage *)img tag:(NSInteger)aTag {
    if (self = [super init]) {
        self.button = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
        
        self.title = aTitle;
        self.image = img;
        self.tag = aTag;
    }
    return self;
}


- (void)dealloc {
    [_button removeFromSuperview];
    self.button = nil;
    self.badgeValue = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<TDTabBarItem: %p '%@'>", self, [self title]];
}


- (BOOL)displaysTitle {
    return YES;
}


- (void)setEnabled:(BOOL)yn {
    [super setEnabled:yn];
    [_button setEnabled:yn];
}


- (id)target {
    return [_button target];
}


- (void)setTarget:(id)t {
    [_button setTarget:t];
}


- (SEL)action {
    return [_button action];
}


- (void)setAction:(SEL)sel {
    [_button setAction:sel];
}


- (void)setTitle:(NSString *)aTitle {
    [super setTitle:aTitle];
    if ([self displaysTitle]) {
        [_button setTitle:aTitle];
    } else {
        [_button setTitle:@""];
    }
}


- (void)setImage:(NSImage *)img {
    [super setImage:img];
    [_button setImage:img];
}


- (void)setTag:(NSInteger)aTag {
    [super setTag:aTag];
    [_button setTag:aTag];
}

@end
