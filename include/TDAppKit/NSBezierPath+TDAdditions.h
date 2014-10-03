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

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, TDCorner) {
    TDCornerTopLeft = 1,
    TDCornerBottomLeft = 2,
    TDCornerTopRight = 4,
    TDCornerBottomRight = 8
};

#define TDCornersAll TDCornerTopLeft|TDCornerTopRight|TDCornerBottomLeft|TDCornerBottomRight
#define TDCornersLeft TDCornerTopLeft|TDCornerBottomLeft
#define TDCornersRight TDCornerTopRight|TDCornerBottomRight
#define TDCornersTop TDCornerTopLeft|TDCornerTopRight
#define TDCornersBottom TDCornerBottomLeft|TDCornerBottomRight

@interface NSBezierPath (TDAdditions)
+ (NSBezierPath *)bezierPathWithRoundRect:(NSRect)r xRadius:(CGFloat)xRadius yRadius:(CGFloat)yRadius corners:(TDCorner)corners;
@end
