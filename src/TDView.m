//
//  TDView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/19/12.
//
//

#import <TDAppKit/TDView.h>
#import <TDAppKit/TDUtils.h>

@implementation TDView

#pragma mark -
#pragma mark NSView

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize {
    TDAssertMainThread();
    
    [super resizeSubviewsWithOldSize:oldSize];
    
    [self layoutSubviews];
}


#pragma mark -
#pragma mark Public

- (void)setNeedsLayout {
    TDPerformOnMainThreadAfterDelay(0.0, ^{
        [self layoutSubviews];
    });
}


- (void)layoutSubviews {
    TDAssertMainThread();
    
}

@end
