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
    
    [_mainBgGradient release]; _mainBgGradient = nil;
    [_hiBgGradient release]; _hiBgGradient = nil;
    [_nonMainBgGradient release]; _nonMainBgGradient = nil;
    [_mainTopBorderColor release]; _mainTopBorderColor = nil;
    [_nonMainTopBorderColor release]; _nonMainTopBorderColor = nil;
    [_mainTopBevelColor release]; _mainTopBevelColor = nil;
    [_hiTopBevelColor release]; _hiTopBevelColor = nil;
    [_nonMainTopBevelColor release]; _nonMainTopBevelColor = nil;
    [_mainBottomBevelColor release]; _mainBottomBevelColor = nil;
    [_nonMainBottomBevelColor release]; _nonMainBottomBevelColor = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [self setUpColors];
}


- (void)viewDidChangeEffectiveAppearance {
    [self setUpColors];
    [self setNeedsDisplay:YES];
}


- (void)setUpColors {
    // MAIN
    {
        NSColor *topColor = [NSColor colorNamed:@"statusBarButtonMainBackgroundTopColor"]; //TDHexColor(0xdddddd);
        NSColor *botColor = [NSColor colorNamed:@"statusBarButtonMainBackgroundBotColor"]; //TDHexColor(0xbbbbbb);
        
        self.mainTopBorderColor = [NSColor colorNamed:@"statusBarButtonMainTopBorderColor"]; //TDHexColor(0x9E9E9E);
        self.mainTopBevelColor = nil;
        self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
        self.mainBottomBevelColor = nil;
    }

    // HI
    {
        NSColor *topColor = [NSColor colorNamed:@"statusBarButtonHiBackgroundTopColor"]; //TDHexColor(0xd0d0d0);
        NSColor *botColor = [NSColor colorNamed:@"statusBarButtonHiBackgroundBotColor"]; //TDHexColor(0xb0b0b0);
        
        self.hiTopBevelColor = nil;
        self.hiBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    }
    
    // NON MAIN
    {
        NSColor *topColor = [NSColor colorNamed:@"statusBarButtonNonMainBackgroundTopColor"]; //TDHexColor(0xdddddd);
        NSColor *botColor = [NSColor colorNamed:@"statusBarButtonNonMainBackgroundBotColor"]; //TDHexColor(0xbbbbbb);

        self.nonMainTopBorderColor = [NSColor colorNamed:@"statusBarButtonNonMainBorderColor"]; //TDHexColor(0x9E9E9E);;
        self.nonMainTopBevelColor = nil;
        self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
        self.nonMainBottomBevelColor = nil;
    }
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
    BOOL centered = NSTextAlignmentCenter == [self alignment];
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
