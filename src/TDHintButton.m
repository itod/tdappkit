//
//  TDHintView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/11/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDHintButton.h>
#import <TDAppKit/TDUtils.h>

#define HINT_MIN_WIDTH 100.0
#define HINT_MAX_WIDTH 300.0

#define HINT_HEIGHT 42.0
#define HINT_MARGIN_X 0.0
#define HINT_PADDING_X 22.0
#define HINT_PADDING_Y 14.0

#define HINT_VERT_FUDGE 0.0

static NSDictionary *sHintAttrs = nil;

static NSColor *sHintBgColor = nil;
static NSColor *sHintHiBgColor = nil;

static NSColor *sHintBgColorDark = nil;
static NSColor *sHintHiBgColorDark = nil;

@implementation TDHintButton

+ (void)initialize {
    if ([TDHintButton class] == self) {
        
        //[[NSColor colorWithDeviceWhite:.87 alpha:1] set];
        //[[NSColor colorWithDeviceRed:230.0/255.0 green:236.0/255.0 blue:242.0/255.0 alpha:1] set];
        
        sHintBgColor = [[NSColor colorWithDeviceWhite:0.68 alpha:1.0] retain];
        sHintHiBgColor = [[NSColor colorWithDeviceWhite:0.58 alpha:1.0] retain];
        
        sHintBgColorDark = [[NSColor colorWithDeviceWhite:0.15 alpha:1.0] retain];
        sHintHiBgColorDark = [[NSColor colorWithDeviceWhite:0.1 alpha:1.0] retain];
        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSTextAlignmentCenter];
        [paraStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.5]];
        [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        [shadow setShadowBlurRadius:2.0];
        
        sHintAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [NSFont boldSystemFontOfSize:14.0], NSFontAttributeName,
                      [NSColor whiteColor], NSForegroundColorAttributeName,
                      shadow, NSShadowAttributeName,
                      paraStyle, NSParagraphStyleAttributeName,
                      nil];
    }
}


- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setButtonType:NSButtonTypeMomentaryChange];
        [self setFocusRingType:NSFocusRingTypeNone];
        [self setTag:0];
    }
    return self;
}


- (void)dealloc {
    self.hintText = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p '%@'>", [self class], self, _hintText];
}


- (NSRect)hintTextRectForBounds:(NSRect)bounds {
    CGFloat w = bounds.size.width - HINT_MARGIN_X * 2 - HINT_PADDING_X * 2;
    w = w < HINT_MIN_WIDTH ? HINT_MIN_WIDTH : w;
    
    NSRect strRect = [_hintText boundingRectWithSize:NSMakeSize(w, 10000000.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:sHintAttrs];

    CGFloat h = strRect.size.height;
    CGFloat x = HINT_MARGIN_X + HINT_PADDING_X;
    CGFloat y = bounds.size.height / 2 - strRect.size.height / 2 + HINT_VERT_FUDGE;
    y += _hintTextOffsetY;

    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];

//    [[NSColor redColor] setFill];
//    NSRectFill(bounds);
    
    BOOL isHi = [[self cell] isHighlighted]; //NSOnState == [self state];
    
    BOOL showHint = ([_hintText length]);
    if (showHint) {
        NSRect hintTextRect = [self hintTextRectForBounds:bounds];
        
        NSRect hintRect = NSInsetRect(hintTextRect, -HINT_PADDING_X, -HINT_PADDING_Y);
        
        CGFloat w = hintRect.size.width;
        w = w > HINT_MAX_WIDTH ? HINT_MAX_WIDTH : w;
        hintRect.size.width = floor(w);
        
        CGFloat x = bounds.size.width / 2 -  hintRect.size.width / 2;
        x = x < HINT_MARGIN_X ? HINT_MARGIN_X : x;
        hintRect.origin.x = floor(x);
        
        hintRect.origin.y = floor(hintRect.origin.y);
        hintRect.size.height = floor(hintRect.size.height);
        CGFloat radius = hintRect.size.height / 2 - 2;
        
        NSColor *bgColor = nil;
        if (TDIsDarkMode()) {
            bgColor = isHi ? sHintHiBgColorDark : sHintBgColorDark;
        } else {
            bgColor = isHi ? sHintHiBgColor : sHintBgColor;
        }
        [bgColor setFill];
        
        CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];
        TDAddRoundRect(ctx, hintRect, radius);
        CGContextFillPath(ctx);
        
        [[NSColor whiteColor] set];
        [_hintText drawInRect:hintTextRect withAttributes:sHintAttrs];
    }
}

@end
