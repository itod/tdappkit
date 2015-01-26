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

#import "TDUberViewSplitView.h"
#import "TDUberView.h"
#import <TDAppKit/NSBezierPath+TDAdditions.h>
#import <TDAppKit/TDUtils.h>

#define DIVOT_SIDE 4.5

static NSGradient *sDivotGradient = nil;
static NSColor *sMainBorderColor = nil;
static NSColor *sNonMainBorderColor = nil;

@interface TDUberView ()
@property (nonatomic, retain) NSView *midSuperview;
@end

@interface TDUberViewSplitView ()
- (void)drawLeftDividerInRect:(NSRect)divRect;
- (void)drawRightDividerInRect:(NSRect)divRect;
- (void)drawVertDivotInRect:(NSRect)divRect;
- (void)drawHorizDivotInRect:(NSRect)divRect;
@end

@implementation TDUberViewSplitView

+ (void)initialize {
    if ([TDUberViewSplitView class] == self) {

        NSColor *black = [NSColor colorWithDeviceWhite:.3 alpha:1];
        NSColor *gray = [NSColor colorWithDeviceWhite:.85 alpha:1];
        NSColor *white = [NSColor colorWithDeviceWhite:1 alpha:1];
        sDivotGradient = [[NSGradient alloc] initWithColors:[NSArray arrayWithObjects:black, gray, white, nil]];

        if (TDIsYozOrLater()) {
            sMainBorderColor = [TDHexColor(0x9E9E9E) retain];
            sNonMainBorderColor = [TDHexColor(0xBBBBBB) retain];
        } else {
            sMainBorderColor = [[NSColor colorWithDeviceWhite:0.48 alpha:1.0] retain];
            sNonMainBorderColor = [[NSColor colorWithDeviceWhite:0.7 alpha:1.0] retain];
        }
    }
}


- (id)initWithFrame:(NSRect)frame uberView:(TDUberView *)uv {
    if (self = [super initWithFrame:frame]) {
        self.uberView = uv;
        self.borderColor = [NSColor colorWithDeviceWhite:0.4 alpha:1.0];
    }
    return self;
}


