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

#import <TDAppKit/TDGutterView.h>

@interface TDGutterView ()
@property (nonatomic, retain) NSDictionary *attrs;
@property (nonatomic, retain) NSDictionary *hiAttrs;
@end

@implementation TDGutterView

- (void)awakeFromNib {
    self.attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSFont userFixedPitchFontOfSize:11.0], NSFontAttributeName,
                  [NSColor grayColor], NSForegroundColorAttributeName,
                  nil];
    
    self.hiAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                  [NSFont userFixedPitchFontOfSize:11.0], NSFontAttributeName,
                  [NSColor blackColor], NSForegroundColorAttributeName,
                  nil];
    
    self.color = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
    self.borderColor = [NSColor grayColor];
    self.lineNumberRects = [NSArray arrayWithObject:[NSValue valueWithRect:NSMakeRect(0.0, 0.0, 100.0, 14.0)]];
}


- (void)dealloc {
    self.sourceScrollView = nil;
    self.sourceTextView = nil;
    self.lineNumberRects = nil;
    self.attrs = nil;
    self.hiAttrs = nil;
    self.borderColor = nil;
    [super dealloc];
}


- (BOOL)isFlipped {
    return YES;
}


- (NSUInteger)autoresizingMask {
    return NSViewHeightSizable;
}


- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    NSRect bounds = [self bounds];
    
    CGFloat boundsWidth = bounds.size.width;
    
    [self.color setFill];
    NSRectFill(bounds);

    // stroke vert line
    [borderColor set];
    CGContextSetLineWidth(ctx, 1.0);

    CGPoint p1 = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    CGPoint p2 = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, p1.x, p1.y);
    CGContextAddLineToPoint(ctx, p2.x, p2.y);
    CGContextStrokePath(ctx);

    // stroke horiz top line
//    p1 = CGPointMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds));
//    p2 = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
//    
//    CGContextMoveToPoint(ctx, p1.x, p1.y);
//    CGContextAddLineToPoint(ctx, p2.x, p2.y);
//    CGContextClosePath(ctx);
//    CGContextStrokePath(ctx);
    
//    NSPoint p1 = NSMakePoint(boundsWidth, 0);
//    NSPoint p2 = NSMakePoint(boundsWidth, bounds.size.height);
//    [NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
    
    if (![lineNumberRects count]) {
        return;
    }
    
    NSUInteger i = startLineNumber;
    NSUInteger count = i + [lineNumberRects count];
    
    for ( ; i < count; i++) {
        NSRect r = [[lineNumberRects objectAtIndex:i - startLineNumber] rectValue];

        // set the x origin of the number according to the number of digits it contains
        CGFloat x = 0.0;
        if (i < 9) {
            x = boundsWidth - 14.0;
        } else if (i < 99) {
            x = boundsWidth - 21.0;
        } else if (i < 999) {
            x = boundsWidth - 28.0;
        } else if (i < 9999) {
            x = boundsWidth - 35.0;
        }
        r.origin.x = x;
        
        // center the number vertically for tall lines
        if (r.origin.y) {
            r.origin.y += r.size.height/2.0 - 7.0;
        }
        
        NSUInteger displayIdx = i + 1;
        BOOL isHi = displayIdx == highlightedLineNumber;
        
        NSString *s = [[NSNumber numberWithInteger:displayIdx] stringValue];
        
        NSDictionary *currAttrs = nil;
        if (isHi) {
            currAttrs = hiAttrs;
            
            NSRect hiRect = NSMakeRect(NSMinX(bounds), round(r.origin.y + 3.0) + 0.5, boundsWidth, round(r.size.height));
            
            // fill highlight
            [[NSColor lightGrayColor] setFill];
            NSRectFill(hiRect);
            
            // stroke highlight
            [[NSColor grayColor] setStroke];

            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, NSMinX(hiRect), NSMinY(hiRect));
            CGContextAddLineToPoint(ctx, NSMaxX(hiRect), NSMinY(hiRect));
            CGContextStrokePath(ctx);

            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, NSMinX(hiRect), NSMaxY(hiRect));
            CGContextAddLineToPoint(ctx, NSMaxX(hiRect), NSMaxY(hiRect));
            CGContextStrokePath(ctx);
        } else {
            currAttrs = attrs;
        }
        
        NSAttributedString *as = [[[NSAttributedString alloc] initWithString:s attributes:currAttrs] autorelease];
        [as drawAtPoint:r.origin];        
    }
}

@synthesize sourceScrollView;
@synthesize sourceTextView;
@synthesize lineNumberRects;
@synthesize startLineNumber;
@synthesize highlightedLineNumber;
@synthesize attrs;
@synthesize hiAttrs;
@synthesize borderColor;
@end
