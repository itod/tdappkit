//
//  TDTabListItemStyle.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/3/12.
//  Copyright (c) 2012 Celestial Teapot Software. All rights reserved.
//

#import "TDTabListItemStyle.h"

@implementation TDTabListItemStyle

+ (CGFloat)tabItemExtentForScrollSize:(NSSize)scrollSize isPortrait:(BOOL)isPortrait {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return 0.0;
}


+ (NSFont *)titleFont {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return nil;
}


+ (NSTextAlignment)titleTextAlignment {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return NSLeftTextAlignment;
}


- (NSRect)tabListItem:(TDTabListItem *)item borderRectForBounds:(NSRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return NSZeroRect;
}


- (NSRect)tabListItem:(TDTabListItem *)item titleRectForBounds:(NSRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return NSZeroRect;
}


- (NSRect)tabListItem:(TDTabListItem *)item closeButtonRectForBounds:(NSRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return NSZeroRect;
}


- (NSRect)tabListItem:(TDTabListItem *)item progressIndicatorRectForBounds:(NSRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return NSZeroRect;
}


- (NSRect)tabListItem:(TDTabListItem *)item thumbnailRectForBounds:(NSRect)bounds {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return NSZeroRect;
}


- (void)layoutSubviewsInTabListItem:(TDTabListItem *)item {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
}


- (void)drawTabListItem:(TDTabListItem *)item inContext:(CGContextRef)ctx {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
}

@end
