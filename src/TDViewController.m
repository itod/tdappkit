//
//  TDViewController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDViewController.h>
#import <TDAppKit/TDTabBarItem.h>
#import <TDAppKit/TDViewControllerView.h>

NSString * const TDViewControllerViewWillMoveToSuperviewNotification = @"TDViewControllerViewWillMoveToSuperviewNotification";
NSString * const TDViewControllerViewDidMoveToSuperviewNotification = @"TDViewControllerViewDidMoveToSuperviewNotification";
NSString * const TDViewControllerViewWillMoveToWindowNotification = @"TDViewControllerViewWillMoveToWindowNotification";
NSString * const TDViewControllerViewDidMoveToWindowNotification = @"TDViewControllerViewDidMoveToWindowNotification";

@implementation TDViewController {
    BOOL _TD_isViewLoaded;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    
    self.tabBarItem = nil;
    [super dealloc];
}


- (void)loadView {
    TDAssertMainThread();
    [super loadView];
    _TD_isViewLoaded = YES;
    TDAssert([[self view] isKindOfClass:[TDViewControllerView class]]);
    [self registerForNotifications];
    //[self viewDidLoad];
}


- (void)setView:(NSView *)v {
    [super setView:v];
    if (v) {
        TDAssert([v isKindOfClass:[TDViewControllerView class]]);
    } else {
        _TD_isViewLoaded = NO;
    }
}


- (void)registerForNotifications {
    TDAssert([self isViewLoaded]);
    NSView *v = [self view];
    TDAssert([v isKindOfClass:[TDViewControllerView class]]);
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(__viewWillMoveToSuperview:) name:TDViewControllerViewWillMoveToSuperviewNotification object:v];
    [nc addObserver:self selector:@selector(__viewDidMoveToSuperview:) name:TDViewControllerViewDidMoveToSuperviewNotification object:v];
    [nc addObserver:self selector:@selector(__viewWillMoveToWindow:) name:TDViewControllerViewWillMoveToWindowNotification object:v];
    [nc addObserver:self selector:@selector(__viewDidMoveToWindow:) name:TDViewControllerViewDidMoveToWindowNotification object:v];
}


- (void)__viewWillMoveToSuperview:(NSNotification *)n {
    TDAssert([n object] == [self view]);
    
    NSView *sv = [[n userInfo] objectForKey:@"superview"];
    TDAssert(!sv || [sv isKindOfClass:[NSView class]]);
    [self viewWillMoveToSuperview:sv];
}


- (void)__viewDidMoveToSuperview:(NSNotification *)n {
    TDAssert([n object] == [self view]);

//    NSView *sv = [[n userInfo] objectForKey:@"superview"];
//    TDAssert([sv isKindOfClass:[NSView class]]);
//    TDAssert([[self view] superview] == sv);
    [self viewDidMoveToSuperview];
}


- (void)__viewWillMoveToWindow:(NSNotification *)n {
    TDAssert([n object] == [self view]);

    NSWindow *win = [[n userInfo] objectForKey:@"window"];
    TDAssert(!win || [win isKindOfClass:[NSWindow class]]);
    [self viewWillMoveToWindow:win];
}


- (void)__viewDidMoveToWindow:(NSNotification *)n {
    TDAssert([n object] == [self view]);

//    NSWindow *win = [[n userInfo] objectForKey:@"window"];
//    TDAssert([win isKindOfClass:[NSWindow class]]);
//    TDAssert([[self view] window] == win);
    [self viewDidMoveToWindow];
}


- (BOOL)isViewLoaded {
    return _TD_isViewLoaded;
}


- (void)viewDidLoad {
    
}


- (void)viewWillAppear:(BOOL)animated {
    
}


- (void)viewDidAppear:(BOOL)animated {
    
}


- (void)viewWillDisappear:(BOOL)animated {
    
}


- (void)viewDidDisappear:(BOOL)animated {
    
}


- (void)viewWillMoveToSuperview:(NSView *)v {
    
}


- (void)viewDidMoveToSuperview {
    
}


- (void)viewWillMoveToWindow:(NSWindow *)win {
    
}


- (void)viewDidMoveToWindow {
    
}

@end
