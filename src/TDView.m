//
//  TDView.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 10/19/12.
//
//

#import <TDAppKit/TDView.h>

@implementation TDView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(layoutSubviews) object:nil];
    [super dealloc];
}


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
    [self performSelector:@selector(layoutSubviews) withObject:nil afterDelay:0.0];
}


- (void)layoutSubviews {
    TDAssertMainThread();
    
}

@end
