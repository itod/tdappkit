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

#import <TDAppKit/TDUtils.h>
#import <TDAppKit/NSBezierPath+TDAdditions.h>
#import <QuartzCore/QuartzCore.h>
#include <sys/utsname.h>

NSGradient *TDVertGradient(NSUInteger topHex, NSUInteger botHex) {
    NSColor *topColor = TDHexColor(topHex);
    NSColor *botColor = TDHexColor(botHex);
    NSGradient *grad = [[[NSGradient alloc] initWithStartingColor:topColor endingColor:botColor] autorelease];
    return grad;
}


NSColor *TDHexColor(NSUInteger x) {
    NSUInteger red   = (0xFF0000 & x) >> 16;
    NSUInteger green = (0x00FF00 & x) >>  8;
    NSUInteger blue  = (0x0000FF & x) >>  0;
    
    return [NSColor colorWithDeviceRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}


NSColor *TDHexaColor(NSUInteger x) {
    NSUInteger red   = (0xFF000000 & x) >> 24;
    NSUInteger green = (0x00FF0000 & x) >> 16;
    NSUInteger blue  = (0x0000FF00 & x) >>  8;
    NSUInteger alpha = (0x000000FF & x) >>  0;
    
    return [NSColor colorWithDeviceRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}


NSColor *TDGrayColor(CGFloat f) {
    return [NSColor colorWithWhite:f alpha:1.0];
}


NSColor *TDGrayaColor(CGFloat f, CGFloat a) {
    return [NSColor colorWithWhite:f alpha:a];
}


NSColor *TDGrayColorDiff(NSColor *inColor, CGFloat diff) {
    return [NSColor colorWithWhite:([[inColor colorUsingColorSpace:[NSColorSpace genericGrayColorSpace]] whiteComponent]+diff) alpha:1.0];
}


id TDCGHexColor(NSUInteger x) {
    return (id)[TDHexColor(x) CGColor];
}


id TDCGHexaColor(NSUInteger x) {
    return (id)[TDHexaColor(x) CGColor];
}


NSString *TDHexStringFromColor(NSColor *c) {
    assert([c isKindOfClass:[NSColor class]]);
    
    NSString *result = nil;
    
    NSColor *convertedColor = [c colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    
    if (convertedColor) {
        result = [NSString stringWithFormat:@"%02X%02X%02X%02X",
                  (int) ([convertedColor redComponent] * 0xFF),
                  (int) ([convertedColor greenComponent] * 0xFF),
                  (int) ([convertedColor blueComponent] * 0xFF),
                  (int) ([convertedColor alphaComponent] * 0xFF)
                  ];
    }
    
    return result;
}


NSString *TDStringFromColor(NSColor *c) {
    if (!c) return @"";

    NSColor *export = [c colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    
    return [NSString stringWithFormat:@"%lf:%lf:%lf:%lf",
            export.redComponent,
            export.greenComponent,
            export.blueComponent,
            export.alphaComponent];
}


NSColor *TDColorFromString(NSString *s) {
    NSColor *result = nil;
    NSArray *chunks = [s componentsSeparatedByString:@":"];
    if ([chunks count] != 4) {
        unsigned colorCode = 0;
        unsigned char redByte, greenByte, blueByte;
        if (s) {
             NSScanner *scanner = [NSScanner scannerWithString:s];
             (void)[scanner scanHexInt:&colorCode]; // ignore error
        }
        redByte = (unsigned char)(colorCode >> 16);
        greenByte = (unsigned char)(colorCode >> 8);
        blueByte = (unsigned char)(colorCode); // masks off high bits

        result = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff green:(CGFloat)greenByte / 0xff blue:(CGFloat)blueByte / 0xff alpha:1.0];
    } else {
        CGFloat components[4];
        for (NSUInteger i = 0; i < 4; i++) {
            components[i] = [[chunks objectAtIndex:i] floatValue];
        }
        result = [NSColor colorWithDeviceRed:components[0]
                                       green:components[1]
                                        blue:components[2]
                                       alpha:components[3]];
    }
    return result;
}


void TDPerformOnMainThread(void (^block)(void)) {
    //assert(block);
    dispatch_async(dispatch_get_main_queue(), block);
}


void TDPerformOnBackgroundThread(void (^block)(void)) {
    //assert(block);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


void TDPerformOnMainThreadAfterDelay(double delay, void (^block)(void)) {
    //assert(block);
    //assert(delay >= 0.0);

    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}


void TDPerformOnBackgroundThreadAfterDelay(double delay, void (^block)(void)) {
    //assert(block);
    //assert(delay >= 0.0);

    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


//CGRect TDRectOutset(CGRect r, CGFloat dx, CGFloat dy) {
//    r.origin.x -= dx;
//    r.origin.y -= dy;
//    r.size.width += dx * 2.0;
//    r.size.height += dy * 2.0;
//    return r;
//}


NSRect TDNSRectOutset(NSRect r, CGFloat dx, CGFloat dy) {
    r.origin.x -= dx;
    r.origin.y -= dy;
    r.size.width += dx * 2.0;
    r.size.height += dy * 2.0;
    return r;
}


NSBezierPath *TDGetRoundRect(NSRect r, CGFloat radius, CGFloat lineWidth) {
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:r xRadius:radius yRadius:radius];
    //NSBezierPath *path = [NSBezierPath bezierPathWithRoundRect:r radius:radius];
    [path setLineWidth:lineWidth];
    return path;
    
//    CGFloat minX = NSMinX(r);
//    CGFloat midX = NSMidX(r);
//    CGFloat maxX = NSMaxX(r);
//    CGFloat minY = NSMinY(r);
//    CGFloat midY = NSMidY(r);
//    CGFloat maxY = NSMaxY(r);
//    
//    NSBezierPath *path = [NSBezierPath bezierPath];
//    [path setLineWidth:lineWidth];
//    [path moveToPoint:NSMakePoint(minX, midY)];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, minY) toPoint:NSMakePoint(midX, minY) radius:radius];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, minY) toPoint:NSMakePoint(maxX, midY) radius:radius];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX, maxY) toPoint:NSMakePoint(midX, maxY) radius:radius];
//    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX, maxY) toPoint:NSMakePoint(minX, midY) radius:radius];
//    [path closePath];
//    
//    return path;
}


NSBezierPath *TDDrawRoundRect(NSRect r, CGFloat radius, CGFloat lineWidth, NSGradient *fillGradient, NSColor *strokeColor) {
    //    CGContextRef c = [[NSGraphicsContext currentContext] CGContext];
    //
    //    CGContextSetLineWidth(c, lineWidth);
    
    //    NSLog(@"before r: %@", NSStringFromRect(r));
    //    r = CGContextConvertRectToDeviceSpace(c, r);
    //    NSLog(@"after r: %@", NSStringFromRect(r));
    
    NSBezierPath *path = TDGetRoundRect(r, radius, lineWidth);
    [fillGradient drawInBezierPath:path angle:90.0];
    [strokeColor setStroke];
    [path stroke];
    
    return path;
    
    //    CGContextSetLineWidth(c, lineWidth);
    //    
    //    CGContextBeginPath(c);
    //    CGContextMoveToPoint(c, minX, midY);
    //    CGContextAddArcToPoint(c, minX, minY, midX, minY, radius);
    //    CGContextAddArcToPoint(c, maxX, minY, maxX, midY, radius);
    //    CGContextAddArcToPoint(c, maxX, maxY, midX, maxY, radius);
    //    CGContextAddArcToPoint(c, minX, maxY, minX, midY, radius);
    //    CGContextClosePath(c);
    //    CGContextDrawPath(c, kCGPathFillStroke);
}


void TDAddRoundRect(CGContextRef ctx, CGRect rect, CGFloat radius) {
    CGFloat minx = CGRectGetMinX(rect);
    CGFloat midx = CGRectGetMidX(rect);
    CGFloat maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect);
    CGFloat midy = CGRectGetMidY(rect);
    CGFloat maxy = CGRectGetMaxY(rect);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, minx, midy);
    CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radius);
    CGContextClosePath(ctx);
}


BOOL TDIsCommandKeyPressed(NSInteger modifierFlags) {
    NSInteger commandKeyWasPressed = (NSEventModifierFlagCommand & modifierFlags);
    return [[NSNumber numberWithInteger:commandKeyWasPressed] boolValue];
}


BOOL TDIsControlKeyPressed(NSInteger modifierFlags) {
    NSInteger controlKeyWasPressed = (NSEventModifierFlagControl & modifierFlags);
    return [[NSNumber numberWithInteger:controlKeyWasPressed] boolValue];
}


BOOL TDIsShiftKeyPressed(NSInteger modifierFlags) {
    NSInteger commandKeyWasPressed = (NSEventModifierFlagShift & modifierFlags);
    return [[NSNumber numberWithInteger:commandKeyWasPressed] boolValue];
}


BOOL TDIsOptionKeyPressed(NSInteger modifierFlags) {
    NSInteger commandKeyWasPressed = (NSEventModifierFlagOption & modifierFlags);
    return [[NSNumber numberWithInteger:commandKeyWasPressed] boolValue];         
}


CGPoint TDAlignPointToDeviceSpace(CGContextRef ctx, CGPoint p) {
    p = CGContextConvertPointToDeviceSpace(ctx, p);
    p.x = floor(p.x);
    p.y = floor(p.y);
    p = CGContextConvertPointToUserSpace(ctx, p);
    return p;
}


CGPoint TDDeviceFloorAlign(CGContextRef ctx, CGPoint p) {
    p = TDAlignPointToDeviceSpace(ctx, p);
    p.x += 0.5;
    p.y += 0.5;
    return p;
}


NSNib *TDLoadNib(id owner, NSString *nibName, NSBundle *bundle) {
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    NSNib *nib = [[[NSNib alloc] initWithNibNamed:nibName bundle:bundle] autorelease];

    NSArray *objs = nil;
    if ([nib instantiateWithOwner:owner topLevelObjects:&objs]) {
        [objs retain];
    } else {
        NSLog(@"Could not load nib named %@", nibName);
        return nil;
    }
    return nib;
}


BOOL TDIsSierraOrLater(void) {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 11;
}


BOOL TDIsElCapOrLater(void) {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 10;
}


BOOL TDIsYozOrLater(void) {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 9;
}


BOOL TDIsMtnLionOrLater(void) {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 7;
}


BOOL TDIsLionOrLater(void) {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 6;
}


BOOL TDIsSnowLeopardOrLater(void) {
    NSUInteger major, minor, bugfix;
    TDGetSystemVersion(&major, &minor, &bugfix);
    return minor > 5;
}

//typedef struct {
//    NSInteger majorVersion;
//    NSInteger minorVersion;
//    NSInteger patchVersion;
//} NSOperatingSystemVersion;

@interface NSProcessInfo ()
//- (NSOperatingSystemVersion)operatingSystemVersion;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
void TDGetSystemVersion(NSUInteger *major, NSUInteger *minor, NSUInteger *bugfix) {
//    // Version 10.8 (Build 12A239)
//    NSString *version = [[NSProcessInfo processInfo] operatingSystemVersionString];
//    
//    NSRange r1 = [version rangeOfString:@"Version "];
//    NSRange r2 = [version rangeOfString:@" (B"];
//    
//    version = [version substringWithRange:NSMakeRange(r1.length, r2.location - r1.length)];
//    NSArray *comps = [version componentsSeparatedByString:@"."];
//    NSUInteger c = [comps count];
//
//    if (c >= 1) {
//        if (major) *major = [[comps objectAtIndex:0] intValue];
//    } else {
//        goto fail;
//    }
//    
//    if (c >= 2) {
//        if (minor) *minor = [[comps objectAtIndex:1] intValue];
//    } else {
//        goto fail;
//    }
//    
//    if (c >= 3) {
//        if (bugfix) *bugfix = [[comps objectAtIndex:2] intValue];
//    }
//
//    return;
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
        if (major) *major = version.majorVersion;
        if (minor) *minor = version.minorVersion;
        if (bugfix) *bugfix = version.patchVersion;
    } else
    {
        OSErr err;
        SInt32 systemVersion, versionMajor, versionMinor, versionBugFix;
        if ((err = Gestalt(gestaltSystemVersion, &systemVersion)) != noErr) goto fail;
        if (systemVersion < 0x1040) {
            if (major) *major = ((systemVersion & 0xF000) >> 12) * 10 + ((systemVersion & 0x0F00) >> 8);
            if (minor) *minor = (systemVersion & 0x00F0) >> 4;
            if (bugfix) *bugfix = (systemVersion & 0x000F);
        } else {
            if ((err = Gestalt(gestaltSystemVersionMajor, &versionMajor)) != noErr) goto fail;
            if ((err = Gestalt(gestaltSystemVersionMinor, &versionMinor)) != noErr) goto fail;
            if ((err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix)) != noErr) goto fail;
            if (major) *major = versionMajor;
            if (minor) *minor = versionMinor;
            if (bugfix) *bugfix = versionBugFix;
        }
    }
    return;
    
