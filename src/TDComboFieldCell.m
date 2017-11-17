//
//  TDComboFieldCell.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 6/7/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDComboFieldCell.h"
#import "TDComboFieldTextView.h"
#import <TDAppKit/TDComboField.h>
#import <TDAppKit/TDUtils.h>

#define IMAGE_MARGIN 4.0
#define FUDGE_Y 0.0
#define BORDER_RADIUS 5.0

@implementation TDComboFieldCell

- (id)initImageCell:(NSImage *)img {
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (id)initTextCell:(NSString *)s {
    self = [super initTextCell:s];
    if (self) {
        
    }
    return self;
}


- (void)dealloc {
    self.favicon = nil;
    [super dealloc];
}


- (BOOL)drawsBackground {
    return NO;
}


#pragma mark -
#pragma mark Image

- (CGRect)imageFrameForCellFrame:(CGRect)cellFrame {
    CGRect r = CGRectZero;
    
    if (self.favicon) {
        CGSize imgSize = [self.favicon size];
        CGFloat x = NSMinX(cellFrame) + IMAGE_MARGIN;
        CGFloat y = floor(NSMidY(cellFrame) - imgSize.height*0.5);
        
        r = CGRectMake(x, y, imgSize.width, imgSize.height);
    }
    
    return r;
}


- (CGRect)borderRectForCellFrame:(CGRect)cellFrame {
    return CGRectMake(TDRoundAlign(cellFrame.origin.x), TDRoundAlign(cellFrame.origin.y), cellFrame.size.width -= 1.0, cellFrame.size.height -= 1.0);
}


#pragma mark -
#pragma mark Editing

- (void)selectWithFrame:(CGRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)object start:(NSInteger)selStart length:(NSInteger)selLength {
    // Divide frame
    CGRect textFrame, imageFrame, buttonFrame;
    if (self.favicon) {
        NSDivideRect(rect, &imageFrame, &textFrame, IMAGE_MARGIN + [self.favicon size].width, NSMinXEdge);
    } else {
        textFrame = rect;
        imageFrame = CGRectZero;
    }
    
    buttonFrame = [(TDComboField*)controlView buttonFrame];
    textFrame.size.width -= buttonFrame.size.width + 2;
    textFrame.origin.y -= FUDGE_Y;

    [super selectWithFrame:textFrame
                    inView:controlView 
                    editor:textObj 
                  delegate:object 
                     start:selStart 
                    length:selLength];
}


- (void)editWithFrame:(CGRect)rect inView:(NSView *)cv editor:(NSText *)text delegate:(id)del event:(NSEvent *)evt {
    
    // Divide frame
    CGRect  textFrame, imageFrame, buttonFrame;
    if (self.favicon) {
        NSDivideRect(rect, &imageFrame, &textFrame, IMAGE_MARGIN + [self.favicon size].width, NSMinXEdge);
    } else {
        textFrame = rect;
        imageFrame = CGRectZero;
    }
    
    buttonFrame = [(id)cv buttonFrame];
    textFrame.size.width -= buttonFrame.size.width + 2;
    textFrame.origin.y -= FUDGE_Y;
    
    [super editWithFrame:textFrame inView:cv editor:text delegate:del event:evt];
}


#pragma mark -
#pragma mark Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)cv {
//    [[NSColor redColor] setFill];
//    NSRectFill(cellFrame);
//
    [[NSColor colorWithWhite:0.65 alpha:1.0] setStroke];
    [[NSColor whiteColor] setFill];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    CGRect borderRect = [self borderRectForCellFrame:cellFrame];
    TDAddRoundRect(ctx, borderRect, BORDER_RADIUS);
    
    CGContextSetLineWidth(ctx, 1.0);
    CGContextDrawPath(ctx, kCGPathFillStroke);

    [self drawInteriorWithFrame:cellFrame inView:cv];
}


