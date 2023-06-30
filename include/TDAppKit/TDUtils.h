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

#import <Cocoa/Cocoa.h>

#define TDRoundAlign(x) (round((x)) + 0.5)
#define TDFloorAlign(x) (floor((x)) + 0.5)
#define TDCeilAlign(x) (ceil((x)) + 0.5)
#define TDNoop(x) (x)

#define TDRectInfinite (CGRectMake(-(UINT16_MAX>>1), -(UINT16_MAX>>1), UINT16_MAX, UINT16_MAX))

#define TD_BIG_FLOAT 1000000.0

FOUNDATION_EXTERN NSGradient *TDVertGradient(NSUInteger topHex, NSUInteger botHex);
FOUNDATION_EXTERN NSColor *TDHexColor(NSUInteger x);
FOUNDATION_EXTERN NSColor *TDHexaColor(NSUInteger x);
FOUNDATION_EXTERN NSColor *TDGrayColor(CGFloat f);
FOUNDATION_EXTERN NSColor *TDGrayaColor(CGFloat f, CGFloat a);
FOUNDATION_EXTERN NSColor *TDGrayColorDiff(NSColor *inColor, CGFloat diff);
FOUNDATION_EXTERN id TDCGHexColor(NSUInteger x);
FOUNDATION_EXTERN id TDCGHexaColor(NSUInteger x);
FOUNDATION_EXTERN NSString *TDHexStringFromColor(NSColor *c);

FOUNDATION_EXTERN NSString *TDStringFromColor(NSColor *c);
FOUNDATION_EXTERN NSColor *TDColorFromString(NSString *s);

FOUNDATION_EXTERN void TDPerformOnMainThread(void (^block)(void));
FOUNDATION_EXTERN void TDPerformOnBackgroundThread(void (^block)(void));
FOUNDATION_EXTERN void TDPerformOnMainThreadAfterDelay(double delay, void (^block)(void));
FOUNDATION_EXTERN void TDPerformOnBackgroundThreadAfterDelay(double delay, void (^block)(void));

//CGRect TDRectOutset(CGRect r, CGFloat dx, CGFloat dy);
FOUNDATION_EXTERN NSRect TDNSRectOutset(NSRect r, CGFloat dx, CGFloat dy);
FOUNDATION_EXTERN NSBezierPath *TDGetRoundRect(NSRect r, CGFloat radius, CGFloat lineWidth);
FOUNDATION_EXTERN NSBezierPath *TDDrawRoundRect(NSRect r, CGFloat radius, CGFloat lineWidth, NSGradient *fillGradient, NSColor *strokeColor);
FOUNDATION_EXTERN void TDAddRoundRect(CGContextRef ctx, CGRect rect, CGFloat radius);

FOUNDATION_EXTERN BOOL TDIsCommandKeyPressed(NSInteger modifierFlags);
FOUNDATION_EXTERN BOOL TDIsControlKeyPressed(NSInteger modifierFlags);
FOUNDATION_EXTERN BOOL TDIsShiftKeyPressed(NSInteger modifierFlags);
FOUNDATION_EXTERN BOOL TDIsOptionKeyPressed(NSInteger modifierFlags);

NSPoint TDAlignPointToDeviceSpace(CGContextRef ctx, NSPoint p);
CGPoint TDDeviceFloorAlign(CGContextRef ctx, CGPoint p);

NSNib *TDLoadNib(id owner, NSString *nibName, NSBundle *bundle);

BOOL TDIsSierraOrLater(void);
BOOL TDIsElCapOrLater(void);
BOOL TDIsYozOrLater(void);
BOOL TDIsMtnLionOrLater(void);
BOOL TDIsLionOrLater(void);
BOOL TDIsSnowLeopardOrLater(void);
void TDGetSystemVersion(NSUInteger *major, NSUInteger *minor, NSUInteger *bugfix);

NSStringEncoding TDNSStringEncodingFromTextEncodingName(NSString *encName);
NSString *TDTextEncodingNameFromNSStringEncoding(NSStringEncoding enc);

typedef struct {
    CGFloat top; 
    CGFloat left; 
    CGFloat bottom;
    CGFloat right;
} TDEdgeInsets;

TDEdgeInsets TDEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);

void TDDumpAppleEvent(NSAppleEventDescriptor *aevtDesc);

CGRect TDCombineRects(CGRect r1, CGRect r2);

NSArray *TDPlistFromData(NSData *data, NSError **outErr);
NSData *TDDataFromPlist(NSArray *plist, NSError **outErr);

FOUNDATION_EXTERN BOOL TDIsDarkMode(void);
