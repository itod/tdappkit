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
- (void)updateGradientsForMenuVisible;
- (void)drawArrowsInRect:(NSRect)arrowsRect dirtyRect:(NSRect)dirtyRect;
@property (nonatomic, assign) NSSize labelTextSize;
@property (nonatomic, assign) NSSize valueTextSize;
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


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.labelTextSize = CGSizeZero;
        self.valueTextSize = CGSizeZero;
        [self setUpSubviews];
    }
    
    return self;
}


- (void)dealloc {
    self.labelText = nil;
    self.valueText = nil;
    self.checkbox = nil;
    self.popUpButton = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUpSubviews];
    [self updateValue];
}


#pragma mark -
#pragma mark NSResponder

- (BOOL)acceptsFirstResponder {
    return YES;
}


- (void)mouseDown:(NSEvent *)evt {
    NSMenu *menu = [popUpButton menu];
    if (![[menu itemArray] count]) return;
    self.menuVisible = YES;
    
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        NSInteger idx = [popUpButton indexOfSelectedItem];
        NSMenuItem *item = [menu itemAtIndex:idx];
        
        NSSize menuSize = [menu size];
        NSRect bounds = [self bounds];
        NSRect valueRect = [self valueTextRectForBounds:bounds];
        
        NSPoint p = NSMakePoint(floor(NSMidX(valueRect) - menuSize.width / 2.0) - 0.5, NSMaxY(valueRect) - MENU_OFFSET_Y);
        [menu popUpMenuPositioningItem:item atLocation:p inView:self];

    });
}


#pragma mark -
#pragma mark NSView

- (BOOL)isFlipped {
    return NO;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    TDAssert([self window]);
    BOOL isMain = [[self window] isMainWindow];
    
    NSRect bounds = [self bounds];
    
    if (labelText) {
        NSRect labelRect = [self labelTextRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor redColor] setFill];
        NSRectFill(labelRect);
#endif
        NSDictionary *labelAttrs = isMain ? [TDStatusBarPopUpView defaultLabelTextAttributes] : [TDStatusBarPopUpView defaultNonMainLabelTextAttributes];
        [labelText drawInRect:labelRect withAttributes:labelAttrs];
    }
    
    if (valueText) {
        NSRect valueRect = [self valueTextRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor greenColor] setFill];
        NSRectFill(valueRect);
#endif
        NSDictionary *valAttrs = isMain ? [TDStatusBarPopUpView defaultValueTextAttributes] : [TDStatusBarPopUpView defaultNonMainValueTextAttributes];
        [valueText drawInRect:valueRect withAttributes:valAttrs];
        
        NSRect arrowsRect = [self arrowsRectForBounds:bounds];
#if DEBUG_DRAW
        [[NSColor whiteColor] setFill];
        NSRectFill(arrowsRect);
#endif
        [self drawArrowsInRect:arrowsRect dirtyRect:dirtyRect];
    }

    NSColor *strokeColor = nil;
    if (isMain) {
        strokeColor = [NSColor colorWithDeviceWhite:0.2 alpha:1.0];
    } else {
        strokeColor = [NSColor colorWithDeviceWhite:0.5 alpha:1.0];
    }
    [strokeColor setStroke];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, NSMinX(bounds), NSMinY(bounds));
    CGContextAddLineToPoint(ctx, NSMinX(bounds), NSMaxY(bounds));
    CGContextStrokePath(ctx);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, NSMaxX(bounds), NSMinY(bounds));
    CGContextAddLineToPoint(ctx, NSMaxX(bounds), NSMaxY(bounds));
    CGContextStrokePath(ctx);
}


- (void)drawArrowsInRect:(NSRect)arrowsRect dirtyRect:(NSRect)dirtyRect {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    NSPoint arrowsMidPoint = NSMakePoint(NSMidX(arrowsRect), NSMidY(arrowsRect));
    
    // begin
    CGContextSaveGState(ctx);

    [[NSColor colorWithDeviceWhite:0.2 alpha:1.0] setFill];
    
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
    NSRect bounds = [self bounds];
    
    self.popUpButton.frame = [self popUpButtonRectForBounds:bounds];
}


#pragma mark -
#pragma mark Metrics

