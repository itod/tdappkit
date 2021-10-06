//
//  TDStatusBarPopUpControl.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/16/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDStatusBarPopUpView.h>
#import <TDAppKit/TDUtils.h>

#define D2R(d) (M_PI * (d) / 180.0)

#define LABEL_MARGIN_X 8.0
#define VALUE_MARGIN_X 3.0
#define POPUP_MARGIN_X 3.0
#define MENU_OFFSET_Y 1.0
#define ARROWS_MARGIN_X 3.0
#define ARROWS_MARGIN_Y 1.0

static NSDictionary *sLabelTextAttrs = nil;
static NSDictionary *sValueTextAttrs = nil;
static NSDictionary *sNonMainLabelTextAttrs = nil;
static NSDictionary *sNonMainValueTextAttrs = nil;

@interface TDStatusBarPopUpView ()
- (void)setUpSubviews;
- (void)drawArrowsInRect:(CGRect)arrowsRect dirtyRect:(CGRect)dirtyRect;
@property (nonatomic, assign) CGSize labelTextSize;
@property (nonatomic, assign) CGSize valueTextSize;
@property (nonatomic, assign) BOOL menuVisible;
@end

@implementation TDStatusBarPopUpView

+ (void)initialize {
    if ([TDStatusBarPopUpView class] == self) {
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSTextAlignmentCenter];
        [paraStyle setLineBreakMode:NSLineBreakByClipping];
        
        //        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        //        [shadow setShadowColor:[NSColor colorWithDeviceWhite:0.0 alpha:0.2]];
        //        [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        //        [shadow setShadowBlurRadius:1.0];
        
        sLabelTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:9.0], NSFontAttributeName,
                           [NSColor textColor], NSForegroundColorAttributeName,
                           //shadow, NSShadowAttributeName,
                           paraStyle, NSParagraphStyleAttributeName,
                           nil];

        sValueTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:9.0], NSFontAttributeName,
                           [NSColor textColor], NSForegroundColorAttributeName,
                           //shadow, NSShadowAttributeName,
                           paraStyle, NSParagraphStyleAttributeName,
                           nil];
        
        sNonMainLabelTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:9.0], NSFontAttributeName,
                            [[NSColor textColor] colorWithAlphaComponent:0.6], NSForegroundColorAttributeName,
                           //shadow, NSShadowAttributeName,
                           paraStyle, NSParagraphStyleAttributeName,
                           nil];

        sNonMainValueTextAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [NSFont systemFontOfSize:9.0], NSFontAttributeName,
                           [[NSColor textColor] colorWithAlphaComponent:0.6], NSForegroundColorAttributeName,
                           //shadow, NSShadowAttributeName,
                           paraStyle, NSParagraphStyleAttributeName,
                           nil];
    }
}


+ (NSDictionary *)defaultLabelTextAttributes {
    return sLabelTextAttrs;
}


+ (NSDictionary *)defaultValueTextAttributes {
    return sValueTextAttrs;
}


+ (NSDictionary *)defaultNonMainLabelTextAttributes {
    return sNonMainLabelTextAttrs;
}


+ (NSDictionary *)defaultNonMainValueTextAttributes {
    return sNonMainValueTextAttrs;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.labelTextSize = CGSizeZero;
        self.valueTextSize = CGSizeZero;
        [self setUpSubviews];
    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_labelText release]; _labelText = nil;
    [_valueText release]; _valueText = nil;
    [_checkbox release]; _checkbox = nil;
    [_popUpButton release]; _popUpButton = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpColors];
    [self setUpSubviews];
    [self updateValue];
}


- (void)viewDidChangeEffectiveAppearance {
    [self setUpColors];
    [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark NSResponder

- (BOOL)acceptsFirstResponder {
    return YES;
}


- (void)mouseDown:(NSEvent *)evt {
    NSMenu *menu = [_popUpButton menu];
    if (![[menu itemArray] count]) return;
    self.menuVisible = YES;
    
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        NSInteger idx = [_popUpButton indexOfSelectedItem];
        NSMenuItem *item = [menu itemAtIndex:idx];
        
        CGSize menuSize = [menu size];
        CGRect bounds = [self bounds];
        CGRect valueRect = [self valueTextRectForBounds:bounds];
        
        NSPoint p = NSMakePoint(floor(NSMidX(valueRect) - menuSize.width / 2.0) - 0.5, NSMaxY(valueRect) - MENU_OFFSET_Y);
        [menu popUpMenuPositioningItem:item atLocation:p inView:self];

    });
}


