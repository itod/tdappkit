//
//  TDComboField.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 4/9/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDComboField.h>
#import <TDAppKit/TDListItem.h>
#import <TDAppKit/NSImage+TDAdditions.h>
#import <TDAppKit/TDUtils.h>
#import "TDComboFieldCell.h"
#import "TDComboFieldListView.h"
#import "TDComboFieldListItem.h"
#import "TDComboFieldTextView.h"

#define LIST_MARGIN_Y 5.0
#define MAX_SCROLL_HEIGHT 40

@interface TDComboField ()
- (void)removeListWindow;
- (void)resizeListWindow;
- (void)textWasInserted:(id)insertString;
- (void)removeTextFieldSelection;
- (void)addTextFieldSelectionFromListSelection;
- (void)movedToIndex:(NSUInteger)i;

@property (nonatomic, retain, readwrite) NSMutableArray *buttons;
@end

@implementation TDComboField {
    BOOL _shouldDrag;
}

+ (Class)cellClass {
    return [TDComboFieldCell class];
}


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}


- (void)dealloc {
#ifndef NDEBUG
    NSLog(@"%s %@", __PRETTY_FUNCTION__, self);
#endif

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeListWindow];
    
    TDAssert(_listView);
    _listView.dataSource = nil;
    _listView.delegate = nil;
    self.listView = nil;

    self.dataSource = nil;
    self.scrollView = nil;
    self.listWindow = nil;
    self.fieldEditor = nil;
    self.image = nil;
    self.buttons = nil;
    self.progressImage = nil;
    [super dealloc];
}


- (void)awakeFromNib {
    self.buttons = [NSMutableArray array];
    
    NSString *imgName = self.isRounded ? @"location_field_progress_indicator_rounded" : @"location_field_progress_indicator";
    NSImage *img = [NSImage imageNamed:imgName];

    self.progressImage = img;
    TDAssert(_progressImage);

    self.font = [NSFont controlContentFontOfSize:12.0];
}


- (void)viewDidMoveToWindow {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(applicationDidResignActive:) name:NSApplicationDidResignActiveNotification object:NSApp];
    [nc addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:[self window]];
    
    [self resizeSubviewsWithOldSize:NSZeroSize];
    
    if (![self image]) {
        [self showDefaultIcon];
    }
}


- (void)drawRect:(CGRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    CGRect bounds = [self bounds];
    CGSize size = bounds.size;
    
    // progress rect
    CGFloat x;
    CGFloat y;
    CGFloat w;
    CGFloat h;
    CGFloat clipWidth;
    if (TDIsYozOrLater()) {
        x = bounds.origin.x;
        y = bounds.origin.y;
        w = size.width * _progress;
        h = size.height - 1.0;
        clipWidth = size.width;
    } else if (TDIsLionOrLater()) {
        x = bounds.origin.x + 1.0;
        y = bounds.origin.y;
        w = size.width * _progress - 2.0;
        h = size.height - (_isRounded ? 2.0 : 1.0);
        clipWidth = size.width - 2.0;
    } else {
        x = bounds.origin.x + 1.0;
        y = bounds.origin.y + 2.0;
        w = size.width * _progress - 2.0;
        h = size.height - (_isRounded ? 2.0 : 1.0);
        clipWidth = size.width - 2.0;
    }
    
    if (_progress > 0.1) {
        CGSize pSize = CGSizeMake(w, h);
        CGRect pRect = CGRectMake(x, y, pSize.width, pSize.height);
        
        TDAssert(_progressImage);
        CGRect imageRect = CGRectZero;
        imageRect.size = [_progressImage size];
        imageRect.origin = NSZeroPoint;
        
        CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
        
        CGRect clipRect = CGRectMake(x, y, clipWidth, h);
        TDAddRoundRect(ctx, clipRect, 4.0);
        CGContextClip(ctx);
        CGContextSaveGState(ctx);

        [_progressImage drawStretchableInRect:pRect
                                  edgeInsets:TDEdgeInsetsMake(0.0, 10.0, 0.0, 10.0)
                                   operation:NSCompositingOperationPlusDarker
                                    fraction:1.0];
        
        CGContextSaveGState(ctx);
    }
    
    CGRect cellRect = [[self cell] drawingRectForBounds:bounds];
    cellRect.origin.x -= 2.0;
    cellRect.origin.y -= 1.0;
    [[self cell] drawInteriorImageOnlyWithFrame:cellRect inView:self];
}


