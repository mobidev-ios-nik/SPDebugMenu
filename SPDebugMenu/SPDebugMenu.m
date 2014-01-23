//
//  SPDebugMenu.m
//  SPDebugMenu
//
//  Created by Sergio Padrino on 10/11/13.
//  Copyright (c) 2013 Sergio Padrino. All rights reserved.
//

#import "SPDebugMenu.h"

#import "SPDebugMenuAction.h"
#import "SPDebugMenuTriggering.h"
#import "SPDebugMenuViewController.h"

#pragma mark - SPDebugMenu class extension

@interface SPDebugMenu () <
    SPDebugMenuTriggeringDelegate,
    SPDebugMenuViewControllerDelegate
>

@property (nonatomic, weak) UIWindow *window;
@property (nonatomic, strong, readonly) UIViewController *topMostViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, strong) NSMutableArray *triggers;
@property (nonatomic, strong) NSMutableArray *actions;

@property (nonatomic, getter = isMenuVisible) BOOL menuVisible;

@end

#pragma mark - SPDebugMenu class implementation

@implementation SPDebugMenu

- (id)initWithWindow:(UIWindow *)window
{
    self = [super init];
    if (self)
    {
        _window = window;
        
        _triggers = [NSMutableArray array];
        _actions = [NSMutableArray array];
    }
    return self;
}

- (void)registerTrigger:(id<SPDebugMenuTriggering>)trigger
{
    trigger.delegate = self;
    [self.triggers addObject:trigger];
}

- (void)unregisterAllTriggers
{
    for (id<SPDebugMenuTriggering> trigger in self.triggers)
    {
        trigger.delegate = nil;
    }
    
    [self.triggers removeAllObjects];
}

- (void)registerAction:(id<SPDebugMenuAction>)action
{
    [self.actions addObject:action];
}

- (void)unregisterAllActions
{
    for (id<SPDebugMenuAction> action in self.actions)
    {
        action.delegate = nil;
    }
    
    [self.actions removeAllObjects];
}

- (void)prepareActions
{
    for (id<SPDebugMenuAction> action in self.actions)
    {
        [action prepare];
    }
}

- (void)disposeActions
{
    for (id<SPDebugMenuAction> action in self.actions)
    {
        [action dispose];
    }
}

- (void)showDebugMenu
{
    SPDebugMenuViewController *viewController = [[SPDebugMenuViewController alloc] initWithDebugMenuActions:self.actions];
    viewController.delegate = self;
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    
    [self.topMostViewController presentViewController:self.navigationController
                                             animated:YES
                                           completion:nil];
}

- (void)dismissDebugMenu
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES
                                                                           completion:^{
                                                                               self.menuVisible = NO;
                                                                           }];
    self.navigationController = nil;
}

- (UIViewController *)topMostViewController
{
    UIViewController *topController = self.window.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

#pragma mark - SPDebugMenuTriggeringDelegate methods

- (void)debugMenuWasTriggered:(id<SPDebugMenuTriggering>)sender
{
    if (self.menuVisible) return;
    self.menuVisible = YES;

    [self prepareActions];
    [self showDebugMenu];
}

#pragma mark - SPDebugMenuViewControllerDelegate methods

- (void)debugMenuViewControllerDidFinish:(SPDebugMenuViewController *)controller
{
    [self dismissDebugMenu];
    [self disposeActions];
}

@end