#pragma mark -
#pragma mark NSView

- (BOOL)isFlipped {
    return NO;
}


- (void)drawRect:(CGRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    TDAssert([self window]);
    BOOL isMain = [[self window] isMainWindow];
    
    CGRect bounds = [self bounds];
    
    if (_labelText) {
        CGRect labelRect = [self labelTextRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor redColor] setFill];
        NSRectFill(labelRect);
#endif
        NSDictionary *labelAttrs = isMain ? [TDStatusBarPopUpView defaultLabelTextAttributes] : [TDStatusBarPopUpView defaultNonMainLabelTextAttributes];
        [_labelText drawInRect:labelRect withAttributes:labelAttrs];
    }
    
    if (_valueText) {
        CGRect valueRect = [self valueTextRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor greenColor] setFill];
        NSRectFill(valueRect);
#endif
        NSDictionary *valAttrs = isMain ? [TDStatusBarPopUpView defaultValueTextAttributes] : [TDStatusBarPopUpView defaultNonMainValueTextAttributes];
        [_valueText drawInRect:valueRect withAttributes:valAttrs];
        
        CGRect arrowsRect = [self arrowsRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor whiteColor] setFill];
        NSRectFill(arrowsRect);
#endif
        [self drawArrowsInRect:arrowsRect dirtyRect:dirtyRect];
    }

    [(isMain ? self.mainTopBorderColor : self.nonMainTopBorderColor) setStroke];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, round(NSMinX(bounds))+0.5, NSMinY(bounds));
    CGContextAddLineToPoint(ctx, round(NSMinX(bounds))+0.5, NSMaxY(bounds));
    CGContextStrokePath(ctx);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, round(NSMaxX(bounds))-0.5, NSMinY(bounds));
    CGContextAddLineToPoint(ctx, round(NSMaxX(bounds))-0.5, NSMaxY(bounds));
    CGContextStrokePath(ctx);
}


