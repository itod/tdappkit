//
//  TDTabsViewController.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import "TDTabsListViewController.h"
#import <TDAppKit/TDTabbedDocument.h>
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabListItem.h>
#import <TDAppKit/TDUtils.h>
#import "TDTabListItemStyle.h"
#import "TDTabListItemStyleBrowser.h"

#define TAB_MODEL_KEY @"tabModel"
#define TAB_MODEL_INDEX_KEY @"tabModelIndex"
#define DOC_ID_KEY @"tabbedDocumentIdentifier"

#define TDTabPboardType @"TDTabPboardType"

static NSMutableDictionary *sClassNameForListItemStyleDict = nil;

#if FU_BUILD_TARGET_SNOW_LEOPARD
@interface NSResponder (Compiler)
- (void)encodeRestorableStateWithCoder:(NSCoder *)c;
- (void)restoreStateWithCoder:(NSCoder *)c;
- (void)invalidateRestorableState;
@end
#endif

@interface TDTabbedDocument ()
+ (TDTabbedDocument *)documentForIdentifier:(NSString *)identifier;
@property (nonatomic, copy, readonly) NSString *identifier;
@end

@interface TDTabsListViewController ()
- (TDTabbedDocument *)document;

- (void)beginEditingTabTitle:(TDTabListItem *)li atIndex:(NSUInteger)i inRect:(NSRect)titleRect;
- (void)tryInvalidateRestorableState;
- (void)stopEditing;

@property (nonatomic, retain) TDTabModel *draggingTabModel;
@property (nonatomic, retain) NSTextField *fieldEditor;
@property (nonatomic, assign) NSUInteger editingIndex;
@end

@implementation TDTabsListViewController

+ (void)initialize {
    if (self == [TDTabsListViewController class]) {
        sClassNameForListItemStyleDict = [[NSMutableDictionary alloc] init];
                                          //WithObjectsAndKeys:
                                            //NSStringFromClass([TDTabListItemStyleBrowser class]), @"browser",
                                            //nil];
    }
}


- (id)init {
    self = [super initWithNibName:@"TDTabsListView" bundle:[NSBundle bundleForClass:[self class]]];
    return self;
}


- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)b{
    if (self = [super initWithNibName:name bundle:b]) {
        
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

#ifndef NDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif

    self.scrollView = nil;
    self.listView = nil;
    self.overflowButtonContainerView = nil;
    self.draggingTabModel = nil;
    self.listItemStyle = nil;
    self.fieldEditor = nil;
    [super dealloc];
}


- (void)viewDidLoad {    
    TDAssert(_delegate);
    TDAssert(_listView);

    // setup ui
    _listView.backgroundColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
    _listView.nonMainBackgroundColor = [NSColor colorWithDeviceWhite:0.9 alpha:1.0];
    _listView.orientation = TDListViewOrientationLandscape;
    _listView.displaysClippedItems = YES;

    // setup drag and drop
    [_listView registerForDraggedTypes:[NSArray arrayWithObjects:TDTabPboardType, nil]];
    [_listView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [_listView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    
    TDAssert([_scrollView contentView]);
    [[_scrollView contentView] setPostsFrameChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewFrameDidChange:) name:NSViewFrameDidChangeNotification object:[_scrollView contentView]];
}


#pragma mark -
#pragma mark Actions

- (IBAction)closeTabButtonClick:(id)sender {
    TDAssert(_delegate);

    [_delegate tabsViewController:self didCloseTabModelAtIndex:[sender tag]];
    //[_listView reloadData];
}


#pragma mark -
#pragma mark TDListViewDataSource

- (NSUInteger)numberOfItemsInListView:(TDListView *)lv {
    TDAssert(_delegate);
    
    NSUInteger c = [_delegate numberOfTabsInTabsViewController:self];
    //NSLog(@"%lu", c);
    return c;
}


- (TDListItem *)listView:(TDListView *)lv itemAtIndex:(NSUInteger)i {
    TDAssert(_delegate);
    TDAssert(_listView);

    TDTabModel *tm = [_delegate tabsViewController:self tabModelAtIndex:i];
    tm.index = i;
    
    TDTabListItem *listItem = (TDTabListItem *)[_listView dequeueReusableItemWithIdentifier:[TDTabListItem reuseIdentifier]];
    
    if (!listItem) {
        listItem = [[[TDTabListItem alloc] init] autorelease];
    }
    
    TDAssert(listItem);

    listItem.tabModel = tm;
    listItem.tabsListViewController = self;
    
    [listItem setNeedsDisplay:YES];
    return listItem;
}


#pragma mark -
#pragma mark TDListViewDelegate

- (CGFloat)listView:(TDListView *)lv extentForItemAtIndex:(NSUInteger)i {
    NSSize scrollSize = [_scrollView frame].size;
    BOOL isPortrait = _listView.isPortrait;

    Class styleClass = [_listItemStyle class];
    CGFloat extent = [styleClass tabItemExtentForScrollSize:scrollSize isPortrait:isPortrait];
    return extent;
}


- (void)listView:(TDListView *)lv willDisplayView:(TDListItem *)itemView forItemAtIndex:(NSUInteger)i {
    
}


- (void)listView:(TDListView *)lv didSelectItemsAtIndexes:(NSIndexSet *)set {
    [[lv window] makeFirstResponder:lv];

//    NSResponder *resp = [[lv window] firstResponder];
//    if ([resp isKindOfClass:[NSTextView class]]) {
//        [[lv window] makeFirstResponder:nil];
//    }

    [_delegate tabsViewController:self didSelectTabModelAtIndex:[set firstIndex]];
}


- (void)listViewEmptyAreaWasDoubleClicked:(TDListView *)lv {
    [_delegate tabsViewControllerWantsNewTab:self];
}


- (NSMenu *)listView:(TDListView *)lv contextMenuForItemsAtIndexes:(NSIndexSet *)set {
    NSUInteger i = [set firstIndex];
    NSMenu *menu = [_delegate tabsViewController:self contextMenuForTabModelAtIndex:i];
    return menu;
}


- (void)listView:(TDListView *)lv itemWasDoubleClickedAtIndex:(NSUInteger)i {
    if (!_allowsTabTitleEditing) return;
    
    NSEvent *evt = [[lv window] currentEvent];
    NSPoint p = [evt locationInWindow];
    p = [lv convertPoint:p fromView:nil];
    
    TDTabListItem *li = (TDTabListItem *)[lv hitTest:p];

    p = [li convertPoint:p fromView:lv];
    NSRect r = [li titleRectForBounds:[li bounds]];
    
    if (NSPointInRect(p, r)) {
        r = [li convertRect:r toView:[self view]];
        [self beginEditingTabTitle:li atIndex:i inRect:r];
    }
}


//- (void)listView:(TDListView *)lv itemWasMiddleClickedAtIndex:(NSUInteger)i {
//    [delegate tabsViewController:self didCloseTabModelAtIndex:i];
//}


#pragma mark -
#pragma mark TDListViewDelegate Drag

- (BOOL)listView:(TDListView *)lv canDragItemsAtIndexes:(NSIndexSet *)set withEvent:(NSEvent *)evt slideBack:(BOOL *)slideBack {
    *slideBack = YES;
    return YES;
}


- (BOOL)listView:(TDListView *)lv writeItemsAtIndexes:(NSIndexSet *)set toPasteboard:(NSPasteboard *)pboard {
    NSUInteger i = [set firstIndex];
    
    TDTabbedDocument *doc = [self document];
    self.draggingTabModel = [doc tabModelAtIndex:i];

    // declare
    [pboard declareTypes:[NSArray arrayWithObjects:TDTabPboardType, TDListItemPboardType, nil] owner:self];

    // write
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_draggingTabModel];
    NSDictionary *plist = [NSDictionary dictionaryWithObjectsAndKeys:
                           data, TAB_MODEL_KEY,
                           [NSNumber numberWithInteger:i], TAB_MODEL_INDEX_KEY,
                           doc.identifier, DOC_ID_KEY,
                           nil];
    [pboard setPropertyList:plist forType:TDTabPboardType];
    
    return YES;
}


#pragma mark -
#pragma mark TDListViewDelegate Drop

- (NSDragOperation)listView:(TDListView *)lv validateDrop:(id <NSDraggingInfo>)draggingInfo proposedIndex:(NSUInteger *)proposedDropIndex dropOperation:(TDListViewDropOperation *)proposedDropOperation {
    NSPasteboard *pboard = [draggingInfo draggingPasteboard];
    
    NSArray *types = [pboard types];
    
    NSDragOperation op = NSDragOperationNone;
    
    if ([types containsObject:TDTabPboardType]) {
        op = NSDragOperationMove;
    }

    return op;
}


- (BOOL)listView:(TDListView *)lv acceptDrop:(id <NSDraggingInfo>)draggingInfo index:(NSUInteger)newIndex dropOperation:(TDListViewDropOperation)dropOperation {
    NSPasteboard *pboard = [draggingInfo draggingPasteboard];
    
    TDTabbedDocument *newDoc = [self document];
    NSArray *types = [pboard types];

    if (![types containsObject:TDTabPboardType]) {
        return NO;
    }
        
    BOOL isLocal = (nil != _draggingTabModel);

    NSDictionary *plist = [pboard propertyListForType:TDTabPboardType];
    
    TDTabbedDocument *oldDoc = nil;
    TDTabModel *tm = nil;
    NSUInteger oldIndex = NSNotFound;
    if (isLocal) {
        oldDoc = newDoc;
        tm = _draggingTabModel;

        self.draggingTabModel = nil;

        oldIndex = [oldDoc indexOfTabModel:tm];
        NSAssert(NSNotFound != oldIndex, @"");
        if (isLocal && newIndex == oldIndex) { // same index. do nothing
            return YES;
        }
    } else {
        oldDoc = [TDTabbedDocument documentForIdentifier:[plist objectForKey:DOC_ID_KEY]];
        tm = [NSKeyedUnarchiver unarchiveObjectWithData:[plist objectForKey:TAB_MODEL_KEY]];
        oldIndex = [[plist objectForKey:TAB_MODEL_INDEX_KEY] unsignedIntegerValue];
    }
    
    [oldDoc removeTabModelAtIndex:oldIndex];
    [newDoc addTabModel:tm atIndex:newIndex];
    
    [self updateAllTabModelsFromIndex:newIndex];
    newDoc.selectedTabIndex = newIndex;
    
    return YES;
}


- (BOOL)listView:(TDListView *)lv shouldRunPoofAt:(NSPoint)endPointInScreen forRemovedItemsAtIndexes:(NSIndexSet *)set {
    return NO;
    
//    NSUInteger i = [set firstIndex];
//    
//    if (!_draggingTabModel) {
//        return NO; // we dont yet support dragging tab thumbnails to a new window
//    }
//    
//    TDTabbedDocument *doc = [self document];
//    NSAssert(NSNotFound != i, @"");
//    NSAssert([set containsIndex:[doc indexOfTabModel:_draggingTabModel]], @"");
//    
//    [doc removeTabModel:_draggingTabModel];
//    self.draggingTabModel = nil;
//    
//    [self updateAllTabModelsFromIndex:i];
//    return YES;
}


#pragma mark -
#pragma mark Private

- (void)updateAllTabModels {
    [self updateAllTabModelsFromIndex:0];
}


- (void)updateAllTabModelsFromIndex:(NSUInteger)startIndex {
    NSParameterAssert(startIndex != NSNotFound);
    
//    NSArray *wvs = [self webViews];
//    NSUInteger webViewsCount = [wvs count];
//    NSUInteger lastWebViewIndex = webViewsCount - 1;
//    startIndex = startIndex > lastWebViewIndex ? lastWebViewIndex : startIndex; // make sure there's no exception here
//    
//    NSMutableArray *newModels = [NSMutableArray arrayWithCapacity:webViewsCount];
//    if (startIndex > 0 && tabModels) {
//        [newModels addObjectsFromArray:[tabModels subarrayWithRange:NSMakeRange(0, startIndex)]];
//    }
//    
//    NSInteger newModelsCount = [newModels count];
//    NSInteger i = startIndex;   
//    for (i >= 0; i < webViewsCount; i++) {
//        WebView *wv = [wvs objectAtIndex:i];
//        FUTabModel *model = [[[FUTabModel alloc] init] autorelease];
//        [self updateTabModel:model fromWebView:wv atIndex:i];
//        if (i < newModelsCount) {
//            [newModels replaceObjectAtIndex:i withObject:model];
//        } else {
//            [newModels addObject:model];
//        }
//    }
//    
//    self.tabModels = newModels;
//    
//    FUWindowController *wc = [self windowController];
//    for (FUTabController *tc in [wc tabControllers]) {
//        [self startObserveringTabController:tc];
//    }
//    
//    [self updateSelectedTabModel];
    
    [_listView reloadData];
}


- (void)updateSelectedTabModel {
//    NSUInteger selectedIndex = [[self document] selectedTabIndex];
//    
//    if (selectedModel) {
//        selectedModel.selected = NO;
//    }
//    
//    if (selectedIndex >= 0 && selectedIndex < [tabModels count]) {
//        self.selectedModel = [tabModels objectAtIndex:selectedIndex];
//        selectedModel.selected = YES;
//        
//        _listView.selectionIndexes = [NSIndexSet indexSetWithIndex:selectedIndex];
//    }
}


- (void)beginEditingTabTitle:(TDTabListItem *)li atIndex:(NSUInteger)i inRect:(NSRect)titleRect {    
    self.editingIndex = i;
    
    TDTabModel *tm = [_delegate tabsViewController:self tabModelAtIndex:i];
    
    NSString *str = [tm.title stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    str = str ? str : @"";
    
    NSWindow *win = [li window];
    titleRect = TDNSRectOutset(titleRect, 2.0, 2.0);
    self.fieldEditor = [[[NSTextField alloc] initWithFrame:titleRect] autorelease];
    
    Class styleClass = [_listItemStyle class];
    [_fieldEditor setFont:[styleClass titleFont]];
    [_fieldEditor setAlignment:[styleClass titleTextAlignment]];
    [_fieldEditor setDrawsBackground:YES];
    [_fieldEditor setBackgroundColor:[NSColor whiteColor]];
    [_fieldEditor setStringValue:str];
    [_fieldEditor setDelegate:self];
    
    [_fieldEditor setNeedsDisplay:YES];
        
    [[self view] addSubview:_fieldEditor];
    [_listView reloadData];
    
    [win makeFirstResponder:_fieldEditor];

    [self tryInvalidateRestorableState];
}


- (void)tryInvalidateRestorableState {
    if ([self respondsToSelector:@selector(invalidateRestorableState)]) {
        [self invalidateRestorableState];
    }
}


//- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
//    [super encodeRestorableStateWithCoder:coder];
//    
//    BOOL isEditingText = NO;
//    if (1 == [objs count]) {
//        isEditingText = [[objs objectAtIndex:0] isEditingText];
//    }
//    [coder encodeBool:isEditingText forKey:@"TDTabViewControllerIsEditingText"];
//    [coder encodeInteger:_editingIndex forKey:@"TDTabViewControllerEditingIndex"];
//}
//
//
//- (void)restoreStateWithCoder:(NSCoder *)coder {
//    [super restoreStateWithCoder:coder];
//    
//    BOOL isEditingText = [coder decodeBoolForKey:@"TDSelectedObjectIsEditingText"];
//    self.editingIndex = [coder decodeIntegerForKey:@"TDSelectedObjectEditingIndex"];
//    
//}


#pragma mark -
#pragma mark Notifications

- (void)viewFrameDidChange:(NSNotification *)n {
    if (_fieldEditor) {
        [self stopEditing];
    }
}


#pragma mark -
#pragma mark NSTextDelegate

- (void)controlTextDidEndEditing:(NSNotification *)n {
    NSAssert([n object] == _fieldEditor, @"");
    [self stopEditing];
}


- (void)stopEditing {
    if (!_fieldEditor) return;

//    NSTextField *fieldEditor = [n object];
    
    TDTabModel *tm = [_delegate tabsViewController:self tabModelAtIndex:_editingIndex];

//	NSUndoManager *mgr = [[self.view window] undoManager];
//	[[mgr prepareWithInvocationTarget:tm] setTitle:tm.title];
//	[mgr setActionName:NSLocalizedString(@"Change Page Title", @"")];

    tm.title = [_fieldEditor stringValue];
    
    [_fieldEditor removeFromSuperview];
    self.fieldEditor = nil;
    
    [[_listView window] endEditingFor:_listView];
    [self tryInvalidateRestorableState];
}


#pragma mark -
#pragma mark Properties

- (TDTabbedDocument *)document {
    return [[[self.view window] windowController] document];
}


+ (void)registerStyleClass:(Class)cls forName:(NSString *)name {
    NSParameterAssert(cls);
    NSParameterAssert([name length]);
    [sClassNameForListItemStyleDict setObject:NSStringFromClass(cls) forKey:name];
}


- (void)useStyleNamed:(NSString *)styleName {
    NSParameterAssert(styleName);
    Class cls = NSClassFromString([sClassNameForListItemStyleDict objectForKey:styleName]);
    NSAssert(cls, @"");
    self.listItemStyle = [[[cls alloc] init] autorelease];
    //_listView.displaysClippedItems = [[_listItemStyle class] displaysClippedItems];
}

@end
