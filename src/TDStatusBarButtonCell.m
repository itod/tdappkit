//
//  TDStatusBarButtonCell.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/23/12.
//  Copyright (c) 2012 Todd Ditchendorf. All rights reserved.
//

#import "TDStatusBarButtonCell.h"
#import "TDStatusBarButton.h"
#import "TDStatusBarPopUpView.h"
#import <TDAppKit/TDUtils.h>

@implementation TDStatusBarButtonCell

+ (void)initialize {
    if ([TDStatusBarButtonCell class] == self) {

    }
}


- (void)drawWithFrame:(NSRect)cellFrame inView:(TDStatusBarButton *)cv {
    BOOL isMain = [[cv window] isMainWindow];
    BOOL isHi = [self isHighlighted];

    NSGradient *bgGradient = nil;
    NSColor *topBorderColor = nil;
    NSColor *topBevelColor = nil;
    NSColor *bottomBevelColor = nil;
    if (isMain) {
        bgGradient = cv.mainBgGradient;
        topBorderColor = cv.mainTopBorderColor;
        topBevelColor = cv.mainTopBevelColor;
        bottomBevelColor = cv.mainBottomBevelColor;
    } else {
        bgGradient = cv.nonMainBgGradient;
        topBorderColor = cv.nonMainTopBorderColor;
        topBevelColor = cv.nonMainTopBevelColor;
        bottomBevelColor = cv.nonMainBottomBevelColor;
    }
    
    if (isHi) {
        topBevelColor = cv.hiTopBevelColor;
        bgGradient = cv.hiBgGradient;
    }
    
    // background
    if (bgGradient) {
        [bgGradient drawInRect:[cv bounds] angle:270.0];
    }
    
    // title
    NSString *title = [self title];
    CGRect titleRect = [cv titleRectForBounds:cellFrame];
    NSDictionary *attrs = isMain ? [TDStatusBarPopUpView defaultLabelTextAttributes] : [TDStatusBarPopUpView defaultNonMainLabelTextAttributes];
    [title drawInRect:titleRect withAttributes:attrs];
    
    CGFloat y = NSMaxY(cellFrame) - 1.5;
    NSPoint p1 = NSMakePoint(0.0, y);
    NSPoint p2 = NSMakePoint(NSWidth(cellFrame), y);
    
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
    if (topBorderColor) {
        [topBorderColor set];
        p1.y += 1.0;
        p2.y += 1.0;
        [path removeAllPoints];
        [path moveToPoint:p1];
        [path lineToPoint:p2];
        [path stroke];
    }
    
    // bottom bevel
    if (bottomBevelColor) {
        [bottomBevelColor set];
        p1 = NSMakePoint(0.0, 0.5);
        p2 = NSMakePoint(NSWidth(cellFrame), 0.5);
        [path removeAllPoints];
        [path moveToPoint:p1];
        [path lineToPoint:p2];
        [path stroke];
    }
    
    // right border
    [topBorderColor setStroke];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, NSMinX(cellFrame), NSMinY(cellFrame));
    CGContextAddLineToPoint(ctx, NSMinX(cellFrame), NSMaxY(cellFrame));
    CGContextStrokePath(ctx);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, round(NSMaxX(cellFrame))-0.5, NSMinY(cellFrame));
    CGContextAddLineToPoint(ctx, round(NSMaxX(cellFrame))-0.5, NSMaxY(cellFrame));
    CGContextStrokePath(ctx);

}

@end