- (void)drawArrowsInRect:(CGRect)arrowsRect dirtyRect:(CGRect)dirtyRect {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    NSPoint arrowsMidPoint = NSMakePoint(NSMidX(arrowsRect), NSMidY(arrowsRect));
    
    // begin
    CGContextSaveGState(ctx);

    [[NSColor colorNamed:@"statusBarPopupButtonArrowsColor"] setFill];
    
    // translate to center of arrows rect
    CGContextTranslateCTM(ctx, arrowsMidPoint.x, arrowsMidPoint.y);
    
    // draw top arrow path
    CGContextSaveGState(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, TDFloorAlign(-(NSWidth(arrowsRect) / 2.0)), (1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(NSWidth(arrowsRect) / 2.0), (1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(0.0), ((NSHeight(arrowsRect) / 2.0)));
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);

    // draw bottom arrow path
    CGContextSaveGState(ctx);
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, TDFloorAlign(-(NSWidth(arrowsRect) / 2.0)), (-1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(NSWidth(arrowsRect) / 2.0), (-1.0));
    CGContextAddLineToPoint(ctx, TDFloorAlign(0.0), (-(NSHeight(arrowsRect) / 2.0)));
    CGContextFillPath(ctx);
    CGContextRestoreGState(ctx);

    // done
    CGContextRestoreGState(ctx);
}


- (void)layoutSubviews {
    CGRect bounds = [self bounds];
    
    self.popUpButton.frame = [self popUpButtonRectForBounds:bounds];
}


#pragma mark -
#pragma mark Metrics

- (CGRect)labelTextRectForBounds:(CGRect)bounds {
    CGFloat x = LABEL_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _labelTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(_labelTextSize.width);
    CGFloat h = _labelTextSize.height;
    
    CGRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (CGRect)valueTextRectForBounds:(CGRect)bounds {
    CGRect labelRect = [self labelTextRectForBounds:bounds];
    BOOL hasLabelText = [_labelText length] > 0;
    CGFloat marginX = hasLabelText ? VALUE_MARGIN_X : 0.0;
    
    CGFloat x = TDRoundAlign(CGRectGetMaxX(labelRect) + marginX);
    CGFloat y = TDRoundAlign(NSMidY(bounds) - _valueTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(_valueTextSize.width);
    CGFloat h = _valueTextSize.height;
    
    CGRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (CGRect)popUpButtonRectForBounds:(CGRect)bounds {
    CGRect popUpBounds = [_popUpButton bounds];
    
    CGFloat x = POPUP_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - popUpBounds.size.height / 2.0);
    CGFloat w = TDRoundAlign(bounds.size.width - POPUP_MARGIN_X * 2.0);
    CGFloat h = popUpBounds.size.height;
    
    CGRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (CGRect)arrowsRectForBounds:(CGRect)bounds {
    CGRect valueRect = [self valueTextRectForBounds:bounds];
    
    CGFloat h = [[[[self class] defaultValueTextAttributes] objectForKey:NSFontAttributeName] pointSize];

    CGFloat x = TDRoundAlign(CGRectGetMaxX(valueRect) + ARROWS_MARGIN_X);
    CGFloat y = valueRect.origin.y + ARROWS_MARGIN_Y;
    CGFloat w = round(0.66 * h);
    
    CGRect r = NSMakeRect(x, y, w, h);
    return r;
}


#pragma mark -
#pragma mark NSMenuDelegate

- (void)menuDidClose:(NSMenu *)menu {
    [self updateValue];
}


#pragma mark -
#pragma mark Private

- (void)setUpColors {
    NSColor *topBorderColor = nil;
    NSColor *topBevelColor = nil;
    NSColor *topColor = nil;
    NSColor *botColor = nil;
    
    // MAIN
    {
        topBorderColor = [NSColor colorNamed:@"statusBarButtonMainTopBorderColor"]; //TDHexColor(0x9E9E9E);
        topBevelColor = nil;
        topColor = [NSColor colorNamed:@"statusBarButtonMainBackgroundTopColor"]; //TDHexColor(0xdddddd);
        botColor = [NSColor colorNamed:@"statusBarButtonMainBackgroundBotColor"]; //TDHexColor(0xbbbbbb);
        
        self.mainTopBorderColor = topBorderColor;
        self.mainTopBevelColor = topBevelColor;
        self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
        self.mainBottomBevelColor = nil;
    }

    // HI
    {
        topColor = [NSColor colorNamed:@"statusBarButtonHiBackgroundTopColor"]; //TDHexColor(0xd0d0d0);
        botColor = [NSColor colorNamed:@"statusBarButtonHiBackgroundBotColor"]; //TDHexColor(0xb0b0b0);
        
        self.hiBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    }
    
    // NON MAIN
    {
        topBorderColor = [NSColor colorNamed:@"statusBarButtonNonMainBorderColor"]; //TDHexColor(0x9E9E9E);
        topBevelColor = nil;
        topColor = [NSColor colorNamed:@"statusBarButtonNonMainBackgroundTopColor"]; //TDHexColor(0xdddddd);
        botColor = [NSColor colorNamed:@"statusBarButtonNonMainBackgroundBotColor"]; //TDHexColor(0xbbbbbb);

        self.nonMainTopBorderColor = topBorderColor;
        self.nonMainTopBevelColor = topBevelColor;
        self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
        self.nonMainBottomBevelColor = nil;
    }
}


- (void)setUpSubviews {
    [_popUpButton setHidden:YES];
    
    NSMenu *menu = [_popUpButton menu];
    [menu setDelegate:self];

    NSFont *font = [[[self class] defaultValueTextAttributes] objectForKey:NSFontAttributeName];
    [menu setFont:font];
}


- (void)updateValue {
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        [_popUpButton synchronizeTitleAndSelectedItem];
        self.valueText = [_popUpButton titleOfSelectedItem];
        self.menuVisible = NO;
    });
}


#pragma mark -
#pragma mark Notifications

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
#pragma mark Properties

- (BOOL)isHighlighted {
    return _menuVisible;
}


- (void)setLabelText:(NSString *)s {
    if (s != _labelText) {
        [_labelText release]; _labelText = nil;
        _labelText = [s retain];
        
        self.labelTextSize = [_labelText sizeWithAttributes:[[self class] defaultLabelTextAttributes]];
        
        [self setNeedsDisplay:YES];
    }
}


- (void)setValueText:(NSString *)s {
    if (s != _valueText) {
        [_valueText release]; _valueText = nil;
        _valueText = [s retain];
        
        self.valueTextSize = [self.valueText sizeWithAttributes:[[self class] defaultValueTextAttributes]];
        
        [self setNeedsDisplay:YES];
    }
}

@end
