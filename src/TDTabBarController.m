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

#import <TDAppKit/TDTabBarController.h>
#import <TDAppKit/TDTabBar.h>
#import <TDAppKit/TDTabBarItem.h>
#import <TDAppKit/TDFlippedColorView.h>
#import "TDTabBarControllerView.h"

@interface TDTabBarController ()
- (void)layoutSubviews;
- (void)layoutTabBarItems;
- (void)setUpTabBarItems;
- (void)highlightButtonAtIndex:(NSInteger)i;

@property (nonatomic, readwrite, retain) TDTabBar *tabBar;
@property (nonatomic, retain) NSArray *tabBarItems;
@property (nonatomic, retain) TDTabBarItem *selectedTabBarItem;
@end

@implementation TDTabBarController

- (id)init {
    if (self = [super init]) {
        _selectedIndex = -1;
    }
    return self;
}


- (void)dealloc {
    [_tabBar removeFromSuperview];
    [_containerView removeFromSuperview];
    
    for (TDTabBarItem *item in _tabBarItems) {
        [item.button removeFromSuperview];
    }

    self.tabBar = nil;
    self.containerView = nil;
    self.delegate = nil;
    self.tabBarItems = nil;
    self.selectedTabBarItem = nil;

    TDAssert(_viewControllers);
    TDAssert([_viewControllers count]);
    TDAssert([_viewControllers containsObject:_selectedViewController]);
    // don't go thru setters
    [_selectedViewController release];
    [_viewControllers release];

    [super dealloc];
}


- (void)loadView {
    TDTabBarControllerView *tbcv = [[[TDTabBarControllerView alloc] initWithFrame:NSZeroRect] autorelease];
    self.view = tbcv;
    tbcv.color = [NSColor windowBackgroundColor];
    [tbcv setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [tbcv setWantsLayer:NO];
    
    self.tabBar = [[[TDTabBar alloc] initWithFrame:NSMakeRect(0, 0, 0, [TDTabBar defaultHeight])] autorelease];
    [_tabBar setAutoresizingMask:NSViewWidthSizable|NSViewMinYMargin];
    [tbcv addSubview:_tabBar];
    
    TDFlippedColorView *cv = [[[TDFlippedColorView alloc] initWithFrame:NSZeroRect] autorelease];
    cv.color = [NSColor windowBackgroundColor];
    [cv setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [tbcv addSubview:cv];
    self.containerView = cv;
    
    tbcv.tabBar = self.tabBar;
    tbcv.containerView = self.containerView;
    
    [self viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self layoutSubviews];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.selectedViewController = nil; // this will trigger -viewWillDisappear: & -viewDidDisappear on the selectedView controller when this tabbarcontroller is popped. 
                                       // this is desireable.
}


- (IBAction)tabBarItemClick:(id)sender {
    //NSParameterAssert([tabBarItems containsObject:sender]);
    NSInteger i = -1;
    for (TDTabBarItem *item in _tabBarItems) {
        i++;
        if (item.button == sender) break;
    }
    self.selectedIndex = i;
    [self highlightButtonAtIndex:i]; // force
}


- (void)layoutSubviews {
    TDTabBarControllerView *v = (TDTabBarControllerView *)[self view];
    [v setNeedsLayout];
    [self layoutTabBarItems];
}


- (void)layoutTabBarItems {
    [self.tabBar setNeedsLayout];
    
    [self highlightButtonAtIndex:self.selectedIndex];
    
//    NSUInteger i = 0;
//    NSUInteger selIdx = self.selectedIndex;
//    for (TDTabBarItem *item in self.tabBarItems) {
//        [[item.button cell] setHighlighted:(i == selIdx)];
//        ++i;
//    }
}


#pragma mark -
#pragma mark Properties

- (void)setSelectedIndex:(NSUInteger)i {
    NSParameterAssert(0 == i || i < [_viewControllers count]);
    if (i == _selectedIndex) return;
    
    _selectedIndex = i;
    self.selectedViewController = [_viewControllers objectAtIndex:i];
}


- (void)setSelectedViewController:(TDViewController *)vc {
    NSParameterAssert(nil == vc || [_viewControllers containsObject:vc]);
    
    if (_selectedViewController && vc == _selectedViewController) {
        return; // Dont re-show the same view controller
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)]) {
        if (![_delegate tabBarController:self shouldSelectViewController:_selectedViewController]) {
            return;
        }
    }
    
    if (_selectedViewController) {
        [_selectedViewController viewWillDisappear:NO];
        [_selectedViewController.view removeFromSuperview];
        [_selectedViewController viewDidDisappear:NO];
    }
    
    _selectedIndex = [_viewControllers indexOfObject:vc];

    [_selectedViewController release];
    _selectedViewController = [vc retain];
        
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:willSelectViewController:)]) {
        [_delegate tabBarController:self willSelectViewController:_selectedViewController];
    }
    
    [self view]; // trigger view load if necessary
    
    [_selectedViewController.view setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [_selectedViewController.view setFrame:[_containerView bounds]];
    
    [_selectedViewController viewWillAppear:NO];
    [_containerView addSubview:_selectedViewController.view];
    [_selectedViewController viewDidAppear:NO];
    
    [self highlightButtonAtIndex:_selectedIndex];
    
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)]) {
        [_delegate tabBarController:self didSelectViewController:_selectedViewController]; // TODO NO?
    }
}


- (void)setViewControllers:(NSArray *)vcs animated:(BOOL)animated {
    self.viewControllers = (id)vcs;
}


- (void)setViewControllers:(NSArray *)vcs {
    if (_viewControllers != vcs) {
        [_viewControllers release];
        _viewControllers = [vcs copy];

        // giggle handle for selectectViewController
        _selectedIndex = NSNotFound;
        self.selectedIndex = 0;
        
        [self setUpTabBarItems];
    }
}


- (void)setUpTabBarItems {
    NSInteger c = [_viewControllers count];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:c];
    
    if (c > 0) {
        NSInteger tag = 0;
        for (TDViewController *vc in _viewControllers) {
            
            TDTabBarItem *item = [vc tabBarItem];
            if (!item) {
                TDAssert([vc.title length]);
                item = [[[TDTabBarItem alloc] initWithTitle:vc.title image:nil tag:tag++] autorelease];
            }

            [item.button setAutoresizingMask:NSViewWidthSizable|NSViewMinXMargin|NSViewMaxXMargin];
            [item.button setTarget:self];
            [item.button setAction:@selector(tabBarItemClick:)];
            
            [_tabBar addSubview:item.button];
            [items addObject:item];
        }
    }
    
    self.tabBarItems = [[items copy] autorelease];
    [self highlightButtonAtIndex:_selectedIndex];
    [self layoutTabBarItems];
}


- (void)highlightButtonAtIndex:(NSInteger)i {
    NSUInteger c = [_tabBarItems count];
    if (i < 0 || 0 == c || i > c - 1) {
        return;
    }

    TDTabBarItem *newItem = [_tabBarItems objectAtIndex:i];
    
    if (_selectedTabBarItem != newItem) {
        [_selectedTabBarItem.button setState:NSOffState];
        [[_selectedTabBarItem.button cell] setHighlighted:NO];
        self.selectedTabBarItem = newItem;
    }
    [_selectedTabBarItem.button setState:NSOnState];
    [[_selectedTabBarItem.button cell] setHighlighted:YES];
}

@end
