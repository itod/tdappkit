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

#import <TDAppKit/TDView.h>

@interface TDListItem : TDView {
    NSString *reuseIdentifier;
    NSUInteger index;
    BOOL drawingDragImage;
}

- (id)initWithFrame:(NSRect)frame reuseIdentifier:(NSString *)s;

- (void)prepareForReuse;

- (NSImage *)draggingImage;

@property (nonatomic, copy) NSString *reuseIdentifier;
@property (nonatomic, assign) BOOL drawingDragImage;
@property (nonatomic, assign) NSUInteger index;
@end
