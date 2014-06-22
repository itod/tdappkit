//
//  DropTargetView.h
//  PrivateAlly
//
//  Created by Todd Ditchendorf on 4/29/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDColorView.h>

@class TDHintButton;

@interface TDDropTargetView : TDColorView

@property (nonatomic, assign) TDHintButton *hintButton;
@end
