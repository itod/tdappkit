//
//  TDPreferenceWindowController.m
//  Blitz
//
//  Created by Todd Ditchendorf on 3/4/18.
//  Copyright © 2018 Celestial Teapot. All rights reserved.
//

#import <TDAppKit/TDPreferenceWindowController.h>
#import <TDAppKit/TDPreferenceModel.h>
#import <TDAppKit/TDPreferenceViewController.h>

@interface TDPreferenceWindowController ()
@property (nonatomic, retain) TDPreferenceViewController *selectedViewController;

@property (nonatomic, retain) NSArray *viewControllers;
@property (nonatomic, retain) NSDictionary *viewControllerTab;
@end

@implementation TDPreferenceWindowController

+ (instancetype)instance {
    TDAssertMainThread();
    static TDPreferenceWindowController *sInstance = nil;
    if (!sInstance) {
        sInstance = [[TDPreferenceWindowController alloc] init];
    }
    return sInstance;
}


- (instancetype)init {
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    if (self) {
        [self load];
    }
    return self;
}


- (void)dealloc {
    self.containerView = nil;
    
    self.selectedViewController = nil;
    self.viewControllers = nil;
    self.viewControllerTab = nil;
    
    [super dealloc];
}


#pragma mark -
#pragma mark NSWindowController

- (void)windowDidLoad {
    [self setUpToolbar];
    [self showPreferencePane:[self.viewControllers firstObject] animate:NO];
    [self center];
}


#pragma mark -
#pragma mark Private

- (void)load {
    TDAssertMainThread();
    
    NSString *path = [[NSBundle mainBundle] pathForResource:PREFERENCES_FILENAME ofType:@"plist"];
    TDAssert([path length]);
    NSArray *plist = [NSArray arrayWithContentsOfFile:path];
    TDAssert([plist count]);
    
    NSUInteger c = [plist count];
    
    NSMutableArray *vcs = [NSMutableArray arrayWithCapacity:c];
    NSMutableDictionary *tab = [NSMutableDictionary dictionaryWithCapacity:c];
    
    for (NSDictionary *modelPlist in plist) {
        TDPreferenceModel *mod = [TDPreferenceModel fromPlist:modelPlist];
        
        Class cls = NSClassFromString(mod.className);
        TDAssert([cls isSubclassOfClass:[TDPreferenceViewController class]]);
        
        TDPreferenceViewController *vc = [[[cls alloc] initWithModel:mod] autorelease];
        [vcs addObject:vc];
        
        [tab setObject:vc forKey:mod.identifier];
    }
    
    self.viewControllers = [[vcs copy] autorelease];
    self.viewControllerTab = [[tab copy] autorelease];
}


- (void)setUpToolbar {
    NSToolbar *tb = [[[NSToolbar alloc] initWithIdentifier:NSStringFromClass([self class])] autorelease];
    
    [tb setShowsBaselineSeparator:YES];
    [tb setDelegate:self];
    [tb setAllowsUserCustomization:NO];
    [tb setDisplayMode:NSToolbarDisplayModeIconAndLabel];
    [tb setAutosavesConfiguration:YES];
    [tb setAllowsExtensionItems:NO];
    
    TDAssert(self.window);
    [self.window setToolbar:tb];
    [tb setVisible:YES];
}


- (void)center {
    CGRect screenRect = self.window.screen.visibleFrame;
    CGRect winRect = self.window.frame;
    winRect.origin.x = round(NSMidX(screenRect) - NSWidth(winRect)*0.5);
    winRect.origin.y = round(NSHeight(screenRect)*0.66 - NSHeight(winRect)*0.5);
    [[self window] setFrame:winRect display:YES animate:NO];
}


- (void)showPreferencePaneWithIdentifier:(NSString *)identifier {
    TDPreferenceViewController *vc = [self.viewControllerTab objectForKey:identifier];
    [self showPreferencePane:vc animate:YES];
}


- (void)showPreferencePane:(TDPreferenceViewController *)vc animate:(BOOL)animate {
    if (self.selectedViewController) {
        [self.selectedViewController.view removeFromSuperview];
    }
    
    TDAssert(vc);
    self.selectedViewController = vc;
    self.window.toolbar.selectedItemIdentifier = vc.model.identifier;
    
    TDAssert(self.containerView);
    TDAssert(vc.view);
    
    CGRect winFrame = self.window.frame;
    CGRect containerFrame = self.containerView.frame;
    CGRect viewBounds = vc.view.bounds;
    TDAssert(NSWidth(containerFrame) >= NSWidth(viewBounds));
    
    CGFloat h = viewBounds.size.height;
    h += NSHeight(winFrame) - NSHeight(containerFrame);
    
    winFrame = CGRectMake(winFrame.origin.x, winFrame.origin.y+(NSHeight(winFrame)-h), NSWidth(winFrame), h);
    
    self.containerView.frame = CGRectMake(containerFrame.origin.x, containerFrame.origin.y, NSWidth(containerFrame), NSHeight(viewBounds));
    
    [self.window setFrame:winFrame display:YES animate:animate];
    
    [self.containerView addSubview:vc.view];
    vc.view.frame = CGRectMake(round(NSMidX(containerFrame)-NSWidth(viewBounds)*0.5), 0.0, NSWidth(viewBounds), NSHeight(viewBounds));
}

#pragma mark -
#pragma mark NSToolbarDelegate

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)tb {
    NSMutableArray *vec = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
    
    for (TDPreferenceViewController *vc in self.viewControllers) {
        [vec addObject:vc.model.identifier];
    }
    
    return vec;
}


- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)tb {
    return [self toolbarDefaultItemIdentifiers:tb];
}


- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)tb {
    return [self toolbarDefaultItemIdentifiers:tb];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)tb itemForItemIdentifier:(NSString *)identifier willBeInsertedIntoToolbar:(BOOL)flag {
    TDPreferenceModel *mod = [[self.viewControllerTab objectForKey:identifier] model];
    TDAssert(mod);
    
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:identifier] autorelease];
    item.label = mod.shortTitle;
    item.paletteLabel = mod.title;
    item.toolTip = mod.title;
    item.image = mod.iconImage;
    
    item.target = self;
    item.action = @selector(toolbarItemSelected:);
    
    return item;
}


#pragma mark -
#pragma mark Actions

- (IBAction)toolbarItemSelected:(NSToolbarItem *)sender {
    NSString *identifier = sender.itemIdentifier;
    
    [self showPreferencePaneWithIdentifier:identifier];
}


#pragma mark -
#pragma mark NSFontChanging

- (void)changeFont:(NSFontManager *)sender {
    if ([self.selectedViewController respondsToSelector:@selector(changeFont:)]) {
        [self.selectedViewController changeFont:sender];
    }
}

@end
