//
//  TDTabListItem.m
//  TDAppKit
//
//  Created by Todd Ditchendorf on 11/10/10.
//  Copyright 2010 Todd Ditchendorf. All rights reserved.
//

#import <TDAppKit/TDTabListItem.h>
#import <TDAppKit/TDTabModel.h>
#import <TDAppKit/TDTabsListViewController.h>
#import <TDAppKit/NSImage+TDAdditions.h>
#import "TDTabListItemStyle.h"

@interface TDTabListItem ()
- (NSImage *)imageNamed:(NSString *)name scaledToSize:(NSSize)size;
- (void)startObserveringModel:(TDTabModel *)m;
- (void)stopObserveringModel:(TDTabModel *)m;

- (void)startDrawHiRezTimer;
- (void)drawHiRezTimerFired:(NSTimer *)t;
- (void)killDrawHiRezTimer;

@property (nonatomic, retain) NSTimer *drawHiRezTimer;
@property (nonatomic, retain, readonly) TDTabListItemStyle *style;
@end

@implementation TDTabListItem

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self);
}


- (id)init {
    self = [self initWithFrame:NSZeroRect reuseIdentifier:[[self class] reuseIdentifier]];
    return self;
}


- (id)initWithFrame:(NSRect)frame reuseIdentifier:(NSString *)s {
    if (self = [super initWithFrame:frame reuseIdentifier:s]) {
        
    }
    return self;
}


- (void)dealloc {
    [self killDrawHiRezTimer];
    
    self.tabModel = nil;
    self.closeButton = nil;
    self.progressIndicator = nil;
    self.tabsListViewController = nil;
    self.drawHiRezTimer = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@>", NSStringFromClass([self class]), self, tabModel.title];
}


#pragma mark -
#pragma mark Drawing/Layout

- (void)layoutSubviews {
    [self.closeButton setTag:tabModel.index];
    [self.closeButton setTarget:tabsListViewController];

    [self.style layoutSubviewsInTabListItem:self];
}


- (NSRect)borderRectForBounds:(NSRect)bounds {
    return [self.style tabListItem:self borderRectForBounds:bounds];
}


- (NSRect)titleRectForBounds:(NSRect)bounds{
    return [self.style tabListItem:self titleRectForBounds:bounds];
}


- (NSRect)closeButtonRectForBounds:(NSRect)bounds{
    return [self.style tabListItem:self closeButtonRectForBounds:bounds];
}


- (NSRect)progressIndicatorRectForBounds:(NSRect)bounds{
    return [self.style tabListItem:self progressIndicatorRectForBounds:bounds];
}


- (NSRect)thumbnailRectForBounds:(NSRect)bounds{
    return [self.style tabListItem:self thumbnailRectForBounds:bounds];
}


- (void)drawRect:(NSRect)dirtyRect {
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    [self.style drawTabListItem:self inContext:ctx];
}


#pragma mark -
#pragma mark Draw HiRez

- (void)drawHiRezLater {
    //NSLog(@"%s YES %@", __PRETTY_FUNCTION__, tabModel);
    drawHiRez = NO;
    [self startDrawHiRezTimer];
}


- (void)startDrawHiRezTimer {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, tabModel);
    [self killDrawHiRezTimer];
    self.drawHiRezTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(drawHiRezTimerFired:) userInfo:nil repeats:NO];
}


- (void)drawHiRezTimerFired:(NSTimer *)t {
    if ([drawHiRezTimer isValid]) {
        //NSLog(@"%s %@", __PRETTY_FUNCTION__, tabModel);
        drawHiRez = YES;
        [super setNeedsDisplay:YES]; // call super to avoid setting flag
    }
}


- (void)killDrawHiRezTimer {
    [drawHiRezTimer invalidate];
    self.drawHiRezTimer = nil;
}


#pragma mark -
#pragma mark Private

- (NSImage *)imageNamed:(NSString *)name scaledToSize:(NSSize)size {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForImageResource:name];
    return [[[[NSImage alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path]] autorelease] scaledImageOfSize:size];
}


- (void)startObserveringModel:(TDTabModel *)m {
    if (m) {
        [m addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:NULL];
        [m addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        [m addObserver:self forKeyPath:@"changeCount" options:NSKeyValueObservingOptionNew context:NULL];
    }
}


- (void)stopObserveringModel:(TDTabModel *)m {
    if (m) {
        [m removeObserver:self forKeyPath:@"image"];
        [m removeObserver:self forKeyPath:@"title"];
        [m removeObserver:self forKeyPath:@"changeCount"];
    }
}


- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)obj change:(NSDictionary *)change context:(void *)ctx {
    if (obj == tabModel) {
        [self setNeedsDisplay:YES];
    }
}


#pragma mark -
#pragma mark Properties

- (void)setTabModel:(TDTabModel *)tm {
    if (tm != tabModel) {
        [self willChangeValueForKey:@"tabModel"];
        [self stopObserveringModel:tabModel];
        
        [tabModel autorelease];
        tabModel = [tm retain];
        
        [self startObserveringModel:tabModel];
        [self didChangeValueForKey:@"tabModel"];
    }
}


- (NSButton *)closeButton {
    if (!closeButton) {
        self.closeButton = [[[NSButton alloc] initWithFrame:NSZeroRect] autorelease];
        [closeButton setButtonType:NSMomentaryChangeButton];
        [closeButton setBordered:NO];
        [closeButton setAction:@selector(closeTabButtonClick:)];
        
        NSSize imgSize = NSMakeSize(10.0, 10.0);
        [closeButton setImage:[self imageNamed:@"close_button" scaledToSize:imgSize]];
        [closeButton setAlternateImage:[self imageNamed:@"close_button_pressed" scaledToSize:imgSize]];
        [self addSubview:closeButton];

    }
    return closeButton;
}


- (NSProgressIndicator *)progressIndicator {
    if (!progressIndicator) {
        self.progressIndicator = [[[NSProgressIndicator alloc] initWithFrame:NSZeroRect] autorelease];
        [progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
        [progressIndicator setControlSize:NSSmallControlSize];
        [progressIndicator setDisplayedWhenStopped:NO];
        [progressIndicator setIndeterminate:YES];
        [self addSubview:progressIndicator];
    }
    return progressIndicator;
}


- (TDTabListItemStyle *)style {
    return tabsListViewController.listItemStyle;
}
     

@synthesize tabModel;
@synthesize closeButton;
@synthesize progressIndicator;
@synthesize tabsListViewController;
@synthesize showsCloseButton;
@synthesize showsProgressIndicator;
@synthesize drawHiRezTimer;
@end
