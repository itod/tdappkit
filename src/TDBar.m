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

#import "TDBar.h"
#import "TDUtils.h"

@implementation TDBar

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.mainBgGradient = nil;
    self.nonMainBgGradient = nil;
    self.hiBgGradient = nil;
    self.mainTopBorderColor = nil;
    self.nonMainTopBorderColor = nil;
    self.mainTopBevelColor = nil;
    self.nonMainTopBevelColor = nil;
    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    if (TDIsYozOrLater()) {
        NSColor *topColor = TDHexColor(0xE1DFDF);
        NSColor *botColor = TDHexColor(0xC2C1C2);
        self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
        
        topColor = TDHexColor(0xF4F4F4);
        botColor = TDHexColor(0xF4F4F4);
        self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
        
        self.hiBgGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.75 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.55 alpha:1.0]] autorelease];
        
        self.mainTopBorderColor = TDHexColor(0x9E9E9E);
        self.nonMainTopBorderColor = TDHexColor(0xBBBBBB);
        
        self.mainTopBevelColor = nil;
        self.nonMainTopBevelColor = nil;
        
        self.mainBottomBevelColor = nil;
        self.nonMainBottomBevelColor = nil;
    } else {
        NSColor *bgColor = [NSColor colorWithDeviceWhite:0.77 alpha:1.0];
        self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:[bgColor colorWithAlphaComponent:0.7] endingColor:bgColor] autorelease];
        
        bgColor = [NSColor colorWithDeviceWhite:0.93 alpha:1.0];
        self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:[bgColor colorWithAlphaComponent:0.7] endingColor:bgColor] autorelease];
        
        self.hiBgGradient = [[[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.75 alpha:1.0] endingColor:[NSColor colorWithDeviceWhite:0.55 alpha:1.0]] autorelease];
        
        self.mainTopBorderColor = [NSColor colorWithDeviceWhite:0.53 alpha:1.0];
        self.nonMainTopBorderColor = [NSColor colorWithDeviceWhite:0.78 alpha:1.0];
        self.mainTopBevelColor = [NSColor colorWithDeviceWhite:0.88 alpha:1.0];
        self.nonMainTopBevelColor = [NSColor colorWithDeviceWhite:0.99 alpha:1.0];
        self.mainBottomBevelColor = [NSColor lightGrayColor];
        self.nonMainBottomBevelColor = [NSColor colorWithDeviceWhite:0.99 alpha:1.0];
    }
}


- (BOOL)shouldDrawTopBorder {
    return YES;
}


- (void)viewDidMoveToWindow {
    NSWindow *win = [self window];
    if (win) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:win];
        [nc addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidResignMainNotification object:win];
    }
}


- (void)windowDidBecomeMain:(NSNotification *)n {
    if ([self window]) {
        [self setNeedsDisplay:YES];
    }
}


- (void)drawRect:(CGRect)dirtyRect {
    CGRect bounds = [self bounds];
    BOOL isMain = [[self window] isMainWindow];
    BOOL isHi = [self isHighlighted];
    
    NSGradient *bgGradient = nil;
    NSColor *topBorderColor = nil;
    NSColor *topBevelColor = nil;
    NSColor *bottomBevelColor = nil;
    
    if (isMain) {
        if (isHi) {
            bgGradient = _hiBgGradient;
        } else {
            bgGradient = _mainBgGradient;
        }
        topBorderColor = _mainTopBorderColor;
        topBevelColor = _mainTopBevelColor;
        bottomBevelColor = _mainBottomBevelColor;
    } else {
        bgGradient = _nonMainBgGradient;
        topBorderColor = _nonMainTopBorderColor;
        topBevelColor = _nonMainTopBevelColor;
        bottomBevelColor = _nonMainBottomBevelColor;
    }

    // background
    if (bgGradient) {
        [bgGradient drawInRect:bounds angle:270];
    }
    
    CGFloat y = NSMaxY(bounds) - 1.5;
    CGPoint p1 = CGPointMake(0.0, y);
    CGPoint p2 = CGPointMake(NSWidth(bounds), y);

    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:1.0];

    // top bevel
    if (topBevelColor) {
        [topBevelColor set];
        [path moveToPoint:p1];
        [path lineToPoint:p2];
        [path stroke];
    }

    // top border
    if ([self shouldDrawTopBorder]) {
        if (topBorderColor) {
            [topBorderColor set];
            p1.y += 1.0;
            p2.y += 1.0;
            [path removeAllPoints];
            [path moveToPoint:p1];
            [path lineToPoint:p2];
            [path stroke];
        }
    }

    // bottom bevel
    if (bottomBevelColor) {
        [bottomBevelColor set];
        p1 = CGPointMake(0.0, 0.5);
        p2 = CGPointMake(NSWidth(bounds), 0.5);
        [path removeAllPoints];
        [path moveToPoint:p1];
        [path lineToPoint:p2];
        [path stroke];
    }
}


- (BOOL)isHighlighted {
    return NO;
}

@end
