//
//  TDDropTargetView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/29/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDDropTargetView.h>
#import <TDAppKit/TDHintButton.h>

#define MARGIN 60.0

#define ROUND_RADIUS 10.0

#define SPACE_LEN 8.0
#define IDEAL_DASH_LEN 40.0

#define HINT_MIN_WIDTH 50.0
#define HINT_HEIGHT 100.0
#define HINT_MARGIN_X 100.0

@interface NSObject ()
- (void)browse:(id)sender;
@end

@implementation TDDropTargetView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGRect r = [self hintButtonRectForBounds:[self bounds]];
        self.hintButton = [[[TDHintButton alloc] initWithFrame:r] autorelease];
        [_hintButton setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [_hintButton setHintText:NSLocalizedString(@"Add an XML document.", @"")];
        [self addSubview:_hintButton];
    }
    return self;
}


- (void)dealloc {
    self.hintButton = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark NSDraggingDestination

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)dragInfo {
    NSWindowController *wc = [[self window] windowController];
    TDAssert(wc);
    if ([wc respondsToSelector:@selector(draggingEntered:)]) {
        return [(id)wc draggingEntered:dragInfo];
    } else {
        return [[wc document] draggingEntered:dragInfo];
    }
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)dragInfo {
    NSWindowController *wc = [[self window] windowController];
    TDAssert(wc);
    if ([wc respondsToSelector:@selector(draggingEntered:)]) {
        return [(id)wc performDragOperation:dragInfo];
    } else {
        return [[wc document] performDragOperation:dragInfo];
    }
}


#pragma mark -
#pragma mark TDView

- (void)layoutSubviews {
    TDAssertMainThread();
    TDAssert(_hintButton);
    
    CGRect bounds = [self bounds];
    _hintButton.frame = [self hintButtonRectForBounds:bounds];
}


#pragma mark -
#pragma mark NSView

- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGRect bounds = [self bounds];

    if (self.color) {
        [self.color setFill];
        NSRectFill(bounds);
    }
    
    CGFloat marginX = bounds.size.width * 0.1;
    CGFloat marginY = bounds.size.height * 0.1;
    CGRect r = CGRectInset(bounds, marginX, marginY);
    
    CGContextSetLineWidth(ctx, 4.0);
    CGContextSetGrayStrokeColor(ctx, 0.67, 1.0);

    CGFloat minx = CGRectGetMinX(r);
    CGFloat midx = CGRectGetMidX(r);
    CGFloat maxx = CGRectGetMaxX(r);
    CGFloat miny = CGRectGetMinY(r);
    CGFloat midy = CGRectGetMidY(r);
    CGFloat maxy = CGRectGetMaxY(r);

    CGFloat height = r.size.height - ROUND_RADIUS;
    CGFloat width = r.size.width - ROUND_RADIUS;

//    CGFloat yNumSegs = round(height/IDEAL_DASH_LEN);
//    CGFloat xNumSegs = round(width/IDEAL_DASH_LEN);

    CGFloat yNumSegs = bounds.size.height/50.0;
    CGFloat xNumSegs = bounds.size.width/50.0;

    CGFloat ySegLen = height/yNumSegs;
    CGFloat yDashLen = ySegLen - SPACE_LEN;
    
    CGFloat xSegLen = width/xNumSegs;
    CGFloat xDashLen = xSegLen - SPACE_LEN;

    CGFloat yLens[] = {yDashLen, SPACE_LEN};
    CGFloat xLens[] = {xDashLen, SPACE_LEN};

    CGFloat yPhase = yDashLen*0.5;
    CGFloat xPhase = xDashLen*0.5;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, minx, maxy-ROUND_RADIUS);
    CGContextAddArcToPoint(ctx, minx, miny, midx, miny, ROUND_RADIUS);
    CGContextSetLineDash(ctx, yPhase, yLens, 2);
    CGContextStrokePath(ctx);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, minx+ROUND_RADIUS, miny);
    CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, ROUND_RADIUS);
    CGContextSetLineDash(ctx, xPhase, xLens, 2);
    CGContextStrokePath(ctx);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, maxx, miny+ROUND_RADIUS);
    CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, ROUND_RADIUS);
    CGContextSetLineDash(ctx, yPhase, yLens, 2);
    CGContextStrokePath(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, maxx-ROUND_RADIUS, maxy);
    CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, ROUND_RADIUS);
    CGContextSetLineDash(ctx, xPhase, xLens, 2);
    CGContextStrokePath(ctx);
}


- (CGRect)hintButtonRectForBounds:(CGRect)bounds {
    CGFloat w = round(CGRectGetWidth(bounds) - HINT_MARGIN_X*2.0);
    w = MAX(HINT_MIN_WIDTH, w);
    CGFloat h = HINT_HEIGHT;

    CGFloat x = round(CGRectGetWidth(bounds)*0.5 - w*0.5);
    CGFloat y = round(CGRectGetHeight(bounds)*0.5 - h*0.5);
    
    CGRect r = CGRectMake(x, y, w, h);
    return r;
}

@end