- (void)dealloc {
    self.uberView = nil;
    self.gradient = nil;
    self.borderColor = nil;
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (CGFloat)dividerThickness {
    CGFloat result = [super dividerThickness];

    if (NSSplitViewDividerStyleThick == [uberView splitViewDividerStyle]) {
        if (result > 2.0) {
            result -= 2.0;
        }
    }
    
    return result;
}


- (void)drawDividerInRect:(NSRect)divRect {
    if (NSSplitViewDividerStyleThin == [uberView splitViewDividerStyle]) {
        NSColor *c = [[self window] isMainWindow] ? sMainBorderColor : sNonMainBorderColor;
        [c setFill];
        NSRectFill(divRect);
        return;
    }
    
    BOOL isVert = self.isVertical;

    if (isVert) {
        // blend the vert and horiz dividers together
        BOOL isLeft = NSMinX(divRect) <= NSMaxX([uberView.leftView frame]);
        if (isLeft && uberView.isLeftViewOpen) {
            [self.gradient drawInRect:divRect angle:0.0];
            [self drawLeftDividerInRect:divRect];
            [self drawVertDivotInRect:divRect];
        } else if (uberView.isRightViewOpen) {
            [self.gradient drawInRect:divRect angle:180.0];
            [self drawRightDividerInRect:divRect];
            [self drawVertDivotInRect:divRect];
        }
    } else {        
        BOOL isTop = NSMinY(divRect) <= NSMidY([uberView.midSuperview frame]);
        if ((isTop && uberView.isTopViewOpen) || (!isTop && uberView.isBottomViewOpen)) {
            [self.gradient drawInRect:divRect angle:90.0];
            [borderColor set];
            
            NSRect borderRect = NSOffsetRect(divRect, -1.0, 0.0);
            borderRect.size.width += 2.0;

//            [NSBezierPath strokeRect:borderRect];
            CGRect cgrect = NSRectToCGRect(borderRect);
            CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
            CGContextStrokeRectWithWidth(ctx, cgrect, 1.0);
            
            // cover up rendering glitch
            borderRect = NSOffsetRect(divRect, -1.0, -.05);
            borderRect.size.width += 2.0;
            borderRect.size.height += 1.0;
            [[NSColor whiteColor] set];
//            [NSBezierPath strokeRect:borderRect];
            cgrect = NSRectToCGRect(borderRect);
            CGContextStrokeRectWithWidth(ctx, cgrect, 1.0);
            
            //[self drawHorizDivotInRect:borderRect];
        }
    }
}


- (NSGradient *)gradient {
    if (!gradient) {
        NSColor *startColor = nil;
        NSColor *endColor = nil;
        
        if (self.isVertical) {
            startColor = [NSColor colorWithDeviceWhite:0.95 alpha:1.0];
            endColor = [NSColor colorWithDeviceWhite:0.80 alpha:1.0];
        } else {
            startColor = [NSColor colorWithDeviceWhite:0.86 alpha:1.0];
            endColor = [NSColor colorWithDeviceWhite:0.83 alpha:1.0];
        }
        self.gradient = [[[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor] autorelease];
    }
    return gradient;    
}


#pragma mark -
#pragma mark Private

- (void)drawVertDivotInRect:(NSRect)divRect {
    CGFloat x = divRect.origin.x + divRect.size.width / 2.0 - DIVOT_SIDE / 2.0;
    CGFloat y = divRect.size.height / 2.0 - DIVOT_SIDE / 2.0;
    
    NSRect divotRect = NSMakeRect(x, y, DIVOT_SIDE, DIVOT_SIDE);
    
    //    NSLog(@"divRect %@", NSStringFromRect(divRect));
    //    NSLog(@"divotRect %@", NSStringFromRect(divotRect));
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundRect:divotRect xRadius:DIVOT_SIDE*0.5 yRadius:DIVOT_SIDE*0.5 corners:TDCornersAll];
    [sDivotGradient drawInBezierPath:path angle:70.0];
}


- (void)drawHorizDivotInRect:(NSRect)divRect {
    CGFloat x = divRect.size.width / 2.0 - DIVOT_SIDE / 2.0;
    CGFloat y = divRect.origin.y + divRect.size.height / 2.0 - DIVOT_SIDE / 2.0;
    
    NSRect divotRect = NSMakeRect(x, y, DIVOT_SIDE, DIVOT_SIDE);
    
    //    NSLog(@"divRect %@", NSStringFromRect(divRect));
    //    NSLog(@"divotRect %@", NSStringFromRect(divotRect));
    
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundRect:divotRect xRadius:DIVOT_SIDE*0.5 yRadius:DIVOT_SIDE*0.5 corners:TDCornersAll];
    [sDivotGradient drawInBezierPath:path angle:70.0];
}


