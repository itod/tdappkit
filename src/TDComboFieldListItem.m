//
//  TDComboFieldListItem.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/9/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDComboFieldListItem.h"
#import "NSBezierPath+TDAdditions.h"

#define LABEL_MARGIN_X 5.0
#define LABEL_MARGIN_Y 2.0

#define RADIUS 3.0

static NSDictionary *sLabelAttributes = nil;
static NSDictionary *sHighlightedLabelAttributes = nil;

@implementation TDComboFieldListItem

+ (void)initialize {
    if (self == [TDComboFieldListItem class]) {
        
//        NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
//        [shadow setShadowColor:[NSColor colorWithCalibratedWhite:1 alpha:.51]];
//        [shadow setShadowOffset:NSMakeSize(0, -1)];
//        [shadow setShadowBlurRadius:0];
        
        NSMutableParagraphStyle *paraStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
        [paraStyle setAlignment:NSTextAlignmentLeft];
        [paraStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        
        sLabelAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSColor blackColor], NSForegroundColorAttributeName,
                            //shadow, NSShadowAttributeName,
                            [NSFont boldSystemFontOfSize:12], NSFontAttributeName,
                            paraStyle, NSParagraphStyleAttributeName,
                            nil];
        
        sHighlightedLabelAttributes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                       [NSColor whiteColor], NSForegroundColorAttributeName,
                                       //shadow, NSShadowAttributeName,
                                       [NSFont boldSystemFontOfSize:12], NSFontAttributeName,
                                       paraStyle, NSParagraphStyleAttributeName,
                                       nil];
        
    }
}


+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}


+ (CGFloat)defaultHeight {
    return 20.0;
}


- (id)init {
    return [self initWithFrame:NSZeroRect reuseIdentifier:[[self class] reuseIdentifier]];
}


- (id)initWithFrame:(NSRect)r reuseIdentifier:(NSString *)s {
    if (self = [super initWithFrame:r reuseIdentifier:s]) {
        
    }
    return self;
}


- (void)dealloc {
    self.labelText = nil;
    [super dealloc];
}


- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];

    NSColor *bgColor = nil;
    NSDictionary *attrs = nil;
    if (selected) {
        attrs = sHighlightedLabelAttributes;
        bgColor = [NSColor selectedContentBackgroundColor];
    } else {
        attrs = sLabelAttributes;
        bgColor = [NSColor clearColor];
    }
    [bgColor setFill];

    NSBezierPath *path = nil;
    if (first && last) {
        path = [NSBezierPath bezierPathWithRoundRect:bounds xRadius:RADIUS yRadius:RADIUS corners:TDCornersAll];
    } else if (first) {
        path = [NSBezierPath bezierPathWithRoundRect:bounds xRadius:RADIUS yRadius:RADIUS corners:TDCornersTop];
    } else if (last) {
        path = [NSBezierPath bezierPathWithRoundRect:bounds xRadius:RADIUS yRadius:RADIUS corners:TDCornersBottom];
    } else {
        path = [NSBezierPath bezierPathWithRect:bounds];
    }
    [path fill];
    
    [labelText drawInRect:[self labelRectForBounds:bounds] withAttributes:attrs];
}


- (NSRect)labelRectForBounds:(NSRect)bounds {
    return NSMakeRect(LABEL_MARGIN_X + labelMarginLeft, LABEL_MARGIN_Y, bounds.size.width - (LABEL_MARGIN_X * 2.0) - labelMarginLeft, 16.0);
}

@synthesize labelText;
@synthesize selected;
@synthesize first;
@synthesize last;
@synthesize labelMarginLeft;
@end
