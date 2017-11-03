//
//  TDViewControllerView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/14/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDViewControllerView.h>
#import <TDAppKit/TDViewController.h>

@implementation TDViewControllerView

//- (id)initWithFrame:(CGRect)f {
//    if (self = [super initWithFrame:f]) {
//        NSLog(@"%s", __PRETTY_FUNCTION__);
//    }
//    return self;
//}


- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    [super dealloc];
}


//- (void)awakeFromNib {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
//}


- (void)viewWillMoveToSuperview:(NSView *)v {
    NSDictionary *info = nil;
    if (v) {
        info = @{@"superview": v};
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TDViewControllerViewWillMoveToSuperviewNotification object:self userInfo:info];
}


- (void)viewDidMoveToSuperview {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TDViewControllerViewDidMoveToSuperviewNotification object:self];
}


- (void)viewWillMoveToWindow:(NSWindow *)win {
    NSDictionary *info = nil;
    if (win) {
        info = @{@"window": win};
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TDViewControllerViewWillMoveToWindowNotification object:self userInfo:info];
}


- (void)viewDidMoveToWindow {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TDViewControllerViewDidMoveToWindowNotification object:self];
}

@end