fail:
    //NSLog(@"Unable to obtain system version: %ld", (long)err);
    if (major) *major = 10;
    if (minor) *minor = 10;
    if (bugfix) *bugfix = 0;
}
#pragma clang diagnostic pop


NSStringEncoding TDNSStringEncodingFromTextEncodingName(NSString *encName) {
    return CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)encName));
}


NSString *TDTextEncodingNameFromNSStringEncoding(NSStringEncoding enc) {
    return (id)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(enc));
}


TDEdgeInsets TDEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right) {
    TDEdgeInsets e;
    e.top = top;
    e.left = left;
    e.bottom = bottom;
    e.right = right;
    return e;
}


void TDDumpAppleEvent(NSAppleEventDescriptor *aevt) {
    NSLog(@"data %@", [aevt data]);
    //NSLog(@"numberOfItems %ld", [aevt numberOfItems]);
    NSLog(@"eventClass %@", NSFileTypeForHFSTypeCode([aevt eventClass]));
    NSLog(@"eventID %@", NSFileTypeForHFSTypeCode([aevt eventID]));
    NSLog(@"descType %@", NSFileTypeForHFSTypeCode([aevt descriptorType]));
    
    NSLog(@"%@", [aevt descriptorAtIndex:1]);
    NSLog(@"%@", [aevt descriptorForKeyword:'subj']);
    NSLog(@"%@", [aevt descriptorForKeyword:'kocl']);
    NSLog(@"%@", [aevt descriptorForKeyword:'from']);
    NSLog(@"%@", [aevt descriptorForKeyword:'want']);
    NSLog(@"%@", [aevt paramDescriptorForKeyword:'subj']);
    NSLog(@"%@", [aevt paramDescriptorForKeyword:'kocl']);
    NSLog(@"%@", [aevt paramDescriptorForKeyword:'from']);
    NSLog(@"%@", [aevt paramDescriptorForKeyword:'want']);
    NSLog(@"%@", [aevt attributeDescriptorForKeyword:'subj']);
    NSLog(@"%@", [aevt attributeDescriptorForKeyword:'kocl']);
    NSLog(@"%@", [aevt attributeDescriptorForKeyword:'from']);
    NSLog(@"%@", [aevt attributeDescriptorForKeyword:'want']);
    
    NSAppleEventDescriptor *targetDesc = [aevt attributeDescriptorForKeyword:'subj'];
    NSScriptObjectSpecifier *targetSpec = [NSScriptObjectSpecifier objectSpecifierWithDescriptor:targetDesc];
    id target = [targetSpec objectsByEvaluatingSpecifier];
    NSLog(@"targetDesc %@", targetDesc);
    NSLog(@"targetSpect %@", targetSpec);
    NSLog(@"target %@", target);

}