- (BOOL)isListVisible {
    return nil != [self.listWindow parentWindow];
}


- (NSUInteger)numberOfItems {
    return [self numberOfItemsInListView:self.listView];
}


- (NSUInteger)indexOfSelectedItem {
    NSUInteger i = NSNotFound;
    if ([self isListVisible]) {
        i = [self.listView.selectionIndexes firstIndex];
    }
    return i;
}


- (void)deselectItemAtIndex:(NSUInteger)i {
    self.listView.selectionIndexes = nil;
}


- (void)reloadData {
    [self.listView reloadData];
}


#pragma mark -
#pragma mark Bounds

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
    [self resizeSubviewsWithOldSize:NSZeroSize];
}


- (void)resizeSubviewsWithOldSize:(CGSize)oldSize {
    [self removeListWindow];
    [super resizeSubviewsWithOldSize:oldSize];
}


- (void)addListWindow {
    if (![self isListVisible]) {
        [[self window] addChildWindow:self.listWindow ordered:NSWindowAbove];
    }
}


- (void)removeListWindow {
    if ([self isListVisible]) {
        id delegate = [self delegate];
        if (delegate && [delegate respondsToSelector:@selector(comboFieldWillDismissPopUp:)]) {
            [delegate comboFieldWillDismissPopUp:self];
        }
        if ([self.listWindow parentWindow]) {
            [[self.listWindow parentWindow] removeChildWindow:self.listWindow];
            [self.listWindow orderOut:nil];
        }
        //self.listWindow = nil;
    }
}


- (void)resizeListWindow {
    BOOL hidden = ![[self stringValue] length];
    
    if (hidden) {
        [self removeListWindow];
    } else {
        [self addListWindow];
        CGRect bounds = [self bounds];
        [self.listView setFrame:[self listViewRectForBounds:bounds]];
//        [self.scrollView setFrame:[self scrollViewRectForBounds:bounds]];
        [self.listWindow setFrame:[self listWindowRectForBounds:bounds] display:YES];
        [self.listView reloadData];
    }
}


- (CGRect)scrollViewRectForBounds:(CGRect)bounds {
    CGRect scrollRect = [self listViewRectForBounds:bounds];
    if (scrollRect.size.height > MAX_SCROLL_HEIGHT) {
        scrollRect.size.height = MAX_SCROLL_HEIGHT;
    }
    return scrollRect;
}


- (CGRect)listWindowRectForBounds:(CGRect)bounds {
    CGRect listRect = [self listViewRectForBounds:bounds];

    CGRect textFrame = [self frame];
    CGRect locInWin = [self convertRect:textFrame toView:nil];
    CGRect locInScreen = [[self window] convertRectToScreen:locInWin];
    
#define SPACING 2.0
    locInScreen.origin.y += (textFrame.origin.y - (listRect.size.height + SPACING));
    locInScreen.origin.x -= textFrame.origin.x;
    
    return CGRectMake(locInScreen.origin.x, locInScreen.origin.y, listRect.size.width, listRect.size.height);
}


- (CGRect)listViewRectForBounds:(CGRect)bounds {
    CGFloat listHeight = [TDComboFieldListItem defaultHeight] * [self numberOfItemsInListView:_listView];
    return CGRectMake(0.0, 0.0, bounds.size.width, listHeight);
}


#pragma mark -
#pragma mark NSResponder

- (void)moveRight:(id)sender {
    [self removeListWindow];
}


- (void)moveLeft:(id)sender {
    [self removeListWindow];
}


- (void)moveUp:(id)sender {
    [self removeTextFieldSelection];
    if (![self isListVisible]) {
        _listView.selectionIndexes = nil;
    }

    NSUInteger i = [_listView.selectionIndexes firstIndex];
    if (i <= 0 || NSNotFound == i) {
        i = 0;
    } else {
        i--;
    }
    [self movedToIndex:i];
}


