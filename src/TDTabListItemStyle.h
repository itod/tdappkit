//
//  TDTabListItemStyle.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 5/3/12.
//  Copyright (c) 2012 Celestial Teapot Software. All rights reserved.
//

#import <TDAppKit/TDTabListItem.h>

@interface TDTabListItemStyle : NSObject {
    
}

+ (CGFloat)tabItemExtentForScrollSize:(NSSize)scrollSize isPortrait:(BOOL)isPortrait;
+ (NSFont *)titleFont;
+ (NSTextAlignment)titleTextAlignment;

- (NSRect)tabListItem:(TDTabListItem *)item borderRectForBounds:(NSRect)bounds;
- (NSRect)tabListItem:(TDTabListItem *)item titleRectForBounds:(NSRect)bounds;
- (NSRect)tabListItem:(TDTabListItem *)item closeButtonRectForBounds:(NSRect)bounds;
- (NSRect)tabListItem:(TDTabListItem *)item progressIndicatorRectForBounds:(NSRect)bounds;
- (NSRect)tabListItem:(TDTabListItem *)item thumbnailRectForBounds:(NSRect)bounds;

- (void)layoutSubviewsInTabListItem:(TDTabListItem *)item;
- (void)drawTabListItem:(TDTabListItem *)item inContext:(CGContextRef)ctx;
@end
