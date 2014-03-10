//  Copyright 2009 Todd Ditchendorf
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

#import <Cocoa/Cocoa.h>

@class TDUberView;

@interface TDUberViewSplitView : NSSplitView {
    TDUberView *uberView;
    NSGradient *gradient;
    NSColor *borderColor;
}

- (id)initWithFrame:(NSRect)frame uberView:(TDUberView *)uv;

@property (nonatomic, assign) TDUberView *uberView;
@property (nonatomic, retain) NSColor *borderColor;
@property (nonatomic, retain) NSGradient *gradient;
@end
