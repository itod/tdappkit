//
//  TDTabModel.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabViewController.h>
#import <TDAppKit/TDUtils.h>

@interface TDTabModel ()

@end

@implementation TDTabModel

- (id)initWithCoder:(NSCoder *)coder {
    self.title = [coder decodeObjectForKey:@"title"];
    self.representedObject = [coder decodeObjectForKey:@"representedObject"];
    self.index = [coder decodeIntegerForKey:@"index"];
    self.selected = [coder decodeBoolForKey:@"selected"];
    return self;
}


- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:title forKey:@"title"];
    [coder encodeObject:representedObject forKey:@"representedObject"];
    [coder encodeInteger:index forKey:@"index"];
    [coder encodeBool:selected forKey:@"selected"];
}


- (id)init {
    if (self = [super init]) {
        changeCount = 0;
    }
    return self;
}


- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    tabViewController.tabModel = nil;
    
    self.representedObject = nil;
    self.document = nil;
    self.tabViewController = nil;
    self.image = nil;
    self.scaledImage = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<TDTabModel %p %@>", self, self.title];
}


- (BOOL)isDocumentEdited {
    NSAssert(!TDIsLionOrLater(), @"");
    NSAssert(changeCount != NSNotFound, @"invalid changeCount");
    //NSLog(@"%d", changeCount);
    BOOL yn = changeCount != 0;
    [[[[document windowControllers] objectAtIndex:0] window] setDocumentEdited:yn];
    return yn;
}


- (void)updateChangeCount:(NSDocumentChangeType)type {
    NSAssert(!TDIsLionOrLater(), @"");
    NSAssert(changeCount != NSNotFound, @"invalid changeCount");

    switch (type) {
        case NSChangeDone:
            changeCount++;
            break;
        case NSChangeUndone:
            changeCount--;
            break;
        case NSChangeRedone:
            changeCount++;
            break;
        case NSChangeCleared:
            changeCount = 0;
            break;
        case NSChangeReadOtherContents:
            break;
        case NSChangeAutosaved:
            break;
        default:
            NSAssert(0, @"unknown changeType");
            break;
    }

    NSAssert(changeCount != NSNotFound, @"invalid changeCount");
}


- (BOOL)wantsNewImage {
    if (needsNewImage || !image) {
        needsNewImage = NO;
        return YES;
    }

    return NO;
}


- (void)setNeedsNewImage:(BOOL)yn {
    needsNewImage = yn;
}


- (NSString *)title {
    return [[self representedObject] valueForKey:@"title"];
}


- (void)setTitle:(NSString *)s {
    if (s != self.title) {
        [self willChangeValueForKey:@"title"];
        
//        if (title) {
//            NSString *name = [document localizedDisplayNameForTab];
//            
//            NSUndoManager *mgr = [[[[self tabViewController] view] window] undoManager];
//            [[mgr prepareWithInvocationTarget:self] setTitle:title];
//            [mgr setActionName:[NSString stringWithFormat:NSLocalizedString(@"Change %@ Title", @""), name]];
//        }
//
//        [title autorelease];
//        title = [s copy];
        
        [[self representedObject] setValue:s forKey:@"title"];
        
        [self didChangeValueForKey:@"title"];
    }
}

@synthesize title;
@synthesize representedObject;
@synthesize document;
@synthesize tabViewController;
@synthesize image;
@synthesize scaledImage;
@synthesize index;
@synthesize selected;
@synthesize busy;
@synthesize changeCount;
@end