- (void)moveDown:(id)sender {
    [self removeTextFieldSelection];
    if (![self isListVisible]) {
        _listView.selectionIndexes = nil;
    }
    
    NSUInteger i = NSNotFound;
    if ([_listView.selectionIndexes count]) {
        i = [_listView.selectionIndexes firstIndex];
    }
    NSUInteger last = [self numberOfItems] - 1;
    if (i < last) {
        i++;
    } else if (NSNotFound == i) {
        i = 0;
    }
    [self movedToIndex:i];
}


- (void)movedToIndex:(NSUInteger)i {
    _listView.selectionIndexes = [NSIndexSet indexSetWithIndex:i];
    [_listView reloadData];
    
    NSUInteger c = [self numberOfItems];
    if (c > 0) {
        [self addTextFieldSelectionFromListSelection];
        [self addListWindow];
    }
}


#pragma mark -
#pragma mark NSApplicationNotifications

- (void)applicationDidResignActive:(NSNotification *)n {
    [self removeListWindow];
}


#pragma mark -
#pragma mark NSWindowNotifications

- (void)windowDidResize:(NSNotification *)n {
    if ([n object] == [self window]) {
        [self removeListWindow];
    }
}


#pragma mark -
#pragma mark NSTextFieldDelegate

- (void)escape:(id)sender {
    if ([self isListVisible]) {
        [self removeListWindow];
        
        // clear auto-completed text
        NSRange r = [[self currentEditor] selectedRange];
        NSString *s = [[self stringValue] substringToIndex:r.location];
        if (s) [self setStringValue:s];
    } else {
        id delegate = [self delegate];
        if (delegate && [delegate respondsToSelector:@selector(comboFieldDidEscape:)]) {
            [delegate comboFieldDidEscape:self];
        }
    }
}


// <esc> was pressed
- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    [self escape:nil];
    return nil;
}


#pragma mark -
#pragma mark NSTextFieldNotifictions


- (void)textDidBeginEditing:(NSNotification *)n {
    [super textDidBeginEditing:n];

    self.listView.selectionIndexes = [NSIndexSet indexSetWithIndex:0];
    [self resizeListWindow];
}


- (void)textDidEndEditing:(NSNotification *)n {
    [super textDidEndEditing:n];

    [self removeListWindow];
}


- (void)textDidChange:(NSNotification *)n {
    [super textDidChange:n];
    
    self.listView.selectionIndexes = [NSIndexSet indexSetWithIndex:0];
    [self.listView reloadData];
    [self resizeListWindow];
}


#pragma mark -
#pragma mark Private

- (void)textWasInserted:(id)insertString {
    if (_dataSource && [_dataSource respondsToSelector:@selector(comboField:completedString:)]) {
        NSString *s = [self stringValue];
        NSUInteger loc = [s length];
        s = [_dataSource comboField:self completedString:s];
        
        if (s) {
            NSRange range = NSMakeRange(loc, [s length] - loc);
            [self setStringValue:s];
            [[self currentEditor] setSelectedRange:range];
        }
    }
}


- (void)removeTextFieldSelection {
    NSRange range = [[self currentEditor] selectedRange];
    NSString *s = [[self stringValue] substringToIndex:range.location];
    [self setStringValue:s];
}


- (void)addTextFieldSelectionFromListSelection {
    NSString *s = [_dataSource comboField:self objectAtIndex:[_listView.selectionIndexes firstIndex]];
    if (![s length]) return;
    
    NSUInteger loc = [[self stringValue] length];
    NSRange range = NSMakeRange(loc, [s length] - loc);
    [self setStringValue:s];
    [[self currentEditor] setSelectedRange:range];
}

                            
#pragma mark -
#pragma mark TDListViewDataSource

- (NSUInteger)numberOfItemsInListView:(TDListView *)lv {
    //NSAssert(_dataSource, @"must provide a FooBarDataSource");
    return [_dataSource numberOfItemsInComboField:self];
}


