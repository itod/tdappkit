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
//
//  NSBezierPath+TDAdditions.h
//  TDAppKit
//

#import <TDAppKit/NSBezierPath+TDAdditions.h>

@implementation NSBezierPath (TDAdditions)

+ (NSBezierPath *)bezierPathWithRoundRect:(NSRect)r xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius corners:(TDCorner)corners {
    NSBezierPath *path = [self bezierPath];
    
    xRadius = MIN(xRadius, NSWidth(r)*0.5);
    yRadius = MIN(yRadius, NSHeight(r)*0.5);
    
    CGPoint midLef = CGPointMake(NSMinX(r), NSMidY(r));
    CGPoint topLef = CGPointMake(NSMinX(r), NSMinY(r));
    CGPoint topRit = CGPointMake(NSMaxX(r), NSMinY(r));
    CGPoint botRit = CGPointMake(NSMaxX(r), NSMaxY(r));
    CGPoint botLef = CGPointMake(NSMinX(r), NSMaxY(r));
    
    if (corners & TDCornerTopLeft) {
        midLef = CGPointMake(NSMinX(r), NSMinY(r)+yRadius);
        CGPoint topMid = CGPointMake(NSMinX(r)+xRadius, NSMinY(r));

        [path moveToPoint:midLef];
        [path curveToPoint:topMid controlPoint1:midLef controlPoint2:topLef];
    } else {
        [path moveToPoint:midLef];
        [path lineToPoint:topLef];
    }
    
    if (corners & TDCornerTopRight) {
        CGPoint topMid = CGPointMake(NSMaxX(r)-xRadius, NSMinY(r));
        CGPoint midRit = CGPointMake(NSMaxX(r), NSMinY(r)+yRadius);
        
        [path lineToPoint:topMid];
        [path curveToPoint:midRit controlPoint1:topMid controlPoint2:topRit];
    } else {
        [path lineToPoint:topRit];
    }
    
    if (corners & TDCornerBottomRight) {
        CGPoint midRit = CGPointMake(NSMaxX(r), NSMaxY(r)-yRadius);
        CGPoint botMid = CGPointMake(NSMaxX(r)-xRadius, NSMaxY(r));
        
        [path lineToPoint:midRit];
        [path curveToPoint:botMid controlPoint1:midRit controlPoint2:botRit];
    } else {
        [path lineToPoint:botRit];
    }
    
    if (corners & TDCornerBottomLeft) {
        CGPoint botMid = CGPointMake(NSMinX(r)+xRadius, NSMaxY(r));
        midLef = CGPointMake(NSMinX(r), NSMaxY(r)-yRadius);
        
        [path lineToPoint:botMid];
        [path curveToPoint:midLef controlPoint1:botMid controlPoint2:botLef];
    } else {
        [path lineToPoint:botLef];
    }
    
    [path closePath];
    return path;    
}


- (CGMutablePathRef)newClosedQuartzPath {
    // Need to begin a path here.
    CGMutablePathRef path = NULL;
    
    // Then draw the path elements.
    NSInteger numElements = [self elementCount];

    if (numElements > 0) {
        path = CGPathCreateMutable(); // +1
        NSPoint points[3];
        BOOL didClosePath = YES;
        
        for (NSInteger i = 0; i < numElements; i++) {
            switch ([self elementAtIndex:i associatedPoints:points]) {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    didClosePath = NO;
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    didClosePath = NO;
                    break;
                    
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    didClosePath = YES;
                    break;
            }
        }
        
        // Be sure the path is closed or Quartz may not do valid hit detection.
        if (!didClosePath) {
            CGPathCloseSubpath(path);
        }
    }
    
    return path;
}


- (CGMutablePathRef)newOpenQuartzPath {
    // Need to begin a path here.
    CGMutablePathRef path = NULL;
    
    // Then draw the path elements.
    NSInteger numElements = [self elementCount];
    
    if (numElements > 0) {
        path = CGPathCreateMutable(); // +1
        NSPoint points[3];
        
        for (NSInteger i = 0; i < numElements; i++) {
            switch ([self elementAtIndex:i associatedPoints:points]) {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    break;
                    
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                          points[1].x, points[1].y,
                                          points[2].x, points[2].y);
                    break;
                    
                case NSClosePathBezierPathElement:
                    // noop
                    //CGPathCloseSubpath(path);
                    break;
            }
        }
    }
    
    return path;
}


static void CGPathCallback(void *info, const CGPathElement *element)
{
    NSBezierPath *path = info;
    CGPoint *points = element->points;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint:
        {
            [path moveToPoint:NSMakePoint(points[0].x, points[0].y)];
            break;
        }
        case kCGPathElementAddLineToPoint:
        {
            [path lineToPoint:NSMakePoint(points[0].x, points[0].y)];
            break;
        }
        case kCGPathElementAddQuadCurveToPoint:
        {
            // NOTE: This is untested.
            NSPoint currentPoint = [path currentPoint];
            NSPoint interpolatedPoint = NSMakePoint((currentPoint.x + 2*points[0].x) / 3, (currentPoint.y + 2*points[0].y) / 3);
            [path curveToPoint:NSMakePoint(points[1].x, points[1].y) controlPoint1:interpolatedPoint controlPoint2:interpolatedPoint];
            break;
        }
        case kCGPathElementAddCurveToPoint:
        {
            [path curveToPoint:NSMakePoint(points[2].x, points[2].y) controlPoint1:NSMakePoint(points[0].x, points[0].y) controlPoint2:NSMakePoint(points[1].x, points[1].y)];
            break;
        }
        case kCGPathElementCloseSubpath:
        {
            [path closePath];
            break;
        }
    }
}


+ (NSBezierPath *)bezierPathWithCGPath:(CGPathRef)cgPath {
    TDAssert(cgPath);
    NSBezierPath *bp = [NSBezierPath bezierPath];
    CGPathApply(cgPath, bp, CGPathCallback);
    TDAssert(bp);
    return bp;
}

@end
