//
//  TDTabListItemStyleBrowser.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/3/12.
//  Copyright (c) 2012 Celestial Teapot Software. All rights reserved.
//

#import "TDTabListItemStyleBrowser.h"
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabListItem.h>
#import <TDAppKit/TDUtils.h>
#import <TDAppKit/NSImage+TDAdditions.h>

#define NORMAL_RADIUS 4.0
#define SMALL_RADIUS 3.0
#define BGCOLOR_INSET 2.0
#define THUMBNAIL_DIFF 0.0

static NSDictionary *sSelectedTitleAttrs = nil;
static NSDictionary *sTitleAttrs = nil;

static NSGradient *sSelectedOuterRectFillGradient = nil;
static NSGradient *sInnerRectFillGradient = nil;

static NSColor *sSelectedOuterRectStrokeColor = nil;

static NSColor *sSelectedInnerRectStrokeColor = nil;
static NSColor *sInnerRectStrokeColor = nil;

static NSImage *sProgressImage = nil;

static NSDictionary *sHints = nil;

@implementation TDTabListItemStyleBrowser

+ (void)initialize {
    if ([TDTabListItemStyleBrowser class] == self) {
        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSLeftTextAlignment];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:0.0 alpha:0.4]];
        [shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
        [shadow setShadowBlurRadius:0.0];
        
        sSelectedTitleAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSFont boldSystemFontOfSize:10.0], NSFontAttributeName,
                               [NSColor whiteColor], NSForegroundColorAttributeName,
                               paraStyle, NSParagraphStyleAttributeName,
                               shadow, NSShadowAttributeName,
                               nil];
        
        sTitleAttrs = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [NSFont boldSystemFontOfSize:10.0], NSFontAttributeName,
                       [NSColor colorWithDeviceWhite:0.3 alpha:1.0], NSForegroundColorAttributeName,
                       paraStyle, NSParagraphStyleAttributeName,
                       nil];
        
        // outer round rect fill
        NSColor *fillTopColor = [NSColor colorWithDeviceRed:134.0/255.0 green:147.0/255.0 blue:169.0/255.0 alpha:1.0];
        NSColor *fillBottomColor = [NSColor colorWithDeviceRed:108.0/255.0 green:120.0/255.0 blue:141.0/255.0 alpha:1.0];
        sSelectedOuterRectFillGradient = [[NSGradient alloc] initWithStartingColor:fillTopColor endingColor:fillBottomColor];
        
        sInnerRectFillGradient = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor whiteColor]];
        
        // outer round rect stroke
        sSelectedOuterRectStrokeColor = [[NSColor colorWithDeviceRed:91.0/255.0 green:100.0/255.0 blue:115.0/255.0 alpha:1.0] retain];
        
        // inner round rect stroke
        sSelectedInnerRectStrokeColor = [[sSelectedOuterRectStrokeColor colorWithAlphaComponent:0.8] retain];
        sInnerRectStrokeColor = [[NSColor colorWithDeviceWhite:0.7 alpha:1.0] retain];
        
        sProgressImage = [[NSImage imageNamed:@"progress_indicator.png" inBundleForClass:self] retain];
        
        sHints = [[NSDictionary alloc] initWithObjectsAndKeys:
                  [NSNumber numberWithInteger:NSImageInterpolationHigh], NSImageHintInterpolation, 
                  nil];
    }
}


+ (CGFloat)tabItemExtentForScrollSize:(NSSize)scrollSize isPortrait:(BOOL)isPortrait {
#define ASPECT_RATIO 1.0

    CGFloat extent = 0.0;
    
    if (isPortrait) {
        extent = floor(scrollSize.width * ASPECT_RATIO);
    } else {
        extent = floor(scrollSize.height * 1 / ASPECT_RATIO);
    }

    return extent;
}


+ (NSFont *)titleFont {
    return [sTitleAttrs objectForKey:NSFontAttributeName];
}


+ (NSTextAlignment)titleTextAlignment {
    return NSLeftTextAlignment;
}


- (NSRect)tabListItem:(TDTabListItem *)item borderRectForBounds:(NSRect)bounds {
    NSRect r = NSInsetRect(bounds, 2.5, 1.5);
    return r;
}


- (NSRect)tabListItem:(TDTabListItem *)item closeButtonRectForBounds:(NSRect)bounds {
    NSRect r = NSMakeRect(7.0, 5.0, 10.0, 10.0);
    return r;
}


- (NSRect)tabListItem:(TDTabListItem *)item titleRectForBounds:(NSRect)bounds {
    NSRect r = NSInsetRect(bounds, 13.5, 3.5);
    r.size.height = 13.0;
    
    if (item.showsCloseButton) {
        r.origin.x += 8.0;
    }
    
    return r;
}


- (NSRect)tabListItem:(TDTabListItem *)item progressIndicatorRectForBounds:(NSRect)bounds {
    NSSize size = [item.progressIndicator bounds].size;
    NSRect r = NSMakeRect(NSMaxX(bounds) - 26.0, 20.0, size.width, size.height);
    return r;
}