- (NSRect)labelTextRectForBounds:(NSRect)bounds {
    CGFloat x = LABEL_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - labelTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(labelTextSize.width);
    CGFloat h = labelTextSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (NSRect)valueTextRectForBounds:(NSRect)bounds {
    CGRect labelRect = [self labelTextRectForBounds:bounds];
    BOOL hasLabelText = [labelText length] > 0;
    CGFloat marginX = hasLabelText ? VALUE_MARGIN_X : 0.0;
    
    CGFloat x = TDRoundAlign(CGRectGetMaxX(labelRect) + marginX);
    CGFloat y = TDRoundAlign(NSMidY(bounds) - valueTextSize.height / 2.0);
    CGFloat w = TDRoundAlign(valueTextSize.width);
    CGFloat h = valueTextSize.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (NSRect)popUpButtonRectForBounds:(NSRect)bounds {
    NSRect popUpBounds = [popUpButton bounds];
    
    CGFloat x = POPUP_MARGIN_X;
    CGFloat y = TDRoundAlign(NSMidY(bounds) - popUpBounds.size.height / 2.0);
    CGFloat w = TDRoundAlign(bounds.size.width - POPUP_MARGIN_X * 2.0);
    CGFloat h = popUpBounds.size.height;
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


- (NSRect)arrowsRectForBounds:(NSRect)bounds {
    CGRect valueRect = [self valueTextRectForBounds:bounds];
    
    CGFloat h = [[[[self class] defaultValueTextAttributes] objectForKey:NSFontAttributeName] pointSize];

    CGFloat x = TDRoundAlign(CGRectGetMaxX(valueRect) + ARROWS_MARGIN_X);
    CGFloat y = valueRect.origin.y + ARROWS_MARGIN_Y;
    CGFloat w = round(0.66 * h);
    
    NSRect r = NSMakeRect(x, y, w, h);
    return r;
}


#pragma mark -
#pragma mark NSMenuDelegate

- (void)menuDidClose:(NSMenu *)menu {
    [self updateValue];
}


#pragma mark -
#pragma mark Private

- (void)setUpSubviews {
    [self updateGradientsForMenuVisible];

    NSColor *topColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
    NSColor *botColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    self.nonMainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];

    topColor = [NSColor colorWithDeviceWhite:0.85 alpha:1.0];
    botColor = [NSColor colorWithDeviceWhite:0.65 alpha:1.0];
    self.mainBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];

    topColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
    botColor = [NSColor colorWithDeviceWhite:0.55 alpha:1.0];
    self.hiBgGradient = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];

    self.mainBottomBevelColor = nil;
    self.nonMainBottomBevelColor = nil;
    
    [popUpButton setHidden:YES];
    
    NSMenu *menu = [popUpButton menu];
    [menu setDelegate:self];

    NSFont *font = [[[self class] defaultValueTextAttributes] objectForKey:NSFontAttributeName];
    [menu setFont:font];
}


- (void)updateGradientsForMenuVisible {
    NSColor *topBevelColor = nil;
    
    if (menuVisible) {
        topBevelColor = [NSColor colorWithDeviceWhite:0.78 alpha:1.0];
    } else {
        topBevelColor = [NSColor colorWithDeviceWhite:0.88 alpha:1.0];
    }

    self.mainTopBevelColor = topBevelColor;

    [self setNeedsDisplayInRect:[self bounds]];
}


- (void)updateValue {
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        [popUpButton synchronizeTitleAndSelectedItem];
        self.valueText = [popUpButton titleOfSelectedItem];
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
    return menuVisible;
}


- (void)setLabelText:(NSString *)s {
    if (s != labelText) {
        [labelText release];
        labelText = [s retain];
        
        self.labelTextSize = [self.labelText sizeWithAttributes:[[self class] defaultLabelTextAttributes]];
        
        [self setNeedsDisplay:YES];
    }
}


- (void)setValueText:(NSString *)s {
    if (s != valueText) {
        [valueText release];
        valueText = [s retain];
        
        self.valueTextSize = [self.valueText sizeWithAttributes:[[self class] defaultValueTextAttributes]];
        
        [self setNeedsDisplay:YES];
    }
}


- (void)setMenuVisible:(BOOL)yn {
    if (yn != menuVisible) {
        menuVisible = yn;
        
        [self updateGradientsForMenuVisible];
    }
}

@synthesize labelText;
@synthesize valueText;
@synthesize checkbox;
@synthesize popUpButton;

@synthesize labelTextSize;
@synthesize valueTextSize;
@synthesize menuVisible;
@end
