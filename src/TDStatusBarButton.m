//
//  TDStatusBarButton.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 7/1/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarButton.h>
#import <TDAppKit/TDStatusBarPopUpView.h>
#import <TDAppKit/TDUtils.h>

#define LABEL_MARGIN_X 8.0
#define VALUE_MARGIN_X 3.0

@interface TDStatusBarButton ()
@property (nonatomic, assign) NSSize titleTextSize;
@end

@implementation TDStatusBarButton

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.mainBgGradient = nil;
    self.hiBgGradient = nil;
    self.nonMainBgGradient = nil;
    self.mainTopBorderColor = nil;
    self.nonMainTopBorderColor = nil;
    self.mainTopBevelColor = nil;
    self.hiTopBevelColor = nil;
    self.nonMainTopBevelColor = nil;
    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    NSColor *topColor = nil;
    NSColor *botColor = nil;
    NSColor *topBevelColor = nil;
    
    if (TDIsYozOrLater()) {
        topColor = TDHexColor(0xe0e0e0);
        botColor = TDHexColor(0xd0d0d0);
    } else {
        topColor = TDHexColor(0xcfcfcf);
        botColor = TDHexColor(0x9f9f9f);
    }

    topBevelColor = [NSColor colorWithDeviceWhite:0.88 alpha:1.0];
    self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    self.mainTopBevelColor = topBevelColor;
    self.mainTopBorderColor = [NSColor colorWithDeviceWhite:0.53 alpha:1.0];
    
    if (TDIsYozOrLater()) {
        topColor = TDHexColor(0xd0d0d0);
        botColor = TDHexColor(0xc0c0c0);
    } else {
        topColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
        botColor = [NSColor colorWithDeviceWhite:0.55 alpha:1.0];
    }
    topBevelColor = [NSColor colorWithDeviceWhite:0.78 alpha:1.0];
    self.hiBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    self.hiTopBevelColor = topBevelColor;
    
    topColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
    botColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    self.nonMainTopBorderColor = [NSColor colorWithDeviceWhite:0.78 alpha:1.0];
    self.nonMainTopBevelColor = [NSColor colorWithDeviceWhite:0.99 alpha:1.0];
    
    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;

}


- (BOOL)shouldDrawTopBorder {
    return YES;
}


- (BOOL)isFlipped {
    return NO;
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


#pragma mark -
#pragma mark Metrics

- (NSRect)titleRectForBounds:(NSRect)bounds {
    BOOL centered = NSCenterTextAlignment == [self alignment];
    CGFloat x = LABEL_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _titleTextSize.height / 2.0);
    CGFloat w = centered ? round(CGRectGetWidth(bounds) - LABEL_MARGIN_X*2.0) : TDRoundAlign(_titleTextSize.width);
    CGFloat h = _titleTextSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


#pragma mark -
#pragma mark Properties

- (void)setTitle:(NSString *)s {
    [super setTitle:s];
    if (s) {
        NSDictionary *attrs = [TDStatusBarPopUpView defaultLabelTextAttributes];
        TDAssert([attrs count]);
        self.titleTextSize = [s sizeWithAttributes:attrs];
        
        [self setNeedsDisplay:YES];
    }
}

@end
