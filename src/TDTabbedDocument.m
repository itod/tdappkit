//
//  TDTabbedDocument.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabbedDocumentController.h>
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabbedWindowController.h>
#import <TDAppKit/TDTabViewController.h>
#import <TDAppKit/TDUtils.h>

static NSMutableDictionary *sDocuments = nil;

#if FU_BUILD_TARGET_SNOW_LEOPARD
@interface NSObject (Compiler)
- (void)encodeRestorableStateWithCoder:(NSCoder *)c;
- (void)restoreStateWithCoder:(NSCoder *)c;
- (void)invalidateRestorableState;
@end
#endif

@interface TDTabbedDocument ()
- (void)tryInvalidateRestorableState;

+ (TDTabbedDocument *)documentForIdentifier:(NSString *)identifier;
+ (void)addDocument:(TDTabbedDocument *)doc;
+ (void)removeDocument:(TDTabbedDocument *)doc;
+ (NSString *)nextUniqueID;
- (void)tabListViewWasSetUp:(TDTabbedWindowController *)wc;

- (TDTabbedWindowController *)tabbedWindowController;

- (TDTabModel *)newTabModelWithRepresentedObject:(id)repObj;

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, retain) NSMutableArray *models;
@property (nonatomic, retain, readwrite) TDTabModel *selectedTabModel;
@end

@implementation TDTabbedDocument

+ (void)initialize {
    if ([TDTabbedDocument class] == self) {
        sDocuments = [[NSMutableDictionary alloc] init];
    }
}

                      
+ (TDTabbedDocument *)documentForIdentifier:(NSString *)identifier {
    NSParameterAssert([identifier length]);
    TDTabbedDocument *doc = nil;
    @synchronized (sDocuments) {
        doc = [sDocuments objectForKey:identifier];
    }
    NSAssert(doc, @"");
    return doc;
}              


+ (void)addDocument:(TDTabbedDocument *)doc {
    @synchronized (sDocuments) {
        [sDocuments setObject:doc forKey:doc.identifier];
    }
}


+ (void)removeDocument:(TDTabbedDocument *)doc {
    @synchronized (sDocuments) {
        [sDocuments removeObjectForKey:doc.identifier];
    }
}


+ (NSString *)nextUniqueID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *s = [(id)CFUUIDCreateString(NULL, uuid) autorelease];
    CFRelease(uuid);
    return s;
}


- (id)init {
    if (self = [super init]) {
        self.identifier = [[self class] nextUniqueID];
        //[[self class] addDocument:self];
        
        self.models = [NSMutableArray array];
        selectedTabIndex = NSNotFound;
    }
    return self;
}


- (void)dealloc {
#ifdef TDDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif
    //[[self class] removeDocument:self];
    
    self.identifier = nil;
    self.models = nil;
    self.selectedTabModel = nil;
    self.printInfoData = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark NSResponder

- (void)tryInvalidateRestorableState {
    if ([self respondsToSelector:@selector(invalidateRestorableState)]) {
        [self invalidateRestorableState];
    }
}


- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeInteger:self.selectedTabIndex forKey:@"selectedTabIndex"];
    [coder encodeObject:printInfoData forKey:@"printInfoData"];
}


- (void)restoreStateWithCoder:(NSCoder *)coder {
    [super restoreStateWithCoder:coder];
    
    self.selectedTabIndex = [coder decodeIntegerForKey:@"selectedTabIndex"];
    self.printInfoData = [coder decodeObjectForKey:@"printInfoData"];
}


#pragma mark -
#pragma mark NSDocument

//- (void)makeWindowControllers {
//
//}


- (void)tabListViewWasSetUp:(TDTabbedWindowController *)wc {
    NSParameterAssert([wc isKindOfClass:[TDTabbedWindowController class]]);
    
    NSArray *mods = [[self.tabModels copy] autorelease];
    
    self.models = [NSMutableArray arrayWithCapacity:[mods count]];
    
    if ([mods count]) {
        NSUInteger idx = self.selectedTabIndex;
        idx = idx == NSNotFound ? 0 : idx;
        for (TDTabModel *tm in mods) {
            [self addTabModel:tm];
        }
        self.selectedTabIndex = idx;
    } else {
        [self newTab:nil];
    }
    
    hasSetUpTabsList = YES;
}



