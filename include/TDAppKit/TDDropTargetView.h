//
//  TDDropTargetView.h
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/29/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDColorView.h>

@class TDHintButton;

@interface TDDropTargetView : TDColorView

@property (nonatomic, retain) TDHintButton *hintButton;
@property (nonatomic, assign) CGSize borderMarginSize;
@property (nonatomic, assign) CGSize buttonMarginSize;
@end
