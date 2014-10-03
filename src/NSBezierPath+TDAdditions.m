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

+ (NSBezierPath *)bezierPathWithRoundRect:(NSRect)r radius:(CGFloat)radius corners:(TDCorner)corners {
    NSBezierPath *path = [self bezierPath];
    
    CGFloat xRadius = MIN(radius, NSWidth(r)*0.5);
    CGFloat yRadius = MIN(radius, NSHeight(r)*0.5);
    
    CGPoint midLef = CGPointMake(NSMinX(r), NSMidY(r));
    CGPoint topLef = CGPointMake(NSMinX(r), NSMinY(r));
    CGPoint topMid = CGPointMake(NSMidX(r), NSMinY(r));
    CGPoint topRit = CGPointMake(NSMaxX(r), NSMinY(r));
    CGPoint midRit = CGPointMake(NSMaxX(r), NSMidY(r));
    CGPoint botRit = CGPointMake(NSMaxX(r), NSMaxY(r));
    CGPoint botMid = CGPointMake(NSMidX(r), NSMaxY(r));
    CGPoint botLef = CGPointMake(NSMinX(r), NSMaxY(r));
    
    if (corners & TDCornerTopLeft) {
        midLef = CGPointMake(NSMinX(r), NSMinY(r)+yRadius);
        topMid = CGPointMake(NSMinX(r)+xRadius, NSMinY(r));

        [path moveToPoint:midLef];
        [path curveToPoint:topMid controlPoint1:midLef controlPoint2:topLef];
    } else {
        [path moveToPoint:midLef];
        [path lineToPoint:topLef];
    }
    
    if (corners & TDCornerTopRight) {
        topMid = CGPointMake(NSMaxX(r)-xRadius, NSMinY(r));
        midRit = CGPointMake(NSMaxX(r), NSMinY(r)+yRadius);
        
        [path lineToPoint:topMid];
        [path curveToPoint:midRit controlPoint1:topMid controlPoint2:topRit];
    } else {
        [path lineToPoint:topRit];
    }
    
    if (corners & TDCornerBottomRight) {
        midRit = CGPointMake(NSMaxX(r), NSMaxY(r)-yRadius);
        botMid = CGPointMake(NSMaxX(r)-xRadius, NSMaxY(r));
        
        [path lineToPoint:midRit];
        [path curveToPoint:botMid controlPoint1:midRit controlPoint2:botRit];
    } else {
        [path lineToPoint:botRit];
    }
    
    if (corners & TDCornerBottomLeft) {
        botMid = CGPointMake(NSMinX(r)+xRadius, NSMaxY(r));
        midLef = CGPointMake(NSMinX(r), NSMaxY(r)-yRadius);
        
        [path lineToPoint:botMid];
        [path curveToPoint:midLef controlPoint1:botMid controlPoint2:botLef];
    } else {
        [path lineToPoint:botLef];
    }
    
    [path closePath];
    return path;    
}


+ (NSBezierPath *)bezierPathWithRoundRect:(NSRect)r radius:(CGFloat)radius {
    return [NSBezierPath bezierPathWithRoundRect:r radius:radius corners:TDCornersAll];
}

@end