- (void)drawLeftDividerInRect:(NSRect)divRect {
    CGFloat divThickness = [self dividerThickness];

    NSRect borderRect = NSOffsetRect(divRect, 0.0, -1.0);
    borderRect.size.height += 2.0;
    
//    NSBezierPath *path = [NSBezierPath bezierPath];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(ctx, 1.0);

    CGContextBeginPath(ctx);
//    [path moveToPoint:NSMakePoint(NSMaxX(borderRect), NSMinY(borderRect))];
    CGContextMoveToPoint(ctx, NSMaxX(borderRect), NSMinY(borderRect));
    
    CGFloat topHeight = 0.0;
    BOOL isTopViewOpen = uberView.isTopViewOpen;
    if (isTopViewOpen) {
        topHeight = NSHeight([uberView.topView frame]);
//        [path lineToPoint:NSMakePoint(NSMaxX(borderRect), topHeight)];
        CGContextAddLineToPoint(ctx, NSMaxX(borderRect), topHeight);

//        [path moveToPoint:NSMakePoint(NSMaxX(borderRect), topHeight + divThickness)];
        CGContextMoveToPoint(ctx, NSMaxX(borderRect), topHeight + divThickness);
    }
    
    if (uberView.isBottomViewOpen) {
        CGFloat y = topHeight + NSMaxY([uberView.midView frame]) + (isTopViewOpen ? divThickness : 0.0);
//        [path lineToPoint:NSMakePoint(NSMaxX(borderRect), y)];
        CGContextAddLineToPoint(ctx, NSMaxX(borderRect), y);
//        [path moveToPoint:NSMakePoint(NSMaxX(borderRect), y + divThickness)];
        CGContextMoveToPoint(ctx, NSMaxX(borderRect), y + divThickness);
    }
    
//    [path lineToPoint:NSMakePoint(NSMaxX(borderRect), NSMaxY(borderRect))];
    CGContextAddLineToPoint(ctx, NSMaxX(borderRect), NSMaxY(borderRect));
//    [path moveToPoint:NSMakePoint(NSMinX(borderRect), NSMaxY(borderRect))];
    CGContextMoveToPoint(ctx, NSMinX(borderRect), NSMaxY(borderRect));
//    [path lineToPoint:NSMakePoint(NSMinX(borderRect), NSMinY(borderRect))];
    CGContextAddLineToPoint(ctx, NSMinX(borderRect), NSMinY(borderRect));
    
    [borderColor setStroke];
//    [path stroke];
    
    CGContextStrokePath(ctx);
}


- (void)drawRightDividerInRect:(NSRect)divRect {
    CGFloat divThickness = [self dividerThickness];
    
    NSRect borderRect = NSOffsetRect(divRect, 0.0, -1.0);
    borderRect.size.height += 2.0;
    
//    NSBezierPath *path = [NSBezierPath bezierPath];
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth(ctx, 1.0);

    CGContextBeginPath(ctx);
//    [path moveToPoint:NSMakePoint(NSMinX(borderRect), NSMinY(borderRect))];
    CGContextMoveToPoint(ctx, NSMinX(borderRect), NSMinY(borderRect));
    
    CGFloat topHeight = 0.0;
    BOOL isTopViewOpen = uberView.isTopViewOpen;
    if (isTopViewOpen) {
        topHeight = NSHeight([uberView.topView frame]);
//        [path lineToPoint:NSMakePoint(NSMinX(borderRect), topHeight)];
        CGContextAddLineToPoint(ctx, NSMinX(borderRect), topHeight);
//        [path moveToPoint:NSMakePoint(NSMinX(borderRect), topHeight + divThickness)];
        CGContextMoveToPoint(ctx, NSMinX(borderRect), topHeight + divThickness);
    }
    
    if (uberView.isBottomViewOpen) {
        CGFloat y = topHeight + NSMaxY([uberView.midView frame]) + (isTopViewOpen ? divThickness : 0.0);
//        [path lineToPoint:NSMakePoint(NSMinX(borderRect), y)];
        CGContextAddLineToPoint(ctx, NSMinX(borderRect), y);
//        [path moveToPoint:NSMakePoint(NSMinX(borderRect), y + divThickness)];
        CGContextMoveToPoint(ctx, NSMinX(borderRect), y + divThickness);
    }
    
//    [path lineToPoint:NSMakePoint(NSMinX(borderRect), NSMaxY(borderRect))];
    CGContextAddLineToPoint(ctx, NSMinX(borderRect), NSMaxY(borderRect));
//    [path moveToPoint:NSMakePoint(NSMaxX(borderRect), NSMaxY(borderRect))];
    CGContextMoveToPoint(ctx, NSMaxX(borderRect), NSMaxY(borderRect));
//    [path lineToPoint:NSMakePoint(NSMaxX(borderRect), NSMinY(borderRect))];
    CGContextAddLineToPoint(ctx, NSMaxX(borderRect), NSMinY(borderRect));
    
    [borderColor setStroke];
//    [path stroke];
    CGContextStrokePath(ctx);
}

@synthesize uberView;
@synthesize borderColor;
@synthesize gradient;
@end