- (TDListItem *)listView:(TDListView *)lv itemAtIndex:(NSUInteger)i {
    //NSAssert(_dataSource, @"must provide a FooBarDataSource");
    
    TDComboFieldListItem *item = (TDComboFieldListItem *)[_listView dequeueReusableItemWithIdentifier:[TDComboFieldListItem reuseIdentifier]];
    if (!item) {
        item = [[[TDComboFieldListItem alloc] init] autorelease];
        if ([self image]) {
            item.labelMarginLeft = NSWidth([[self cell] imageRectForBounds:[self bounds]]);
        }
    }
    
    item.first = (0 == i);
    item.last = (i == [self numberOfItems] - 1);
    item.selected = ([_listView.selectionIndexes containsIndex:i]);
    item.labelText = [_dataSource comboField:self objectAtIndex:i];
    [item setNeedsDisplay:YES];
    
    return item;
}


#pragma mark -
#pragma mark TDListViewDelegate

- (CGFloat)listView:(TDListView *)lv extentForItemAtIndex:(NSUInteger)i {
    return [TDComboFieldListItem defaultHeight];
}


#pragma mark -
#pragma mark Buttons

- (NSButton *)addButtonWithSize:(CGSize)size {
    TDAssertMainThread();

    // Get button frame;
    CGRect  buttonFrame = [self buttonFrame];
    if (NSIsEmptyRect(buttonFrame)) {
        buttonFrame.origin.x = NSMinX([self frame]) + NSWidth([self frame]) - 24;
    }
    
    // Create button
    CGRect frame = CGRectZero;
    frame.origin.x = buttonFrame.origin.x - size.width - 1;
    frame.origin.y = ([self frame].size.height - size.height) / 2;
    frame.size = size;

    NSButton *b = [[[NSButton alloc] initWithFrame:frame] autorelease];
    [b setAutoresizingMask:NSViewMinXMargin|NSViewMinYMargin];
    
    // Add button
    [self addSubview:b];
    TDAssert(_buttons);
    [_buttons addObject:b];
    
    return b;
}


- (NSButton *)buttonWithTag:(int)tag {
    TDAssertMainThread();
    TDAssert(_buttons);
    for (NSButton *b in _buttons) {
        if ([b tag] == tag) {
            return b;
        }
    }
    return nil;
}


- (void)removeButton:(NSButton *)b {
    TDAssertMainThread();
    TDAssert(_buttons);
    [b removeFromSuperview];
    [_buttons removeObject:b];
}


- (CGRect)buttonFrame {
    TDAssertMainThread();
    TDAssert(_buttons);

    // Get union rect of existed buttons
    CGRect unionRect = CGRectZero;
    for (NSButton *b in _buttons) {
        unionRect = CGRectUnion(unionRect, [b frame]);
    }
    
    return unionRect;
}


#pragma mark -
#pragma mark Progress

- (void)showDefaultIcon {
    [self setImage:[NSImage imageNamed:@"default_favicon"]];
}


- (void)setProgress:(CGFloat)p {
    _progress = p;
    [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark Dragging

// click thru support
- (BOOL)acceptsFirstMouse:(NSEvent *)evt {
    return YES;
}


// click thru support
- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)evt {
    return YES;
}


- (void)mouseDown:(NSEvent *)evt {
    NSPoint p = [self convertPoint:[evt locationInWindow] fromView:nil];
    CGRect frame = [[self cell] imageFrameForCellFrame:[self bounds]];
    
    // Decide to start dragging
    _shouldDrag = CGRectContainsPoint(frame, p);
    if (!_shouldDrag) {
        [super mouseDown:evt];
        return;
    }
    
    // Select all text
    [self selectText:self];
}


- (void)mouseDragged:(NSEvent*)evt {
    if (!_shouldDrag) {
        [super mouseDragged:evt];
        return;
    }
    
    id <TDComboFieldDelegate>del = (id)self.delegate;
    TDAssert([del conformsToProtocol:@protocol(TDComboFieldDelegate)]);

    if (![del comboFieldCanWriteToPasteboard:self]) {
        return;
    }
        
    // Get drag image
    NSImage *dragImg = [[self cell] imageForDraggingWithFrame:[self bounds] inView:self];
    if (!dragImg) {
        return;
    }
    
    // Start dragging
    CGPoint locInView = CGPointZero;
    if ([self isFlipped]) {
        locInView.y = [self bounds].size.height;
    }

    TDAssert(dragImg);
    TDAssert(!CGSizeEqualToSize([dragImg size], CGSizeZero));
    NSDraggingItem *dragItem = [[[NSDraggingItem alloc] initWithPasteboardWriter:self] autorelease];
    
    CGRect dragFrame = CGRectMake(locInView.x, locInView.y, dragImg.size.width, dragImg.size.height);
    [dragItem setDraggingFrame:dragFrame contents:dragImg];
    
    [self beginDraggingSessionWithItems:@[dragItem] event:evt source:self];
}



#pragma mark -
#pragma mark NSPasteboardWriting

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pboard {
    id <TDComboFieldDelegate>del = (id)self.delegate;
    TDAssert([del conformsToProtocol:@protocol(TDComboFieldDelegate)]);

    return [del comboField:self writableTypesForPasteboard:pboard];
}


- (id)pasteboardPropertyListForType:(NSString *)type {
    id <TDComboFieldDelegate>del = (id)self.delegate;
    TDAssert([del conformsToProtocol:@protocol(TDComboFieldDelegate)]);
    
    return [del comboField:self pasteboardPropertyListForType:type];
}


#pragma mark -
#pragma mark NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)ctx {
    return NSDragOperationLink;
}


