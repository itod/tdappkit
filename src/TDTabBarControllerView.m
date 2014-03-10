//
//  TDTabBarControllerView.m
//  Editor
//
//  Created by Todd Ditchendorf on 6/18/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDTabBarControllerView.h"
#import "TDTabBar.h"

@implementation TDTabBarControllerView

+ (void)initialize {
    if ([TDTabBarControllerView class] == self) {
        
    }
}


- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

    }
    
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.tabBar = nil;
    self.containerView = nil;
    self.tabBar = nil;
    [super dealloc];
}


- (void)awakeFromNib {
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(statusBarVisibleDidChange:) name:EDStatusBarVisibleDidChangeNotification object:nil];
}


#pragma mark -
#pragma mark NSView

- (BOOL)isFlipped {
    return YES;
}


//- (void)drawRect:(NSRect)dirtyRect {
//    TDAssert([self isFlipped]);
//    CGRect bounds = [self bounds];
//    //CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
//
//    [[NSColor redColor] setFill];
//    NSRectFill([self containerViewRectForBounds:bounds]);
//
//    [[NSColor blueColor] setFill];
//    NSRectFill([self statusBarRectForBounds:bounds]);
//}


- (void)layoutSubviews {
    TDAssertMainThread();
    TDAssert(_tabBar);
    TDAssert(_containerView);
    
    CGRect bounds = [self bounds];
    
    _tabBar.frame =  [self tabBarRectForBounds:bounds];
    _containerView.frame = [self containerViewRectForBounds:bounds];
    
    NSArray *subviews = [_containerView subviews];
    if ([subviews count]) {
        [subviews[0] setFrame:[_containerView bounds]];
    }
    
    [self setNeedsDisplay:YES];
}


//- (CGRect)navBarRectForBounds:(CGRect)bounds {
//    CGFloat x = 0.0;
//    CGFloat y = 0.0;
//    CGFloat w = bounds.size.width;
//    CGFloat h = NAVBAR_HEIGHT;
//
//    CGRect r = CGRectMake(x, y, w, h);
//    return r;
//}


- (CGRect)tabBarRectForBounds:(CGRect)bounds {
    CGFloat x = CGRectGetMinX(bounds);
    CGFloat y = CGRectGetMinY(bounds);
    CGFloat w = CGRectGetWidth(bounds);
    CGFloat h = [self tabBarHeight];
    
    CGRect r = CGRectMake(x, y, w, h);
    return r;
}


- (CGRect)containerViewRectForBounds:(CGRect)bounds {
    CGFloat x = 0.0;
    CGFloat y = [self tabBarHeight];
    CGFloat w = CGRectGetWidth(bounds);
    CGFloat h = CGRectGetHeight(bounds) - y;
    
    CGRect r = CGRectMake(x, y, w, h);
    return r;
}


#pragma mark -
#pragma mark Private

- (CGFloat)tabBarHeight {
    return [TDTabBar defaultHeight];
}


#pragma mark -
#pragma mark Notifications

- (void)viewDidMoveToWindow {
    NSWindow *win = [self window];
    if (win) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:win];
        [nc addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidResignMainNotification object:win];
    }
}


- (void)windowDidBecomeMain:(NSNotification *)n {
    if ([self window]) {
        [self setNeedsDisplay:YES];
    }
}

@end