- (void)drawInteriorWithFrame:(CGRect)cellFrame inView:(NSView *)cv {
    CGRect txtFrame = cellFrame;

    TDAssert(self.favicon);
    // Draw image
    if (self.favicon) {
        CGRect imgFrame;
        CGSize imgSize = [self.favicon size];
        NSDivideRect(cellFrame, &imgFrame, &txtFrame, IMAGE_MARGIN+imgSize.width, NSMinXEdge);
        txtFrame.origin.y -= FUDGE_Y;
        
        CGRect iconRect = [self imageFrameForCellFrame:cellFrame];
        CGRect srcRect = CGRectMake(0.0, 0.0, imgSize.width, imgSize.height);
        TDAssert(cv);
        CGFloat alpha = [[cv window] isMainWindow] ? 1.0 : 0.65;
        
//        [[NSColor blackColor] setFill]; NSRectFill(iconRect);
        [self.favicon drawInRect:iconRect fromRect:srcRect operation:NSCompositingOperationSourceOver fraction:alpha respectFlipped:YES hints:@{NSImageHintInterpolation: @(NSImageInterpolationHigh)}];
    }
    [super drawInteriorWithFrame:txtFrame inView:cv];
}


- (CGSize)cellSize {
    CGSize cellSize = [super cellSize];
    cellSize.width += (self.favicon ? [self.favicon size].width : 0) + IMAGE_MARGIN;
    return cellSize;
}


- (void)drawFocusRingMaskWithFrame:(NSRect)cellFrame inView:(NSView *)cv {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    CGRect borderRect = [self borderRectForCellFrame:cellFrame];
    borderRect = CGRectInset(borderRect, -0.5, -0.5);
    TDAddRoundRect(ctx, borderRect, BORDER_RADIUS);
    
    CGContextFillPath(ctx);
}


//- (void)_drawFocusRingWithFrame:(CGRect)rect
//{
//    if (self.favicon) {
//        rect.origin.x -= [self.favicon size].width + IMAGE_MARGIN;
//        rect.size.width += [self.favicon size].width + IMAGE_MARGIN;
//    }
//
//    CGRect  buttonFrame;
//    buttonFrame = [(TDComboField*)[self controlView] buttonFrame];
//    if (buttonFrame.size.width > 0) {
//        rect.size.width += buttonFrame.size.width + 2;
//    }
//
////    rect = NSInsetRect(rect, 1.0, 1.0);
////    [super _drawFocusRingWithFrame:rect];
//}


#pragma mark -
#pragma mark Dragging

- (NSImage *)imageForDraggingWithFrame:(CGRect)cellFrame inView:(NSView *)controlView {
    // Create image
    NSImage *result = [[[NSImage alloc] initWithSize:cellFrame.size] autorelease];
    
    // Create attributed string
    CGFloat alpha = 0.7;
    NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithAttributedString:[self attributedStringValue]] autorelease];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[NSColor colorWithCalibratedWhite:0.0 alpha:alpha]
                    range:NSMakeRange(0, [attrStr length])];
    
    // Draw cell
    [result lockFocus];
    [result drawAtPoint:CGPointZero fromRect:cellFrame operation:NSCompositingOperationSourceOver fraction:1.0];
    NSImage *favicon = self.favicon;
    CGSize faviconSize = favicon.size;
    CGRect srcRect = NSMakeRect(0.0, 0.0, faviconSize.width, faviconSize.height);
    NSPoint destPoint = CGPointZero;
    [favicon drawAtPoint:destPoint fromRect:srcRect operation:NSCompositingOperationSourceOver fraction:alpha];
    
    NSPoint p = NSMakePoint(faviconSize.width + IMAGE_MARGIN, 0.0);
    [attrStr drawAtPoint:p];
    [result unlockFocus];
    
    return result;
}


- (BOOL)imageTrackMouse:(NSEvent*)event 
                 inRect:(CGRect)cellFrame
                 ofView:(NSView*)controlView 
{
    // Check mouse is in image or not
    CGRect  imageFrame;
    NSPoint point;
    
    imageFrame = [self imageFrameForCellFrame:cellFrame];
    
    point = [controlView convertPoint:[event locationInWindow] fromView:nil];
    
    if (NSPointInRect(point, imageFrame)) {        
        return YES;
    }
    
    return NO;
}

- (void)resetCursorRect:(CGRect)cellFrame
                 inView:(NSView*)controlView
{
    CGRect  textFrame;
    CGRect  imageFrame;
    NSDivideRect(
                 cellFrame, &imageFrame, &textFrame, IMAGE_MARGIN + [self.favicon size].width, NSMinXEdge);
    [super resetCursorRect:textFrame inView:controlView];
}

@end
