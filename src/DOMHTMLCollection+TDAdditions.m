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

#import <TDAppKit/DOMHTMLCollection+TDAdditions.h>

@implementation DOMHTMLCollection (TDAdditions)

- (NSMutableArray *)asMutableArray {
    NSUInteger count = [self length];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        DOMNode *el = [self item:i];
        if (el) [result addObject:el];
    }
    
    return result;
}


- (NSArray *)asArray {
    return [[[self asMutableArray] copy] autorelease];
}

@end
