//
//  TDTabBarControllerView.h
//  Editor
//
//  Created by Todd Ditchendorf on 6/18/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDViewControllerView.h>

@interface TDTabBarControllerView : TDViewControllerView

@property (nonatomic, retain) IBOutlet NSView *tabBar;
@property (nonatomic, retain) IBOutlet NSView *containerView;

- (CGRect)tabBarRectForBounds:(CGRect)bounds;
- (CGRect)containerViewRectForBounds:(CGRect)bounds;
@end