- (void)shouldCloseWindowController:(NSWindowController *)wc delegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super shouldCloseWindowController:wc delegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)sel contextInfo:(void *)ctx {
    [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:sel contextInfo:ctx];
}


- (BOOL)isDocumentEdited {
    if (TDIsLionOrLater()) {
        return [super isDocumentEdited];
    } else {
        BOOL yn = [self.selectedTabModel isDocumentEdited];
        return yn;
    }
}


- (void)updateChangeCount:(NSDocumentChangeType)type {
    if (reverting) return;
    
    if (!TDIsLionOrLater()) {
        [self.selectedTabModel updateChangeCount:type];
    }
    [super updateChangeCount:type];
}    


#pragma mark -
#pragma mark Actions

//- (IBAction)performClose:(id)sender {
//    [self closeTab:sender];
//}


- (IBAction)closeTab:(id)sender {
    if (self.userMustConfirmTabClose) {
        TDTabbedWindowController *wc = [self tabbedWindowController];
        [wc runConfirmTabCloseSheet:nil];
    } else {
        NSUInteger i = self.selectedTabIndex;
        [self removeTabModelAtIndex:i];
    }
}
              
              
//- (IBAction)closeWindow:(id)sender {
//    [super close];
//    [[[self tabbedWindowController] window] orderOut:self];
//}
//
//
//- (void)close {
//    if ([models count] > 1) {
//        [self removeTabModelAtIndex:self.selectedTabIndex];
//    } else {
//        [self closeWindow:nil];
//    }
//}


- (IBAction)newTab:(id)sender {
    NSUInteger i = [models count];
    [self addTabModelAtIndex:[models count]];
    self.selectedTabIndex = i;
}


- (IBAction)newBackgroundTab:(id)sender {
    [self addTabModelAtIndex:[models count]];
}


- (IBAction)selectPreviousTab:(id)sender {
    NSInteger c = [models count];
    NSUInteger i = self.selectedTabIndex - 1;
    
    i = (i == -1) ? c - 1 : i;
    
    self.selectedTabIndex = i;
}


- (IBAction)selectNextTab:(id)sender {
    NSInteger c = [models count];
    NSUInteger i = self.selectedTabIndex + 1;
    
    i = (i % c);
    
    self.selectedTabIndex = i;
}


- (IBAction)takeTabIndexToCloseFrom:(id)sender {
    if (1 == [self.tabModels count]) {
        NSBeep();
        return;
    }
    
    if (self.userMustConfirmTabClose) {
        TDTabbedWindowController *wc = [self tabbedWindowController];
        [wc runConfirmTabCloseSheet:sender];
    } else {
        NSUInteger i = sender ? [sender tag] : self.selectedTabIndex;
        [self removeTabModelAtIndex:i];
    }
}


- (IBAction)takeTabIndexToMoveToNewWindowFrom:(id)sender {
    NSUInteger i = [sender tag];
    
    NSError *err = nil;
    TDTabbedDocument *doc = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:YES error:&err];
    
    if (doc) {
        TDTabModel *newtm = [[[self tabModelAtIndex:i] retain] autorelease];
        [self removeTabModelAtIndex:i];
        TDTabModel *oldtm = doc.selectedTabModel;
        
//        NSLog(@"oldtm %@", oldtm.tabViewController);
//        NSLog(@"newtm %@", newtm.tabViewController);

        [doc addTabModel:newtm];
        [doc removeTabModel:oldtm];
    } else {
        NSLog(@"%@", err);
    }
}


#pragma mark -
#pragma mark Public

- (void)addTabModelAtIndex:(NSUInteger)i {
    // create model
    
    id dc = [TDTabbedDocumentController sharedDocumentController];
    id repObj = [[dc newRepresentedObject] autorelease];
    TDTabModel *tm = [[self newTabModelWithRepresentedObject:repObj] autorelease];
    [self addTabModel:tm atIndex:i];
}


