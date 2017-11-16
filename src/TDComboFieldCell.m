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

#define IMAGE_MARGIN 2.0
#define FUDGE_Y 1.0

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
    self.image = nil;
    [super dealloc];
}


- (BOOL)drawsBackground {
    return NO;
}


#pragma mark -
#pragma mark Image

- (CGRect)imageFrameForCellFrame:(CGRect)cellFrame {
    if (self.image) {
        CGRect imageFrame;
        imageFrame.size = [self.image size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    } else {
        return CGRectZero;
    }
}


#pragma mark -
#pragma mark Editing

- (void)selectWithFrame:(CGRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)object start:(NSInteger)selStart length:(NSInteger)selLength {
    // Divide frame
    CGRect textFrame, imageFrame, buttonFrame;
    if (self.image) {
        NSDivideRect(rect, &imageFrame, &textFrame, IMAGE_MARGIN + [self.image size].width, NSMinXEdge);
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


- (void)editWithFrame:(CGRect)rect inView:(NSView *)controlView editor:(NSText*)textObj delegate:(id)object event:(NSEvent *)event {
    // Divide frame
    CGRect  textFrame, imageFrame, buttonFrame;
    if (self.image) {
        NSDivideRect(rect, &imageFrame, &textFrame, IMAGE_MARGIN + [self.image size].width, NSMinXEdge);
    } else {
        textFrame = rect;
        imageFrame = CGRectZero;
    }
    
    buttonFrame = [(TDComboField *)controlView buttonFrame];
    textFrame.size.width -= buttonFrame.size.width + 2;
    textFrame.origin.y -= FUDGE_Y;
    
    [super editWithFrame:textFrame
                  inView:controlView 
                  editor:textObj 
                delegate:object 
                   event:event];
}

//--------------------------------------------------------------//
#pragma mark -- Drawing --
//--------------------------------------------------------------//

- (void)drawInteriorWithFrame:(CGRect)cellFrame
                       inView:(NSView*)controlView
{
    CGRect txtFrame = cellFrame;

    TDAssert(self.image);
    // Draw image
    if (self.image) {
        CGRect imgFrame;
        CGSize imgSize = [self.image size];
        NSDivideRect(cellFrame, &imgFrame, &txtFrame, IMAGE_MARGIN+imgSize.width, NSMinXEdge);
        txtFrame.origin.y -= FUDGE_Y;
        
        CGRect iconRect = CGRectMake(NSMinX(cellFrame)+IMAGE_MARGIN+1.0, floor(NSMidY(cellFrame) - imgSize.height*0.5), imgSize.width, imgSize.height);
        CGRect srcRect = CGRectMake(0.0, 0.0, imgSize.width, imgSize.height);
        TDAssert(controlView);
        CGFloat alpha = [[controlView window] isMainWindow] ? 1.0 : 0.65;
        [self.image drawInRect:iconRect fromRect:srcRect operation:NSCompositingOperationSourceOver fraction:alpha respectFlipped:YES hints:@{NSImageHintInterpolation: @(NSImageInterpolationHigh)}];
    }
    [super drawInteriorWithFrame:txtFrame inView:controlView];
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (self.image ? [self.image size].width : 0) + IMAGE_MARGIN;
    return cellSize;
}

- (void)_drawFocusRingWithFrame:(CGRect)rect
{
    if (self.image) {
        rect.origin.x -= [self.image size].width + IMAGE_MARGIN;
        rect.size.width += [self.image size].width + IMAGE_MARGIN;
    }
    
    CGRect  buttonFrame;
    buttonFrame = [(TDComboField*)[self controlView] buttonFrame];
    if (buttonFrame.size.width > 0) {
        rect.size.width += buttonFrame.size.width + 2;
    }
    
//    rect = NSInsetRect(rect, 1.0, 1.0);
//    [super _drawFocusRingWithFrame:rect];
}


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
    [result drawAtPoint:NSZeroPoint fromRect:cellFrame operation:NSCompositingOperationSourceOver fraction:1.0];
    NSImage *favicon = self.image;
    NSSize faviconSize = favicon.size;
    CGRect srcRect = NSMakeRect(0.0, 0.0, faviconSize.width, faviconSize.height);
    NSPoint destPoint = NSZeroPoint;
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
                 cellFrame, &imageFrame, &textFrame, IMAGE_MARGIN + [self.image size].width, NSMinXEdge);
    [super resetCursorRect:textFrame inView:controlView];
}

@end