BOOL TDRectIsZero(CGRect r) {
    return CGRectEqualToRect(r, CGRectZero);
}


CGRect TDCombineRects(CGRect r1, CGRect r2) {
    CGRect result = CGRectZero;
    
    BOOL is1Zero = TDRectIsZero(r1);
    BOOL is2Zero = TDRectIsZero(r2);
    
    if (is1Zero && is2Zero) {
        // result = CGRectZero;
    } else if (is1Zero) {
        result = r2;
    } else if (is2Zero) {
        result = r1;
    } else {
        result = CGRectUnion(r1, r2);
    }
    
    return result;
}


NSData *TDDataFromPlist(NSArray *plist, NSError **outErr) {
    if (![plist count]) return nil;
    
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:plist format:NSPropertyListXMLFormat_v1_0 options:0 error:outErr];
    if (!data) {
        if (*outErr) {
            NSLog(@"could not serialize plist %@", (*outErr));
        }
    }
    return data;
}


NSArray *TDPlistFromData(NSData *data, NSError **outErr) {
    if (![data length]) return nil;
    
    NSArray *plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:outErr];
    if (!plist) {
        if (*outErr) {
            NSLog(@"could not deserialize plist %@", (*outErr));
        }
    }
    return plist;
}


BOOL TDIsDarkMode(void) {
    NSAppearance *appearance = [NSAppearance currentAppearance];
    if (@available(macOS 10.14, *)) {
        NSAppearanceName name = [appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameAqua, NSAppearanceNameDarkAqua]];
        //NSAppearanceName name = [appearance name];
        return [name isEqualToString:NSAppearanceNameDarkAqua];
    } else {
        return NO;
    }
}