- (void)addTabModel:(TDTabModel *)tm {
    [self addTabModel:tm atIndex:[models count]];
}


- (void)addTabModel:(TDTabModel *)tm atIndex:(NSUInteger)i {
    NSParameterAssert(tm);
    NSParameterAssert(NSNotFound != i && i >= 0 && i <= [models count]);
    
    if (hasSetUpTabsList) {
        NSUndoManager *mgr = [self undoManager];
        [[mgr prepareWithInvocationTarget:self] removeTabModelAtIndex:i];
        NSString *name = [self localizedDisplayNameForTab];
        [mgr setActionName:[NSString stringWithFormat:NSLocalizedString(@"Add %@", @""), name]];
    }
    
    // set index
    tm.index = i;
    
    // create viewController
    TDTabViewController *tvc = [[self newTabViewController] autorelease];
    tvc.tabModel = tm;
    tm.tabViewController = tvc;
    tm.document = self;
    tm.index = i;

    // add or insert
    BOOL isAppend = (i == [models count]);
    if (isAppend) {
        [models addObject:tm];
    } else {
        [models insertObject:tm atIndex:i];
    }
    
    self.selectedTabIndex = i;
    
    // notify
    [self didAddTabModelAtIndex:i];
}


- (void)removeTabModelAtIndex:(NSUInteger)i {
    NSParameterAssert(NSNotFound != i && i >= 0 && i <= [models count]);

    NSUInteger c = [models count];

    if (1 == c) {
        //[self closeWindow:self];
        //[self close];
        return;
    }
    
    [self willRemoveTabModelAtIndex:i];

    NSUInteger newIndex = i;
    if (i == c - 1) {
        newIndex--;
    }
        
    TDTabModel *tm = [[[models objectAtIndex:i] retain] autorelease];

    NSUndoManager *mgr = [self undoManager];
    [[mgr prepareWithInvocationTarget:self] addTabModel:tm atIndex:i];
    NSString *fmt = NSLocalizedString(@"Remove %@", @"");
    NSString *arg = [self localizedDisplayNameForTab];
    [mgr setActionName:[NSString stringWithFormat:fmt, arg]];
    
    [models removeObjectAtIndex:i];
    
    TDTabViewController *tvc = tm.tabViewController;
    [[tvc view] removeFromSuperview]; // ?? 

    // ??
    tm.tabViewController.tabModel = nil;
    tm.tabViewController = nil;
    
    self.selectedTabIndex = newIndex;
}


- (void)removeTabModel:(TDTabModel *)tm {
    NSInteger i = [models indexOfObject:tm];
    [self removeTabModelAtIndex:i];
}


- (TDTabModel *)tabModelAtIndex:(NSUInteger)i {
    return [models objectAtIndex:i];
}


- (NSUInteger)indexOfTabModel:(TDTabModel *)tm {
    return [models indexOfObject:tm];
}


- (NSUInteger)indexOfTabModelWithRepresentedObject:(id)obj {
    NSUInteger foundIdx = NSNotFound;
    
    NSUInteger i = 0;
    for (TDTabModel *tm in models) {
        if (obj == tm.representedObject) {
            foundIdx = i;
            break;
        }
        i++;
    }

    return foundIdx;
}


#pragma mark -
#pragma mark Subclass

- (void)didAddTabModelAtIndex:(NSUInteger)i {
    
}


- (void)willRemoveTabModelAtIndex:(NSUInteger)i {
    
}


- (void)selectedTabIndexWillChange {
    
}


- (void)selectedTabIndexDidChange {
    
}


- (NSString *)localizedDisplayNameForTab {
    return NSLocalizedString(@"Tab", @"");
}


- (NSString *)localizedDisplayNameForTabPlural {
    return NSLocalizedString(@"Tabs", @"");
}


- (TDTabViewController *)newTabViewController {
    NSAssert1(0, @"must override %s", __PRETTY_FUNCTION__);
    return nil;
}


