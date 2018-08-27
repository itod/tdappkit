//
//  TDTitleBorderView.m
//  Pathology
//
//  Created by Todd Ditchendorf on 5/25/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import "TDTitleBorderView.h"
#import <TDAppKit/TDUtils.h>

#define TITLE_BAR_HEIGHT 16.0

#define TITLE_MARGIN_X 4.0
#define TITLE_MARGIN_Y 2.0

static NSColor *sBorderColor = nil;
static NSColor *sNonMainBorderColor = nil;
static NSGradient *sTitleBarGradient = nil;
static NSDictionary *sTitleAttrs = nil;

@implementation TDTitleBorderView

+ (void)initialize {
    if ([TDTitleBorderView class] == self) {
        
        sBorderColor = [TDHexColor(0x999999) retain];
        sNonMainBorderColor = [TDHexColor(0xaaaaaa) retain];
        
        sTitleBarGradient = [TDVertGradient(0xdddddd, 0xffffff) retain];
        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSTextAlignmentLeft];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.2]];
        [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        [shadow setShadowBlurRadius:1.0];
        
        sTitleAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSFont boldSystemFontOfSize:11.0], NSFontAttributeName,
                       [NSColor controlTextColor], NSForegroundColorAttributeName,
                       shadow, NSShadowAttributeName,
                       paraStyle, NSParagraphStyleAttributeName,
                       nil];
    }
}


- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.title = nil;
    [super dealloc];
}


- (void)awakeFromNib {
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(statusBarVisibleDidChange:) name:PAStatusBarVisibleDidChangeNotification object:nil];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGRect bounds = [self bounds];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    NSColor *borderColor = nil;
    NSGradient *grad = nil;

    if ([[self window] isMainWindow]) {
        borderColor = sBorderColor;
        grad = sTitleBarGradient;
    } else {
        borderColor = sNonMainBorderColor;
        grad = sTitleBarGradient;
    }
    [borderColor set];

    CGContextFillRect(ctx, bounds);

    CGRect titleBarRect = [self titleBarRectForBounds:bounds];
    [grad drawInRect:titleBarRect angle:90.0];
    CGContextStrokeRect(ctx, titleBarRect);
    
    CGRect titleRect = [self titleTextRectForBounds:bounds];
 
    TDAssert([_title length]);
    [_title drawInRect:titleRect withAttributes:sTitleAttrs];
}


- (CGRect)titleBarRectForBounds:(CGRect)bounds {
    CGFloat h = TITLE_BAR_HEIGHT;
    
    CGFloat x = round(CGRectGetMinX(bounds)) + 0.5;
    CGFloat y = round(CGRectGetMaxY(bounds) - h) - 0.5;
    CGFloat w = round(CGRectGetWidth(bounds)) - 1.0;
    
    CGRect r = CGRectMake(x, y, w, h);
    return r;
}


- (CGRect)titleTextRectForBounds:(CGRect)bounds {
    CGFloat x = round(CGRectGetMinX(bounds) + TITLE_MARGIN_X);
    CGFloat y = round(CGRectGetMaxY(bounds) - (TITLE_BAR_HEIGHT+TITLE_MARGIN_Y));
    CGFloat w = round(CGRectGetWidth(bounds) - TITLE_MARGIN_X*2.0);
    CGFloat h = TITLE_BAR_HEIGHT;
    
    CGRect r = CGRectMake(x, y, w, h);
    return r;
}


#pragma mark -
#pragma mark Notifications

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    
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


//- (void)statusBarVisibleDidChange:(NSNotification *)n {
//    [self setNeedsDisplay:YES];
//}

@end