- (BOOL)ignoreModifierKeysForDraggingSession:(NSDraggingSession *)session {
    return YES;
}


#pragma mark -
#pragma mark Properties

- (NSScrollView *)scrollView {
    if (!_scrollView) {
        CGRect scrollFrame = [self listViewRectForBounds:[self bounds]];
        self.scrollView = [[[NSScrollView alloc] initWithFrame:scrollFrame] autorelease];
//        [[scrollView contentView] setFrameSize:r.size];
        [_scrollView setAutoresizingMask:NSViewWidthSizable];

        [[_scrollView contentView] setAutoresizingMask:NSViewWidthSizable];
        [[_scrollView contentView] setAutoresizesSubviews:YES];

        [_scrollView setHasHorizontalScroller:NO];
        [_scrollView setHasVerticalScroller:NO];
        [_scrollView setBorderType:NSNoBorder];
        [_scrollView setAutohidesScrollers:NO];
        
        [_scrollView setDocumentView:self.listView];
        
        CGSize s = [NSScrollView contentSizeForFrameSize:scrollFrame.size horizontalScrollerClass:nil verticalScrollerClass:nil borderType:NSNoBorder controlSize:NSControlSizeRegular scrollerStyle:NSScrollerStyleOverlay];
        //CGSize s = [NSScrollView contentSizeForFrameSize:scrollFrame.size hasHorizontalScroller:NO hasVerticalScroller:YES borderType:NSNoBorder];
        [self.listView setFrame:CGRectMake(0, 0, s.width, s.height)]; //[[_scrollView contentView] frame]];
    }
    return _scrollView;
}


- (TDListView *)listView {
    if (!_listView) {
        CGRect r = [self listViewRectForBounds:[self bounds]];
        self.listView = [[[TDComboFieldListView alloc] initWithFrame:r] autorelease];
        [_listView setAutoresizingMask:NSViewWidthSizable];
        _listView.dataSource = self;
        _listView.delegate = self;
        _listView.allowsMultipleSelection = NO;
    }
    return _listView;
}


- (NSWindow *)listWindow {
    if (!_listWindow) {
        CGRect r = [self listWindowRectForBounds:[self bounds]];
        self.listWindow = [[[NSWindow alloc] initWithContentRect:r styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES] autorelease];
        [_listWindow setOpaque:NO];
        [_listWindow setHasShadow:YES];
        [_listWindow setBackgroundColor:[NSColor clearColor]];
        [[_listWindow contentView] addSubview:self.listView];
    }
    return _listWindow;
}


- (NSTextView *)fieldEditor {
    if (!_fieldEditor) {
        self.fieldEditor = [[[TDComboFieldTextView alloc] initWithFrame:[self bounds]] autorelease];
        _fieldEditor.comboField = self;
    }
    return _fieldEditor;
}


- (NSImage *)image {
    return [[self cell] image];
}


- (void)setImage:(NSImage *)img {
    [[self cell] setImage:img];
}

@end