- (NSMenu *)contextMenuForTabModelAtIndex:(NSUInteger)i {
    if (0 == i && 1 == [models count]) {
        return nil;
    }
    
    TDTabModel *tm = [self tabModelAtIndex:i];
    NSMenu *menu = [[[NSMenu alloc] initWithTitle:@""] autorelease];
    NSMenuItem *item = nil;
    item = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"")
                                       action:@selector(takeTabIndexToCloseFrom:) 
                                keyEquivalent:@""] autorelease];
    [item setTarget:self];
    [item setRepresentedObject:tm];
    [item setOnStateImage:nil];
    [item setTag:i];
    [menu addItem:item];
    
//    item = [[[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Move Page to New Document", @"")
//                                       action:@selector(takeTabIndexToMoveToNewWindowFrom:) 
//                                keyEquivalent:@""] autorelease];
//    [item setTarget:self];
//    [item setRepresentedObject:tm];
//    [item setOnStateImage:nil];
//    [item setTag:i];
//    [menu addItem:item];    
    
    return menu;
}


#pragma mark -
#pragma mark TDTabsListViewControllerDelegate

- (NSUInteger)numberOfTabsInTabsViewController:(TDTabsListViewController *)tvc {
    NSUInteger c = [models count];
    return c;
}


- (TDTabModel *)tabsViewController:(TDTabsListViewController *)tvc tabModelAtIndex:(NSUInteger)i {
    TDTabModel *tabModel = [models objectAtIndex:i];
    return tabModel;
}


- (NSMenu *)tabsViewController:(TDTabsListViewController *)tvc contextMenuForTabModelAtIndex:(NSUInteger)i {
    return [self contextMenuForTabModelAtIndex:i];
}


- (void)tabsViewController:(TDTabsListViewController *)tvc didSelectTabModelAtIndex:(NSUInteger)i {
    self.selectedTabIndex = i;
}


- (void)tabsViewController:(TDTabsListViewController *)tvc didCloseTabModelAtIndex:(NSUInteger)i {
//    TDTabModel *tm = [models objectAtIndex:i];
//    if (tm.isDocumentEdited) {
//        // runs 'sure you want to close?' dialog
//        self.selectedTabIndex = i;
//        [self closeTab:nil];
//    } else {
        [self removeTabModelAtIndex:i];
//    }
}


- (void)tabsViewControllerWantsNewTab:(TDTabsListViewController *)tvc {
    [self newTab:nil];
}


#pragma mark -
#pragma mark Private

- (TDTabModel *)newTabModelWithRepresentedObject:(id)repObj {
    TDTabModel *tm = [[TDTabModel alloc] init];
    tm.representedObject = repObj;
    
    NSString *title = [repObj valueForKey:@"title"];
    if (!title) {
        title = [self localizedDisplayNameForTab];
        NSUInteger i = [self.models count];
        title = [NSString stringWithFormat:NSLocalizedString(@"%@ %d", @""), title, i + 1];
        [repObj setValue:title forKey:@"title"];
    }
    
    return tm;
}


#pragma mark -
#pragma mark Properties

- (TDTabbedWindowController *)tabbedWindowController {
    return [[self windowControllers] objectAtIndex:0];
}


- (NSArray *)tabModels {
    return [[models copy] autorelease];
}


- (TDTabViewController *)selectedTabViewController {
    return self.selectedTabModel.tabViewController;
}


- (void)setSelectedTabIndex:(NSUInteger)i {
    //BOOL didChange = selectedTabIndex != i;
    //if (selectedTabIndex != i) {
        [self willChangeValueForKey:@"selectedTabIndex"];

        [self selectedTabIndexWillChange];
        
        selectedTabModel.selected = NO;

        selectedTabIndex = i;
        
        TDTabModel *tm = nil;
        if (NSNotFound != selectedTabIndex) {
            tm = [models objectAtIndex:selectedTabIndex];
            tm.selected = YES;
        }
        self.selectedTabModel = tm;
    
        [self tryInvalidateRestorableState];
    
        [self selectedTabIndexDidChange];
        
        [self didChangeValueForKey:@"selectedTabIndex"];
    //}
}

@synthesize identifier;
@synthesize models;
@synthesize selectedTabIndex;
@synthesize selectedTabModel;
@synthesize userMustConfirmTabClose;
@synthesize printInfoData;
@end