- (NSRect)tabListItem:(TDTabListItem *)item thumbnailRectForBounds:(NSRect)bounds {
    NSRect r = NSInsetRect(bounds, 6.5, 5.5);
    r = NSOffsetRect(r, 0.0, 12.0);
    r.size.height -= 10.0;
    
    r.size.width = floor(r.size.width - THUMBNAIL_DIFF);
    r.size.height = floor(r.size.height - THUMBNAIL_DIFF);
    
    return r;
}


- (void)layoutSubviewsInTabListItem:(TDTabListItem *)item {
    NSRect bounds = [item bounds];
    if (item.showsCloseButton) {
        [item.closeButton setFrame:[self tabListItem:item closeButtonRectForBounds:bounds]];
    }
    if (item.showsProgressIndicator) {
        [item.progressIndicator sizeToFit];
        [item.progressIndicator setFrameOrigin:[self tabListItem:item progressIndicatorRectForBounds:bounds].origin];
    }
}


- (void)drawTabListItem:(TDTabListItem *)item inContext:(CGContextRef)ctx {
    NSRect bounds = [item bounds];
    TDTabModel *tabModel = item.tabModel;
    
    // outer round rect
    if (bounds.size.width < 24.0) return; // dont draw anymore when you're really small. looks bad.
    
    NSRect borderRect = [self tabListItem:item borderRectForBounds:bounds];
    
    if (tabModel.isSelected) {
        CGFloat radius = (bounds.size.width < 32.0) ? SMALL_RADIUS : NORMAL_RADIUS;
        TDDrawRoundRect(borderRect, radius, 1.0, sSelectedOuterRectFillGradient, sSelectedOuterRectStrokeColor);
    }
    
    // title
    if (bounds.size.width < 40.0) return; // dont draw anymore when you're really small. looks bad.
    
    NSRect titleRect = [self tabListItem:item titleRectForBounds:bounds];
    NSUInteger opts = NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin;
    NSDictionary *attrs = tabModel.isSelected ? sSelectedTitleAttrs : sTitleAttrs;
    [tabModel.title drawWithRect:titleRect options:opts attributes:attrs];
    
    // inner round rect
    if (bounds.size.width < 55.0) return; // dont draw anymore when you're really small. looks bad.
    
    NSRect thumbRect = [self tabListItem:item thumbnailRectForBounds:bounds];
    NSSize thumbSize = thumbRect.size;

    // put white behind the image
    NSColor *strokeColor = tabModel.isSelected ? sSelectedInnerRectStrokeColor : sInnerRectStrokeColor;
    //TDDrawRoundRect(thumbRect, NORMAL_RADIUS, 1.0, sInnerRectFillGradient, strokeColor);

    // draw image
    if (bounds.size.width < 64.0) return; // dont draw anymore when you're really small. looks bad.
    
    NSImage *img = tabModel.image;
    if (!img) return;
    
    NSSize imgSize = [img size];
    NSSize scaledImgSize = imgSize;
    
//    BOOL isPortrait = imgSize.height > imgSize.width;
    CGFloat ratio = 0.0;
    
//    if (isPortrait) {
        ratio = (thumbSize.width / imgSize.width);
        scaledImgSize.width *= ratio;
        scaledImgSize.height *= ratio;
//        NSAssert(scaledImgSize.height > scaledImgSize.width, @"");
//    } else {
//        ratio = (thumbSize.height / imgSize.height);
//        scaledImgSize.width *= ratio;
//        scaledImgSize.height *= ratio;
//        NSAssert(scaledImgSize.width > scaledImgSize.height, @"");
//    }

    NSImage *scaledImg = tabModel.scaledImage;
    if (!scaledImg || !NSEqualSizes(scaledImgSize, imgSize)) {
        
        [img setFlipped:[item isFlipped]];
        
        scaledImg = [img scaledImageOfSize:scaledImgSize alpha:1.0 hiRez:YES cornerRadius:NORMAL_RADIUS];
        tabModel.scaledImage = scaledImg;
    }
            
    if (!scaledImg) {
        return;
    }
    
    NSRect srcRect = NSMakeRect(0.0, 0.0, imgSize.width, imgSize.height);
    NSRect scaledSrcRect = NSMakeRect(0.0, 0.0, scaledImgSize.width, scaledImgSize.height);

//    if (isPortrait) {
        srcRect.size.height = thumbSize.height / ratio;
        scaledSrcRect.size.height = thumbSize.height;
//    } else {
//        srcRect.size.width = thumbSize.width / ratio;
//        scaledSrcRect.size.width = thumbSize.width;
//    }
    
    NSRect destRect = thumbRect;
    
//    [img drawInRect:destRect fromRect:srcRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:sHints];
    [scaledImg drawInRect:destRect fromRect:scaledSrcRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:NO hints:sHints];
    
    // stroke again over image
    TDDrawRoundRect(thumbRect, NORMAL_RADIUS, 1.0, nil, strokeColor);
    
    if (item.showsCloseButton) {
        [item.closeButton setNeedsDisplay:YES];
    }
    
    if (item.showsProgressIndicator) {
        if (tabModel.isBusy) {
            [item.progressIndicator startAnimation:self];
        } else {
            [item.progressIndicator stopAnimation:self];
        }
        
        [item.progressIndicator setNeedsDisplay:YES];
    }
}

@end
