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

#import <TDAppKit/TDTabBar.h>
#import <TDAppKit/TDTabBarItem.h>
#import <TDAppKit/TDUtils.h>

#define TABBAR_HEIGHT 22.0

#define BUTTON_WIDTH 28.0
#define BUTTON_MARGIN_X 1.0
#define BUTTON_MARGIN_TOP 0.0
#define BUTTON_MARGIN_BOTTOM 1.0

#define BUTTON_TITLE_PADDING_X 2.0

@implementation TDTabBar

+ (CGFloat)defaultHeight {
    return TABBAR_HEIGHT;
}


+ (NSDictionary *)defaultButtonTitleAttributes {
    TDAssertMainThread();
    static NSDictionary *sAttrs = nil;
    if (!sAttrs) {
        sAttrs = [@{NSFontAttributeName: [NSFont systemFontOfSize:13.0]} retain];
    }
    return sAttrs;
}


- (id)initWithFrame:(NSRect)r {
    if (self = [super initWithFrame:r]) {
        self.mainBgGradient = TDVertGradient(0xefefef, 0xcccccc);
        self.mainBottomBevelColor = [NSColor colorWithDeviceWhite:0.48 alpha:1.0];
        
        self.nonMainBgGradient = TDVertGradient(0xefefef, 0xdfdfdf);
        self.nonMainBottomBevelColor = [NSColor colorWithDeviceWhite:0.7 alpha:1.0];
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (void)awakeFromNib {
    
}


- (void)layoutSubviews {
    CGRect bounds = [self bounds];
    
    NSArray *buttons = [self subviews];
    TDAssert(buttons);
    NSInteger c = [[self subviews] count];
    
    if (c > 0) {
        CGFloat widths[c];
        CGFloat y = floor(CGRectGetMinY(bounds) + BUTTON_MARGIN_BOTTOM);
        CGFloat h = ceil(CGRectGetHeight(bounds) - (BUTTON_MARGIN_TOP + BUTTON_MARGIN_TOP));
        
        NSUInteger i = 0;
        CGFloat totalWidth = 0.0;
        for (NSButton *b in buttons) {
            CGFloat w = BUTTON_WIDTH;
            if (![[b title] isEqualToString:@"Button"]) {
                NSDictionary *attrs = [TDTabBar defaultButtonTitleAttributes];
                CGRect r = [[b title] boundingRectWithSize:CGSizeMake(200.0, h) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs];
                w = r.size.width + BUTTON_TITLE_PADDING_X * 2.0;
            }
            widths[i++] = w;
            totalWidth += w + BUTTON_MARGIN_X;
        }
        totalWidth -= BUTTON_MARGIN_X;

        CGFloat x = floor(CGRectGetWidth(bounds)/2.0 - totalWidth/2.0);
        
        i = 0;
        for (NSButton *b in buttons) {
            CGFloat w = widths[i++];
            CGRect r = CGRectMake(x, y, w, h);
            [b setFrame:r];
            x += floor(w + BUTTON_MARGIN_X - 1.0);
        }
    }
}


//- (void)drawRect:(NSRect)dirtyRect {
//    NSRect bounds = [self bounds];
//    [[NSColor redColor] setFill];
//    NSRectFill(bounds);
//}

@end
