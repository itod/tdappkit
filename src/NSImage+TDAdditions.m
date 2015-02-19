//  Copyright 2010 Todd Ditchendorf
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

#import <TDAppKit/NSImage+TDAdditions.h>
#import <TDAppKit/TDUtils.h>

@implementation NSImage (TDAdditions)

+ (NSImage *)imageNamed:(NSString *)name inBundleForClass:(Class)cls {
    NSBundle *bundle = [NSBundle bundleForClass:cls];
    NSString *path = [bundle pathForImageResource:name];

    NSImage *image = nil;
    if ([path length]) {
        NSURL *URL = [NSURL fileURLWithPath:path];
        image = [[[NSImage alloc] initWithContentsOfURL:URL] autorelease];
    } 
    
    if (!image) {
        NSLog(@"%s couldnt load image named %@ in bundle %@\npath %@", __PRETTY_FUNCTION__, name, bundle, path);
    }
    
    return image;
}


- (NSImage *)scaledImageOfSize:(NSSize)size {
    return [self scaledImageOfSize:size alpha:1];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha {
    return [self scaledImageOfSize:size alpha:alpha hiRez:YES];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez {
    return [self scaledImageOfSize:size alpha:alpha hiRez:hiRez clip:nil];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez cornerRadius:(CGFloat)radius {
    NSBezierPath *path = TDGetRoundRect(NSMakeRect(0, 0, size.width, size.height), radius, 1);
    return [self scaledImageOfSize:size alpha:alpha hiRez:hiRez clip:path];
}


- (NSImage *)scaledImageOfSize:(NSSize)size alpha:(CGFloat)alpha hiRez:(BOOL)hiRez clip:(NSBezierPath *)path {
    NSImage *result = [[[NSImage alloc] initWithSize:size] autorelease];
    [result lockFocus];
    
    // get context
    NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
    
    // store previous state
    BOOL savedAntialias = [currentContext shouldAntialias];
    NSImageInterpolation savedInterpolation = [currentContext imageInterpolation];
    
    // set new state
    [currentContext setShouldAntialias:YES];
    [currentContext setImageInterpolation:hiRez ? NSImageInterpolationHigh : NSImageInterpolationDefault];
    
    // set clip
    [path setClip];
    
    // draw image
    NSSize fromSize = [self size];
    [self drawInRect:NSMakeRect(0, 0, size.width, size.height) fromRect:NSMakeRect(0, 0, fromSize.width, fromSize.height) operation:NSCompositeSourceOver fraction:alpha];
    
    // restore state
    [currentContext setShouldAntialias:savedAntialias];
    [currentContext setImageInterpolation:savedInterpolation];
    
    [result unlockFocus];
    return result;
}


- (void)drawStretchableInRect:(NSRect)rect edgeInsets:(TDEdgeInsets)insets operation:(NSCompositingOperation)op fraction:(CGFloat)delta {
    void (^makeAreas)(NSRect, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *, NSRect *) = ^(NSRect srcRect, NSRect *tl, NSRect *tc, NSRect *tr, NSRect *ml, NSRect *mc, NSRect *mr, NSRect *bl, NSRect *bc, NSRect *br) {
        CGFloat w = NSWidth(srcRect);
        CGFloat h = NSHeight(srcRect);
        CGFloat cw = (w - insets.left - insets.right);
        CGFloat ch = (h - insets.top - insets.bottom);
        
        CGFloat x0 = NSMinX(srcRect);
        CGFloat x1 = (x0 + insets.left);
        CGFloat x2 = (NSMaxX(srcRect) - insets.right);
        
        CGFloat y0 = NSMinY(srcRect);
        CGFloat y1 = (y0 + insets.bottom);
        CGFloat y2 = (NSMaxY(srcRect) - insets.top);
        
        *tl = NSMakeRect(x0, y2, insets.left, insets.top);
        *tc = NSMakeRect(x1, y2, cw, insets.top);
        *tr = NSMakeRect(x2, y2, insets.right, insets.top);
        
        *ml = NSMakeRect(x0, y1, insets.left, ch);
        *mc = NSMakeRect(x1, y1, cw, ch);
        *mr = NSMakeRect(x2, y1, insets.right, ch);
        
        *bl = NSMakeRect(x0, y0, insets.left, insets.bottom);
        *bc = NSMakeRect(x1, y0, cw, insets.bottom);
        *br = NSMakeRect(x2, y0, insets.right, insets.bottom);
    };
  
    // Source rects
    NSRect srcRect = (NSRect){NSZeroPoint, self.size};
    if (NSWidth(srcRect) <= 0.0 || NSHeight(srcRect) <= 0.0) {
        return;
    }
    
    NSRect srcTopL, srcTopC, srcTopR, srcMidL, srcMidC, srcMidR, srcBotL, srcBotC, srcBotR;
    makeAreas(srcRect, &srcTopL, &srcTopC, &srcTopR, &srcMidL, &srcMidC, &srcMidR, &srcBotL, &srcBotC, &srcBotR);

    // Destinations rects
    NSRect dstTopL, dstTopC, dstTopR, dstMidL, dstMidC, dstMidR, dstBotL, dstBotC, dstBotR;
    makeAreas(rect, &dstBotL, &dstBotC, &dstBotR, &dstMidL, &dstMidC, &dstMidR, &dstTopL, &dstTopC, &dstTopR);

    TDAssertMainThread();
    static NSDictionary *sImageHints = nil;
    if (!sImageHints) {
        sImageHints = [[NSDictionary alloc] initWithObjectsAndKeys:@(NSImageInterpolationHigh), NSImageHintInterpolation, nil];
    }
    
    BOOL flipped = YES;
    
    // this is necessary for non-retina devices to always draw the best rep. dunno why. shouldn't have to do this. :(
    NSImageRep *rep = [self bestRepresentationForRect:srcRect context:[NSGraphicsContext currentContext] hints:sImageHints];

    // Draw
//    [rep drawInRect:dstTopL fromRect:srcTopL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstTopC fromRect:srcTopC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstTopR fromRect:srcTopR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    
//    [rep drawInRect:dstMidL fromRect:srcMidL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstMidC fromRect:srcMidC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstMidR fromRect:srcMidR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    
//    [rep drawInRect:dstBotL fromRect:srcBotL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstBotC fromRect:srcBotC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstBotR fromRect:srcBotR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];

    if (NSWidth(dstTopL) > 0.0 && NSHeight(dstTopL) > 0.0 && NSWidth(srcTopL) > 0.0 && NSHeight(srcTopL) > 0.0) [rep drawInRect:dstTopL fromRect:srcTopL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    if (NSWidth(dstTopC) > 0.0 && NSHeight(dstTopC) > 0.0 && NSWidth(srcTopC) > 0.0 && NSHeight(srcTopC) > 0.0) [rep drawInRect:dstTopC fromRect:srcTopC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    if (NSWidth(dstTopR) > 0.0 && NSHeight(dstTopR) > 0.0 && NSWidth(srcTopR) > 0.0 && NSHeight(srcTopR) > 0.0) [rep drawInRect:dstTopR fromRect:srcTopR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    
    if (NSWidth(dstMidL) > 0.0 && NSHeight(dstMidL) > 0.0 && NSWidth(srcMidL) > 0.0 && NSHeight(srcMidL) > 0.0) [rep drawInRect:dstMidL fromRect:srcMidL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    if (NSWidth(dstMidC) > 0.0 && NSHeight(dstMidC) > 0.0 && NSWidth(srcMidC) > 0.0 && NSHeight(srcMidC) > 0.0) [rep drawInRect:dstMidC fromRect:srcMidC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    if (NSWidth(dstMidR) > 0.0 && NSHeight(dstMidR) > 0.0 && NSWidth(srcMidR) > 0.0 && NSHeight(srcMidR) > 0.0) [rep drawInRect:dstMidR fromRect:srcMidR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    
    if (NSWidth(dstBotL) > 0.0 && NSHeight(dstBotL) > 0.0 && NSWidth(srcBotL) > 0.0 && NSHeight(srcBotL) > 0.0) [rep drawInRect:dstBotL fromRect:srcBotL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    if (NSWidth(dstBotC) > 0.0 && NSHeight(dstBotC) > 0.0 && NSWidth(srcBotC) > 0.0 && NSHeight(srcBotC) > 0.0) [rep drawInRect:dstBotC fromRect:srcBotC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    if (NSWidth(dstBotR) > 0.0 && NSHeight(dstBotR) > 0.0 && NSWidth(srcBotR) > 0.0 && NSHeight(srcBotR) > 0.0) [rep drawInRect:dstBotR fromRect:srcBotR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
}


- (void)drawStretchableInRect:(NSRect)rect edgeInsets:(TDEdgeInsets)insets centerRect:(CGRect)centerRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta {
    void (^makeAreas)(NSRect,
                      NSRect *, NSRect *, NSRect *, NSRect *, NSRect *,
                      NSRect *, NSRect *, NSRect *, NSRect *, NSRect *,
                      NSRect *, NSRect *, NSRect *, NSRect *, NSRect *,
                      NSRect *, NSRect *, NSRect *, NSRect *, NSRect *,
                      NSRect *, NSRect *, NSRect *, NSRect *, NSRect *) =
    ^(NSRect srcRect,
      NSRect *t1l1, NSRect *t1l2, NSRect *t1c, NSRect *t1r2, NSRect *t1r1,
      NSRect *t2l1, NSRect *t2l2, NSRect *t2c, NSRect *t2r2, NSRect *t2r1,
      NSRect *ml1,  NSRect *ml2,  NSRect *mc,  NSRect *mr2,  NSRect *mr1,
      NSRect *b1l1, NSRect *b1l2, NSRect *b1c, NSRect *b1r2, NSRect *b1r1,
      NSRect *b2l1, NSRect *b2l2, NSRect *b2c, NSRect *b2r2, NSRect *b2r1)
    
    {
        CGFloat w = NSWidth(srcRect);
        CGFloat h = NSHeight(srcRect);
        
        CGFloat staticMidWidth = centerRect.size.width;
        CGFloat stretchLeftWidth = (w / 2.0) - (staticMidWidth / 2.0) - insets.left;
        CGFloat stretchRightWidth = (w / 2.0) - (staticMidWidth / 2.0) - insets.right;
        
        CGFloat staticMidHeight = centerRect.size.height;
        CGFloat stretchTopHeight = (h / 2.0) - (staticMidHeight / 2.0) - insets.top;
        CGFloat stretchBottomHeight = (h / 2.0) - (staticMidHeight / 2.0) - insets.bottom;
        
        CGFloat x0 = NSMinX(srcRect);
        CGFloat x1 = (x0 + insets.left);
        CGFloat x2 = (x0 + (w / 2.0) - (staticMidWidth / 2.0));
        CGFloat x3 = (x0 + (w / 2.0) + (staticMidWidth / 2.0));
        CGFloat x4 = (NSMaxX(srcRect) - insets.right);
        
        CGFloat y0 = NSMinY(srcRect);
        CGFloat y1 = (y0 + insets.bottom);
        CGFloat y2 = (y0 + (h / 2.0) - (staticMidHeight / 2.0));
        CGFloat y3 = (y0 + (h / 2.0) + (staticMidHeight / 2.0));
        CGFloat y4 = (NSMaxY(srcRect) - insets.top);
        
//        *tl = NSMakeRect(x0, y2, insets.left, insets.top);
//        *tc = NSMakeRect(x1, y2, cw, insets.top);
//        *tr = NSMakeRect(x2, y2, insets.right, insets.top);
        
        *t1l1 = NSMakeRect(x0, y4, insets.left, insets.top);
        *t1l2 = NSMakeRect(x1, y4, stretchLeftWidth, insets.top);
        *t1c  = NSMakeRect(x2, y4, staticMidWidth, insets.top);
        *t1r2 = NSMakeRect(x3, y4, stretchRightWidth, insets.top);
        *t1r1 = NSMakeRect(x4, y4, insets.right, insets.top);
        
        *t2l1 = NSMakeRect(x0, y3, insets.left, stretchTopHeight);
        *t2l2 = NSMakeRect(x1, y3, stretchLeftWidth, stretchTopHeight);
        *t2c  = NSMakeRect(x2, y3, staticMidWidth, stretchTopHeight);
        *t2r2 = NSMakeRect(x3, y3, stretchRightWidth, stretchTopHeight);
        *t2r1 = NSMakeRect(x4, y3, insets.right, stretchTopHeight);
        
//        *ml = NSMakeRect(x0, y1, insets.left, ch);
//        *mc = NSMakeRect(x1, y1, cw, ch);
//        *mr = NSMakeRect(x2, y1, insets.right, ch);

        *ml1 = NSMakeRect(x0, y2, insets.left, staticMidHeight);
        *ml2 = NSMakeRect(x1, y2, stretchLeftWidth, staticMidHeight);
        *mc  = NSMakeRect(x2, y2, staticMidWidth, staticMidHeight);
        *mr2 = NSMakeRect(x3, y2, stretchRightWidth, staticMidHeight);
        *mr1 = NSMakeRect(x4, y2, insets.right, staticMidHeight);
        
//        *bl = NSMakeRect(x0, y0, insets.left, insets.bottom);
//        *bc = NSMakeRect(x1, y0, cw, insets.bottom);
//        *br = NSMakeRect(x2, y0, insets.right, insets.bottom);

        *b2l1 = NSMakeRect(x0, y1, insets.left, stretchBottomHeight);
        *b2l2 = NSMakeRect(x1, y1, stretchLeftWidth, stretchBottomHeight);
        *b2c  = NSMakeRect(x2, y1, staticMidWidth, stretchBottomHeight);
        *b2r2 = NSMakeRect(x3, y1, stretchRightWidth, stretchBottomHeight);
        *b2r1 = NSMakeRect(x4, y1, insets.right, stretchBottomHeight);

        *b1l1 = NSMakeRect(x0, y0, insets.left, insets.bottom);
        *b1l2 = NSMakeRect(x1, y0, stretchLeftWidth, insets.bottom);
        *b1c  = NSMakeRect(x2, y0, staticMidWidth, insets.bottom);
        *b1r2 = NSMakeRect(x3, y0, stretchRightWidth, insets.bottom);
        *b1r1 = NSMakeRect(x4, y0, insets.right, insets.bottom);
    };
    
    // Source rects
    NSRect srcRect = (NSRect){NSZeroPoint, self.size};
//    NSRect srcTopL, srcTopC, srcTopR, srcMidL, srcMidC, srcMidR, srcBotL, srcBotC, srcBotR;
//    makeAreas(srcRect, &srcTopL, &srcTopC, &srcTopR, &srcMidL, &srcMidC, &srcMidR, &srcBotL, &srcBotC, &srcBotR);
    NSRect  src_t1l1, src_t1l2, src_t1c, src_t1r2, src_t1r1,
            src_t2l1, src_t2l2, src_t2c, src_t2r2, src_t2r1,
            src_ml1,  src_ml2,  src_mc,  src_mr2,  src_mr1,
            src_b2l1, src_b2l2, src_b2c, src_b2r2, src_b2r1,
            src_b1l1, src_b1l2, src_b1c, src_b1r2, src_b1r1;
    makeAreas(srcRect,
              &src_t2l1, &src_t2l2, &src_t2c, &src_t2r2, &src_t2r1,
              &src_t1l1, &src_t1l2, &src_t1c, &src_t1r2, &src_t1r1,
              &src_ml1,  &src_ml2,  &src_mc,  &src_mr2,  &src_mr1,
              &src_b1l1, &src_b1l2, &src_b1c, &src_b1r2, &src_b1r1,
              &src_b2l1, &src_b2l2, &src_b2c, &src_b2r2, &src_b2r1);
    
    // Destinations rects
//    NSRect dstTopL, dstTopC, dstTopR, dstMidL, dstMidC, dstMidR, dstBotL, dstBotC, dstBotR;
//    makeAreas(rect, &dstBotL, &dstBotC, &dstBotR, &dstMidL, &dstMidC, &dstMidR, &dstTopL, &dstTopC, &dstTopR);
    NSRect  dst_t1l1, dst_t1l2, dst_t1c, dst_t1r2, dst_t1r1,
            dst_t2l1, dst_t2l2, dst_t2c, dst_t2r2, dst_t2r1,
            dst_ml1,  dst_ml2,  dst_mc,  dst_mr2,  dst_mr1,
            dst_b2l1, dst_b2l2, dst_b2c, dst_b2r2, dst_b2r1,
            dst_b1l1, dst_b1l2, dst_b1c, dst_b1r2, dst_b1r1;
    makeAreas(rect,
              &dst_b1l1, &dst_b1l2, &dst_b1c, &dst_b1r2, &dst_b1r1,
              &dst_b2l1, &dst_b2l2, &dst_b2c, &dst_b2r2, &dst_b2r1,
              &dst_ml1,  &dst_ml2,  &dst_mc,  &dst_mr2,  &dst_mr1,
              &dst_t2l1, &dst_t2l2, &dst_t2c, &dst_t2r2, &dst_t2r1,
              &dst_t1l1, &dst_t1l2, &dst_t1c, &dst_t1r2, &dst_t1r1);
    
    TDAssertMainThread();
    static NSDictionary *sImageHints = nil;
    if (!sImageHints) {
        sImageHints = [[NSDictionary alloc] initWithObjectsAndKeys:@(NSImageInterpolationHigh), NSImageHintInterpolation, nil];
    }
    
    BOOL flipped = YES;
    
    // this is necessary for non-retina devices to always draw the best rep. dunno why. shouldn't have to do this. :(
    NSImageRep *rep = [self bestRepresentationForRect:srcRect context:[NSGraphicsContext currentContext] hints:sImageHints];
    
    // Draw
//    [rep drawInRect:dstTopL fromRect:srcTopL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstTopC fromRect:srcTopC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstTopR fromRect:srcTopR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];

    [rep drawInRect:dst_t1l1 fromRect:src_t1l1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t1l2 fromRect:src_t1l2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t1c  fromRect:src_t1c  operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t1r2 fromRect:src_t1r2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t1r1 fromRect:src_t1r1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
                                          
    [rep drawInRect:dst_t2l1 fromRect:src_t2l1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t2l2 fromRect:src_t2l2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t2c  fromRect:src_t2c  operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t2r2 fromRect:src_t2r2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_t2r1 fromRect:src_t2r1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    
//    [rep drawInRect:dstMidL fromRect:srcMidL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstMidC fromRect:srcMidC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstMidR fromRect:srcMidR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    
    [rep drawInRect:dst_ml1 fromRect:src_ml1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_ml2 fromRect:src_ml2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_mc  fromRect:src_mc  operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_mr2 fromRect:src_mr2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_mr1 fromRect:src_mr1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    
//    [rep drawInRect:dstBotL fromRect:srcBotL operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstBotC fromRect:srcBotC operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
//    [rep drawInRect:dstBotR fromRect:srcBotR operation:op fraction:delta respectFlipped:flipped hints:sImageHints];

    [rep drawInRect:dst_b2l1 fromRect:src_b2l1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b2l2 fromRect:src_b2l2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b2c  fromRect:src_b2c  operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b2r2 fromRect:src_b2r2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b2r1 fromRect:src_b2r1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
                                          
    [rep drawInRect:dst_b1l1 fromRect:src_b1l1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b1l2 fromRect:src_b1l2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b1c  fromRect:src_b1c  operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b1r2 fromRect:src_b1r2 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    [rep drawInRect:dst_b1r1 fromRect:src_b1r1 operation:op fraction:delta respectFlipped:flipped hints:sImageHints];
    
#if DEBUG_PATCH
    [[NSColor whiteColor] setStroke];
    [NSBezierPath strokeRect:dst_ml1];
    [NSBezierPath strokeRect:dst_ml2];
    [NSBezierPath strokeRect:dst_mc];
    [NSBezierPath strokeRect:dst_mr2];
    [NSBezierPath strokeRect:dst_mr1];

    [[NSColor blueColor] setStroke];
    [NSBezierPath strokeRect:dst_t2l1];
    [NSBezierPath strokeRect:dst_t2l2];
    [NSBezierPath strokeRect:dst_t2c];
    [NSBezierPath strokeRect:dst_t2r2];
    [NSBezierPath strokeRect:dst_t2r1];
    
    [[NSColor redColor] setStroke];
    [NSBezierPath strokeRect:dst_t1l1];
    [NSBezierPath strokeRect:dst_t1l2];
    [NSBezierPath strokeRect:dst_t1c];
    [NSBezierPath strokeRect:dst_t1r2];
    [NSBezierPath strokeRect:dst_t1r1];
    
    [[NSColor greenColor] setStroke];
    [NSBezierPath strokeRect:dst_b1l1];
    [NSBezierPath strokeRect:dst_b1l2];
    [NSBezierPath strokeRect:dst_b1c];
    [NSBezierPath strokeRect:dst_b1r2];
    [NSBezierPath strokeRect:dst_b1r1];

    [[NSColor orangeColor] setStroke];
    [NSBezierPath strokeRect:dst_b2l1];
    [NSBezierPath strokeRect:dst_b2l2];
    [NSBezierPath strokeRect:dst_b2c];
    [NSBezierPath strokeRect:dst_b2r2];
    [NSBezierPath strokeRect:dst_b2r1];
#endif
}

@end
